library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;
use work.hanning_window_rom.all;

entity polar_fft_wrapper is
    generic (
        fft_len : integer := C_FFT_LEN;
        n       : integer := C_AUDIO_WIDTH
    );
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;

        -- Streaming audio input
        s_axis        : in  t_axis_forward;
        s_ready       : out std_logic;

        -- Output phase and magnitude arrays
        phase_out     : out t_phase_frame;
        magnitude_out : out t_mag_frame;
        fft_ready     : out std_logic
    );
end entity polar_fft_wrapper;

architecture behavioral of polar_fft_wrapper is

    -- IP output signals
    signal input_ram_dout      : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal phase_ram_dout      : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    signal magnitude_ram_dout  : std_logic_vector(C_AUDIO_WIDTH-1 downto 0);
    
        -- Address signals for IPs
    signal input_write_addr    : unsigned(9 downto 0) := (others => '0');
    signal input_read_addr     : unsigned(9 downto 0) := (others => '0');
    signal phase_write_addr    : unsigned(9 downto 0) := (others => '0');
    signal phase_read_addr     : unsigned(9 downto 0) := (others => '0');
    signal mag_write_addr      : unsigned(9 downto 0) := (others => '0');
    signal mag_read_addr       : unsigned(9 downto 0) := (others => '0');

    -- Address and control signals 
    signal read_offset        : unsigned(9 downto 0) := (others => '0');
    signal mult_pipe          : signed(47 downto 0) := (others => '0');
    signal valid_pipe         : std_logic := '0';
    signal last_pipe          : std_logic := '0';

    signal config_done        : std_logic := '0';

    -- Pipeline signals
    signal pipe_s_axis        : t_axis_forward;
    signal pipe_s_ready       : std_logic;
    signal pipe_m_axis        : t_polar_forward;
    signal pipe_m_ready       : std_logic;

    -- State machine
    type state_t is (IDLE, COLLECT, STREAM_BURST, WAIT_READY);
    signal current_state : state_t := IDLE;

    -- Frame read control
    signal frame_reading : std_logic := '0';
    signal fft_ready_int : std_logic := '0';

    -- Component declarations
    component audio_to_polar
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            s_axis   : in  t_axis_forward;
            s_ready  : out std_logic;
            m_axis   : out t_polar_forward;
            m_ready  : in  std_logic
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

    -- RAM instantiation
    -- input_ram: stores audio samples during COLLECT state
    input_ram_inst : playback_ram
    port map (
        clka  => clk,
        ena   => '1',
        wea   => (others => s_axis.valid),  
        addra => std_logic_vector(input_write_addr),  
        dina  => std_logic_vector(s_axis.data),  
        clkb  => clk,
        enb   => '1',
        addrb => std_logic_vector(input_read_addr), 
        doutb => input_ram_dout 
    );

    -- phase_ram: stores phase from CORDIC
    phase_ram_inst : playback_ram
    port map (
        clka  => clk,
        ena   => '1',
        wea   => (others => pipe_m_axis.valid),
        addra => std_logic_vector(phase_write_addr), 
        dina  => std_logic_vector(pipe_m_axis.phase),  
        clkb  => clk,
        enb   => '1',
        addrb => std_logic_vector(phase_read_addr),
        doutb => phase_ram_dout
    );

    -- magnitude_ram: stores magnitude from CORDIC
    magnitude_ram_inst : playback_ram
    port map (
        clka  => clk,
        ena   => '1',
        wea   => (others => pipe_m_axis.valid),  
        addra => std_logic_vector(mag_write_addr),
        dina  => std_logic_vector(pipe_m_axis.magnitude),  
        clkb  => clk,
        enb   => '1',
        addrb => std_logic_vector(mag_read_addr),
        doutb => magnitude_ram_dout
    );

    -- Instantiate the pipeline 
    audio_to_polar_inst : audio_to_polar
    port map(
        clk     => clk,
        rst     => rst,
        s_axis  => pipe_s_axis,
        s_ready => pipe_s_ready,
        m_axis  => pipe_m_axis,
        m_ready => '1'  
    );

    process (clk)
        variable multiply_result : signed(47 downto 0);
        variable raw_sample      : signed(23 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                read_offset      <= (others => '0');
                input_write_addr <= (others => '0');
                input_read_addr  <= (others => '0');
                current_state    <= IDLE;
                s_ready          <= '1';
                mult_pipe        <= (others => '0');
                valid_pipe       <= '0';
                last_pipe        <= '0';
                pipe_s_axis.valid <= '0';
                pipe_s_axis.last  <= '0';
            else
                s_ready   <= '0';

                case current_state is

                    when IDLE =>
                        s_ready <= '1';
                        if s_axis.valid = '1' and s_ready = '1' then
                            input_write_addr <= input_write_addr + 1;
                            current_state <= COLLECT;
                        end if;

                    when COLLECT =>
                        s_ready <= '1';
                        if s_axis.valid = '1' then
                            input_write_addr <= input_write_addr + 1;
                            if s_axis.last = '1' then
                                read_offset   <= (others => '0');
                                current_state <= STREAM_BURST;
                                s_ready       <= '0';
                            end if;
                        end if;

                    when STREAM_BURST =>
                        s_ready <= '0';
                        -- Compute Hanning-windowed sample
                        raw_sample      := signed(input_ram_dout);
                        multiply_result := raw_sample * hanning_rom(to_integer(read_offset));

                        -- Update pipeline registers
                        mult_pipe  <= multiply_result;
                        valid_pipe <= '1';
                        last_pipe  <= '1' when read_offset = 1023 else '0';

                        -- Drive the pipeline's input
                        pipe_s_axis.data  <= multiply_result(46 downto 23);
                        pipe_s_axis.valid <= valid_pipe;
                        pipe_s_axis.last  <= last_pipe;

                        -- Advance when pipeline accepts data
                        if pipe_s_ready = '1' then
                            if read_offset = 1023 then
                                current_state <= WAIT_READY;
                            else
                                read_offset <= read_offset + 1; 
                                input_read_addr <= input_read_addr + 1;
                            end if;
                        end if;

                    when WAIT_READY =>
                        s_ready       <= '0';
                        pipe_s_axis.valid <= '0';
                        pipe_s_axis.last  <= '0';

                        if fft_ready_int = '1' then
                            current_state <= IDLE;
                        end if;

                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Capture output process (write to phase_ram and magnitude_ram)
    process (clk)
        variable write_addr : integer range 0 to 1023 := 0;
    begin
        if rising_edge(clk) then
            fft_ready_int <= '0';
            if rst = '1' then
                write_addr := 0;
                phase_write_addr <= (others => '0');
                mag_write_addr   <= (others => '0');
            else
                if pipe_m_axis.valid = '1' then
                    phase_write_addr <= to_unsigned(write_addr, 10);
                    mag_write_addr   <= to_unsigned(write_addr, 10);
                    
                    if pipe_m_axis.last = '1' then
                        write_addr := 0;
                        fft_ready_int <= '1';
                    else
                        write_addr := write_addr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Read phase and magnitude from RAM into output arrays
    process (clk)
        variable read_addr : integer range 0 to 1023 := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                read_addr := 0;
                frame_reading <= '0';
                phase_read_addr <= (others => '0');
                mag_read_addr <= (others => '0');
                phase_out <= (others => (others => '0'));
                magnitude_out <= (others => (others => '0'));
            else

                phase_read_addr <= phase_read_addr;
                mag_read_addr <= mag_read_addr;
                
                -- Check if a new frame is ready
                if fft_ready_int = '1' and frame_reading = '0' then
                    read_addr := 0;
                    frame_reading <= '1';
                end if;
                
                -- Read the frame
                if frame_reading = '1' then
                    -- Update read addresses
                    phase_read_addr <= to_unsigned(read_addr, 10);
                    mag_read_addr   <= to_unsigned(read_addr, 10);
                    
                    -- Capture data from IPs 
                    phase_out(read_addr) <= signed(phase_ram_dout);
                    magnitude_out(read_addr) <= signed(magnitude_ram_dout);
                    
                    -- Advance to next sample
                    if read_addr = 1023 then
                        frame_reading <= '0';
                        fft_ready <= '1';  
                        read_addr := 0;
                    else
                        read_addr := read_addr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;
