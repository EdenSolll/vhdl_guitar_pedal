library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;
use work.hanning_window_rom.all;

entity rectangular_ifft is
    generic (
        fft_len : integer := C_FFT_LEN;    -- 1024
        n       : integer := C_AUDIO_WIDTH -- 24 bit samples
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;

        -- Input polar stream (phase + magnitude)
        s_axis  : in  t_polar_forward;
        s_ready : out std_logic;

        -- Output audio stream
        m_axis  : out t_axis_forward;
        m_ready : in  std_logic
    );
end entity rectangular_ifft;

architecture behavioral of rectangular_ifft is

    -- config constants
    constant s_iconfig_tdata  : std_logic_vector(23 downto 0) := "000000000000000000000000";
    constant s_data_imaginary : std_logic_vector(23 downto 0) := (others => '0'); --All of the input data is real

    -- config control signals
    signal s_config_tvalid    : std_logic := '0';
    signal s_config_tready    : std_logic;
    signal config_done        : std_logic := '0';

       -- CORDIC input signals
    signal cordic_phase_valid : std_logic := '0';
    signal cordic_phase_data  : std_logic_vector(23 downto 0) := (others => '0');
    signal cordic_mag_valid   : std_logic := '0';
    signal cordic_mag_data    : std_logic_vector(47 downto 0) := (others => '0');
    signal cordic_in_tlast    : std_logic := '0';
    
        -- Output from CORDIC (to IFFT)
    signal cordic_out_tvalid  : std_logic;
    signal cordic_out_tlast   : std_logic;
    signal cordic_out_tdata   : std_logic_vector(47 downto 0);

    -- IFFT output signals
    signal ifft_data_tdata    : std_logic_vector(47 downto 0);
    signal ifft_data_tvalid   : std_logic;
    signal ifft_data_tlast    : std_logic;

    -- Hanning window signals
    signal ifft_sample_index  : integer range 0 to 1023 := 0;
    signal ifft_audio_out     : t_audio_sample := (others => '0');
    signal ifft_out_valid     : std_logic := '0';
    signal ifft_out_last      : std_logic := '0';
    
    -- Frame buffers (stores one full frame of phase + magnitude)
    signal phase_buf   : t_phase_frame := (others => (others => '0'));
    signal mag_buf     : t_mag_frame   := (others => (others => '0'));
    signal write_index : integer range 0 to 1023 := 0;

    -- State machine types and signals
    type state_t is (IDLE, COLLECT, STREAM_CORDIC, WAIT_IFFT);
    signal state : state_t := IDLE;

    -- Streaming index for CORDIC
    signal cordic_idx : integer range 0 to 1023 := 0;
    
    -- component declarations
    component xfft_0
        port (
            aclk                 : in  std_logic;
            aresetn              : in  std_logic;
            s_axis_config_tdata  : in  std_logic_vector(23 downto 0);
            s_axis_config_tvalid : in  std_logic;
            s_axis_config_tready : out std_logic;
            s_axis_data_tdata    : in  std_logic_vector(47 downto 0);
            s_axis_data_tvalid   : in  std_logic;
            s_axis_data_tready   : out std_logic;
            s_axis_data_tlast    : in  std_logic;
            m_axis_data_tdata    : out std_logic_vector(47 downto 0);
            m_axis_data_tuser    : out std_logic_vector(15 downto 0);
            m_axis_data_tvalid   : out std_logic;
            m_axis_data_tlast    : out std_logic
        );
    end component;

    component cordic_1
        port (
            aclk                    : in  std_logic;
            aresetn                 : in  std_logic;
            s_axis_phase_tvalid     : in  std_logic;
            s_axis_phase_tdata      : in  std_logic_vector(23 downto 0);
            s_axis_cartesian_tvalid : in  std_logic;
            s_axis_cartesian_tlast  : in  std_logic;
            s_axis_cartesian_tdata  : in  std_logic_vector(47 downto 0);
            m_axis_dout_tvalid      : out std_logic;
            m_axis_dout_tlast       : out std_logic;
            m_axis_dout_tdata       : out std_logic_vector(47 downto 0)
        );
    end component;

begin

    -- Configuration
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_config_tvalid <= '0';
                config_done     <= '0';
            else
                if config_done = '0' then
                    s_config_tvalid <= '1';
                    if s_config_tready = '1' then
                        s_config_tvalid <= '0';
                        config_done     <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- FSM: collect frame, stream to CORDIC, wait for IFFT
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state       <= IDLE;
                write_index <= 0;
                cordic_idx  <= 0;
                s_ready     <= '1';
                m_axis.valid <= '0';
                m_axis.last  <= '0';

                -- CORDIC input defaults
                cordic_phase_valid <= '0';
                cordic_mag_valid   <= '0';
                cordic_in_tlast    <= '0';
                cordic_phase_data  <= (others => '0');
                cordic_mag_data    <= (others => '0');

            else
                -- Defaults
                s_ready <= '0';
                m_axis.valid <= '0';

                -- Output handshake: pass valid ifft output downstream if ready
                if ifft_out_valid = '1' then
                    if m_ready = '1' then
                        m_axis.data  <= ifft_audio_out;
                        m_axis.valid <= '1';
                        m_axis.last  <= ifft_out_last;
                        ifft_out_valid <= '0';  -- valid output has been captured and used
                    else
                        m_axis.valid <= '0';
                    end if;
                end if;

                case state is

                    -- IDLE: wait for first polar sample
                    when IDLE =>
                        s_ready <= '1';
                        write_index <= 0;
                        if s_axis.valid = '1' then
                            phase_buf(write_index) <= s_axis.phase;
                            mag_buf(write_index)   <= s_axis.magnitude;
                            write_index <= write_index + 1;
                            state <= COLLECT;
                        end if;

                    -- COLLECT: gather 1024 polar samples
                    when COLLECT =>
                        s_ready <= '1';
                        if s_axis.valid = '1' then
                            phase_buf(write_index) <= s_axis.phase;
                            mag_buf(write_index)   <= s_axis.magnitude;
                            if s_axis.last = '1' then
                                -- Full frame collected: start CORDIC streaming
                                cordic_idx <= 0;
                                state <= STREAM_CORDIC;
                                s_ready <= '0';  -- stop accepting during processing
                            else
                                write_index <= write_index + 1;
                            end if;
                        end if;

                    -- STREAM_CORDIC: feed frame to CORDIC one sample per cycle
                    when STREAM_CORDIC =>
                        s_ready <= '0';

                        -- Present current sample to CORDIC
                        cordic_phase_valid <= '1';
                        cordic_mag_valid   <= '1';
                        cordic_phase_data  <= std_logic_vector(phase_buf(cordic_idx));
                        cordic_mag_data    <= s_data_imaginary & std_logic_vector(mag_buf(cordic_idx));
                        cordic_in_tlast    <= '1' when cordic_idx = 1023 else '0';

                        -- Advance to next sample
                        if cordic_idx = 1023 then
                            -- Last sample sent: wait for IFFT to finish
                            cordic_phase_valid <= '0';
                            cordic_mag_valid   <= '0';
                            state <= WAIT_IFFT;
                        else
                            cordic_idx <= cordic_idx + 1;
                        end if;

                    -- WAIT_IFFT: wait for IFFT to output all samples
                    when WAIT_IFFT =>
                        s_ready <= '0';
                        -- IFFT outputs are handled by the hanning window process
                        -- Set state back to IDLE once last sample has been output.
                        if ifft_out_valid = '1' and ifft_out_last = '1' and m_ready = '1' then
                            state <= IDLE;
                        end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- CORDIC Instantiation (polar to rectangular)
    polar_to_rectangular : cordic_1
    port map(
        aclk                    => clk,
        aresetn                 => (not rst),
        s_axis_phase_tvalid     => cordic_phase_valid,
        s_axis_phase_tdata      => std_logic_vector(phase_buf(cordic_idx)),
        s_axis_cartesian_tvalid => cordic_mag_valid,
        s_axis_cartesian_tlast  => cordic_out_tlast,
        s_axis_cartesian_tdata  => s_data_imaginary & std_logic_vector(mag_buf(cordic_idx)),
        m_axis_dout_tvalid      => cordic_out_tvalid,
        m_axis_dout_tlast       => cordic_out_tlast,
        m_axis_dout_tdata       => cordic_out_tdata
    );

    -- Inverse FFT component instantiation
    inverse_fft : xfft_0
    port map(
        aclk                 => clk,
        aresetn              => (not rst),
        s_axis_config_tdata  => s_iconfig_tdata,
        s_axis_config_tvalid => s_config_tvalid,
        s_axis_config_tready => s_config_tready,
        s_axis_data_tdata    => cordic_out_tdata,
        s_axis_data_tvalid   => cordic_out_tvalid,
        s_axis_data_tready   => open,
        s_axis_data_tlast    => cordic_out_tlast,
        m_axis_data_tdata    => ifft_data_tdata,
        m_axis_data_tuser    => open,
        m_axis_data_tvalid   => ifft_data_tvalid,
        m_axis_data_tlast    => ifft_data_tlast
    );

    -- Apply Hanning Window on the IFFT output
    process (clk)
        variable multiply_result : signed(47 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ifft_sample_index <= 0;
                ifft_audio_out    <= (others => '0');
                ifft_out_valid    <= '0';
                ifft_out_last     <= '0';
            else
                ifft_out_valid <= '0';
                if ifft_data_tvalid = '1' then
                    multiply_result := hanning_rom(ifft_sample_index) * signed(ifft_data_tdata(23 downto 0));
                    ifft_audio_out <= multiply_result(46 downto 23);  -- truncate, can add rounding later
                    ifft_out_valid <= '1';
                    if ifft_data_tlast = '1' or ifft_sample_index = 1023 then
                        ifft_sample_index <= 0;
                        ifft_out_last <= '1';
                    else
                        ifft_sample_index <= ifft_sample_index + 1;
                        ifft_out_last <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture behavioral;