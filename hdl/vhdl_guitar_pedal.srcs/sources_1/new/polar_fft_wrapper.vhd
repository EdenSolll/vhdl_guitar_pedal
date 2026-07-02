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

    -- All your existing signals (keep them)
    signal input_ram          : t_audio_frame := (others => (others => '0'));
    signal write_ptr          : unsigned(9 downto 0) := (others => '0');
    signal read_offset        : unsigned(9 downto 0) := (others => '0');
    signal mult_pipe          : signed(47 downto 0) := (others => '0');
    signal valid_pipe         : std_logic := '0';
    signal last_pipe          : std_logic := '0';
    signal magnitude_ram      : t_mag_frame := (others => (others => '0'));
    signal phase_ram          : t_phase_frame := (others => (others => '0'));
    signal config_done        : std_logic := '0';

    -- Pipeline signals
    signal pipe_s_axis        : t_axis_forward;
    signal pipe_s_ready       : std_logic;
    signal pipe_m_axis        : t_polar_forward;
    signal pipe_m_ready       : std_logic;

    -- State machine type 
    type state_t is (IDLE, COLLECT, STREAM_BURST, WAIT_READY);
    signal current_state : state_t := IDLE;

    -- Component declaration for the pipeline
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

begin

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
                write_ptr     <= (others => '0');
                read_offset   <= (others => '0');
                current_state <= IDLE;
                s_ready       <= '1';
                fft_ready     <= '0';
                mult_pipe     <= (others => '0');
                valid_pipe    <= '0';
                last_pipe     <= '0';
                pipe_s_axis.valid <= '0';
                pipe_s_axis.last  <= '0';
            else
                s_ready   <= '0';
                fft_ready <= '0';

                case current_state is

                    when IDLE =>
                        s_ready <= '1';
                        if s_axis.valid = '1' and s_ready = '1' then
                            input_ram(to_integer(write_ptr)) <= s_axis.data;
                            write_ptr <= write_ptr + 1;
                            current_state <= COLLECT;
                        end if;

                    when COLLECT =>
                        s_ready <= '1';
                        if s_axis.valid = '1' then
                            input_ram(to_integer(write_ptr)) <= s_axis.data;
                            if s_axis.last = '1' then
                                write_ptr     <= (others => '0');
                                read_offset   <= (others => '0');
                                current_state <= STREAM_BURST;
                                s_ready       <= '0';
                            else
                                write_ptr <= write_ptr + 1;
                            end if;
                        end if;

                    when STREAM_BURST =>
                        s_ready <= '0';
                        -- Compute Hanning-windowed sample
                        raw_sample      := input_ram(to_integer(read_offset));
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
                            end if;
                        end if;

                    when WAIT_READY =>
                        s_ready       <= '0';
                        pipe_s_axis.valid <= '0';
                        pipe_s_axis.last  <= '0';

                        if fft_ready = '1' then
                            current_state <= IDLE;
                        end if;

                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;

    -- Capture the pipeline output (phase/magnitude)
    process (clk)
        variable write_addr : integer range 0 to 1023 := 0;
    begin
        if rising_edge(clk) then
            fft_ready <= '0';
            if rst = '1' then
                write_addr := 0;
                phase_ram     <= (others => (others => '0'));
                magnitude_ram <= (others => (others => '0'));
            else
                if pipe_m_axis.valid = '1' then
                    phase_ram(write_addr)     <= pipe_m_axis.phase;
                    magnitude_ram(write_addr) <= pipe_m_axis.magnitude;
                    if pipe_m_axis.last = '1' then
                        write_addr := 0;
                        fft_ready <= '1';
                    else
                        write_addr := write_addr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Outputs
    phase_out     <= phase_ram;
    magnitude_out <= magnitude_ram;

end architecture behavioral;