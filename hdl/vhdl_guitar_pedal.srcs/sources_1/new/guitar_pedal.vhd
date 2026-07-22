library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.audio_stream_pkg.all;

entity guitar_pedal is
    port (
        CLK100MHZ : in  std_logic;
        rst       : in  std_logic;
        
        -- pitch shifting inputs
        pitch_index : in std_logic_vector (2 downto 0); 
        
        -- Pmod I2S2 DAC (Line Out)
        tx_mclk   : out std_logic;
        tx_lrck   : out std_logic;
        tx_sclk   : out std_logic;
        tx_sd     : out std_logic;

        -- Pmod I2S2 ADC (Line In)
        rx_mclk   : out std_logic;
        rx_lrck   : out std_logic;
        rx_sclk   : out std_logic;
        rx_sd     : in  std_logic
    );
end guitar_pedal;

architecture structural of guitar_pedal is
    
    -- Stream signals
    signal adc_stream       : t_axis_forward;
    signal audio_out_stream : t_axis_forward;
    
    -- Handshake signals
    signal pedal_ready     : std_logic;  -- From drop_wammy_pedal to ADC bridge
    signal overlap_ready   : std_logic;  -- From overlap-add buffer to drop_wammy_pedal
    
    -- Clock and I2S signals
    signal master_clk  : std_logic;
    signal serial_clk  : std_logic;
    signal word_select : std_logic;

    signal l_data_rx   : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal r_data_rx   : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal l_data_tx   : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal r_data_tx   : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal r_data_avg  : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);

    -- Overlap-add signals
    signal playback_ram_data_out   : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);

    -- Pitch control signals
    signal pitch_shift_ctl         : signed(15 downto 0);
    signal inverse_pitch_shift_ctl : unsigned(17 downto 0); 

    signal ws_delay        : std_logic := '0';
    
    signal frame_start_addr : unsigned(9 downto 0) := (others => '0');
    signal write_offset     : unsigned(9 downto 0) := (others => '0');
    signal i2s_read_addr    : unsigned(9 downto 0) := (others => '0');

    -- Control signals
    signal mode_sel      : std_logic := '1';   -- '0' = time, '1' = freq
    signal bypass_sel    : std_logic := '0';   -- '0' = effect on, '1' = bypass

    -- Component declarations
    component i2s_transceiver is
        generic (
            mclk_sclk_ratio : integer := 4;
            sclk_ws_ratio   : integer := 64;
            d_width         : integer := 24);
        port (
            reset_n   : in  std_logic;
            mclk      : in  std_logic;
            sclk      : out std_logic;
            ws        : out std_logic;
            sd_tx     : out std_logic;
            sd_rx     : in  std_logic;
            l_data_tx : in  std_logic_vector(d_width - 1 downto 0);
            r_data_tx : in  std_logic_vector(d_width - 1 downto 0);
            l_data_rx : out std_logic_vector(d_width - 1 downto 0);
            r_data_rx : out std_logic_vector(d_width - 1 downto 0));
    end component;

    component clk_wiz_0
        port (
            CLK_IN1  : in  std_logic;
            reset    : in  std_logic;
            clk_out1 : out std_logic
        );
    end component;
    
    component drop_wammy_pedal is 
        port(
            clk           : in  std_logic;
            rst           : in  std_logic; 
            s_axis        : in  t_axis_forward; 
            s_ready       : out std_logic;
            m_axis        : out t_axis_forward;
            m_ready       : in  std_logic;
            pitch_control : in  signed(15 downto 0);
            inverse_pitch : in  unsigned(17 downto 0); 
            mode          : in  std_logic;    
            bypass        : in  std_logic   
        );
    end component;
    
    component pitch_rom is 
        port( 
            clk                 : in  std_logic;
            pitch_index         : in  std_logic_vector(2 downto 0); 
            pitch_shift         : out signed(15 downto 0);
            inverse_pitch_shift : out unsigned(17 downto 0)
        );
    end component;
    
    COMPONENT playback_ram
        PORT (
            clka : IN STD_LOGIC;
            ena : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            clkb : IN STD_LOGIC;
            enb : IN STD_LOGIC;
            addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(23 DOWNTO 0) 
          );
        END COMPONENT;

begin

    -- Average the left and right channels (convert stereo to mono)
    r_data_avg <= std_logic_vector(resize(shift_right(resize(signed(l_data_rx), 25) + resize(signed(r_data_rx), 25), 1), 24));

    -- Clock Wizard IP
    m_clk : clk_wiz_0
    port map(
        clk_in1  => CLK100MHZ,
        reset    => rst,
        clk_out1 => master_clk
    );

    -- I2S Transceiver Instantiation
    i2s_transceiver_0 : i2s_transceiver
    generic map(
        mclk_sclk_ratio => 4,
        sclk_ws_ratio   => 64,
        d_width         => 24
    )
    port map(
        reset_n   => (not rst),
        mclk      => master_clk,
        sclk      => serial_clk,
        ws        => word_select,
        sd_tx     => tx_sd,
        sd_rx     => rx_sd,
        l_data_tx => l_data_tx,
        r_data_tx => r_data_tx,
        l_data_rx => l_data_rx,
        r_data_rx => r_data_rx
    );

    -- Pitch ROM 
    pitch_rom_0 : pitch_rom
    port map(
        clk                 => CLK100MHZ,
        pitch_index         => pitch_index,
        pitch_shift         => pitch_shift_ctl,
        inverse_pitch_shift => inverse_pitch_shift_ctl
    );

    -- Drop wammy pedal
    drop_wammy_inst : drop_wammy_pedal
    port map(
        clk           => CLK100MHZ,
        rst           => rst,
        s_axis        => adc_stream,
        s_ready       => pedal_ready,        
        m_axis        => audio_out_stream,
        m_ready       => overlap_ready,     
        pitch_control => pitch_shift_ctl,
        inverse_pitch => inverse_pitch_shift_ctl,
        mode          => mode_sel,
        bypass        => bypass_sel
    );
    
    -- Block RAM Instantiation
    -- Port A: Write (from overlap-add buffer)
    -- Port B: Read (to I2S output)
    playback_ram_inst : playback_ram
    port map (
        clka  => CLK100MHZ,
        ena   => '1',
        enb   => '1',
        wea   => (0 => audio_out_stream.valid, 
                  1 => audio_out_stream.valid, 
                  2 => audio_out_stream.valid),
        addra => std_logic_vector(resize(frame_start_addr + write_offset, 10)),
        dina  => std_logic_vector(audio_out_stream.data),
        clkb  => CLK100MHZ,
        addrb => std_logic_vector(resize(i2s_read_addr, 10)),
        doutb => playback_ram_data_out
    );
    
    -- Streaming Bridge: I2S word_select -> t_axis_forward
    process(CLK100MHZ)
        variable sample_count : integer range 0 to 1023 := 0;
    begin
        if rising_edge(CLK100MHZ) then
            if rst = '1' then
                i2s_read_addr <= (others => '0');
                sample_count := 0;
                ws_delay <= '0';
                adc_stream.valid <= '0';
                adc_stream.last <= '0';
            else
            ws_delay <= word_select;
            
                -- Detect when new sample available
                if ws_delay = '1' and word_select = '0' then
                    -- Output audio from overlap-add buffer to I2S
                    l_data_tx <= playback_ram_data_out;
                    r_data_tx <= playback_ram_data_out;
                                   
                    -- Advance read pointer
                    i2s_read_addr <= i2s_read_addr + 1;
                    
                    -- Send new sample if pedal is ready
                    if pedal_ready = '1' then
                        adc_stream.data  <= signed(r_data_avg);
                        adc_stream.valid <= '1';
                        
                        -- Manage 'last' sample frame boundaries
                        if sample_count = 1023 then
                            adc_stream.last <= '1';
                            sample_count := 0;
                        else
                            adc_stream.last <= '0';
                            sample_count := sample_count + 1;
                        end if;
                    else
                        adc_stream.valid <= '0';
                        adc_stream.last  <= '0';
                    end if;
                else
                    adc_stream.valid <= '0';
                    adc_stream.last  <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Overlap-Add Buffer Process
    process(CLK100MHZ)
        variable absolute_write_addr : integer range 0 to 1023;
    begin
        if rising_edge(CLK100MHZ) then
            if rst = '1' then 
                overlap_ready <= '1';
                frame_start_addr <= (others => '0');
                write_offset <= (others => '0'); 
            else
                overlap_ready <= '1';  -- Consider adding better more complex AXI4 logic in the future 
                
                if audio_out_stream.valid = '1' and overlap_ready = '1' then
                    -- Calculate circular address: Frame Start + current offset
                    absolute_write_addr := to_integer(frame_start_addr + write_offset);
                    
                    -- Manage write offset and frame hopping
                    if write_offset = 1023 then
                        write_offset <= (others => '0');
                        -- Shift the start of the next frame forward by the Hop Size (256)
                        frame_start_addr <= frame_start_addr + 256;
                    else
                        write_offset <= write_offset + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Send internal clocks to DAC/ADC 
    tx_mclk <= master_clk;
    tx_lrck <= word_select;
    tx_sclk <= serial_clk;

    rx_mclk <= master_clk;
    rx_lrck <= word_select;
    rx_sclk <= serial_clk;

end structural;
