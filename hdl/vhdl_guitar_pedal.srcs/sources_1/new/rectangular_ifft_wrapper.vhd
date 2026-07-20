library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;
use work.hanning_window_rom.all;

entity rectangular_ifft_wrapper is
    generic (
        fft_len : integer := C_FFT_LEN;
        n       : integer := C_AUDIO_WIDTH
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
end entity rectangular_ifft_wrapper;

architecture behavioral of rectangular_ifft_wrapper is

    -- polar buffers 
    signal phase_buf     : t_phase_frame := (others => (others => '0'));
    
    attribute ram_style : string;
    attribute ram_style of phase_buf : signal is "block";

    signal mag_buf       : t_mag_frame   := (others => (others => '0'));

    attribute ram_style of mag_buf : signal is "block";

    -- index signals
    signal write_index   : integer range 0 to 1023 := 0;
    signal cordic_idx    : integer range 0 to 1023 := 0;

    -- Hanning window signals
    signal ifft_sample_index : integer range 0 to 1023 := 0;
    signal ifft_audio_out    : t_audio_sample := (others => '0');
    signal ifft_out_valid    : std_logic := '0';
    signal ifft_out_last     : std_logic := '0';

    -- Pipleline signals 
    signal pipe_s_axis        : t_polar_forward;
    signal pipe_s_ready       : std_logic;
    signal pipe_m_axis        : t_axis_forward;
    signal pipe_m_ready       : std_logic;

    -- State machine 
    type state_t is (IDLE, COLLECT, STREAM_CORDIC, WAIT_IFFT);
    signal state : state_t := IDLE;

    -- Component declaration for the pipeline
    component polar_to_audio
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            s_axis   : in  t_polar_forward;
            s_ready  : out std_logic;
            m_axis   : out t_axis_forward;
            m_ready  : in  std_logic
        );
    end component;

begin

    -- Instantiate the polar to audio entity 
    polar_to_audio_inst : polar_to_audio
    port map(
        clk     => clk,
        rst     => rst,
        s_axis  => pipe_s_axis,
        s_ready => pipe_s_ready,
        m_axis  => pipe_m_axis,
        m_ready => m_ready  
    );

    -- FSM
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
                pipe_s_axis.valid <= '0';
                pipe_s_axis.last  <= '0';
            else
                s_ready <= '0';
                m_axis.valid <= '0';

                -- Pass pipeline output directly to m_axis
                if pipe_m_axis.valid = '1' then
                    m_axis.data  <= pipe_m_axis.data;
                    m_axis.valid <= pipe_m_axis.valid;
                    m_axis.last  <= pipe_m_axis.last;
                end if;

                case state is

                    when IDLE =>
                        s_ready <= '1';
                        write_index <= 0;
                        if s_axis.valid = '1' then
                            phase_buf(write_index) <= s_axis.phase;
                            mag_buf(write_index)   <= s_axis.magnitude;
                            write_index <= write_index + 1;
                            state <= COLLECT;
                        end if;

                    when COLLECT =>
                        s_ready <= '1';
                        if s_axis.valid = '1' then
                            phase_buf(write_index) <= s_axis.phase;
                            mag_buf(write_index)   <= s_axis.magnitude;
                            if s_axis.last = '1' then
                                cordic_idx <= 0;
                                state <= STREAM_CORDIC;
                                s_ready <= '0';
                            else
                                write_index <= write_index + 1;
                            end if;
                        end if;

                    when STREAM_CORDIC =>
                        s_ready <= '0';
                        -- Drive the pipeline's input
                        pipe_s_axis.phase     <= phase_buf(cordic_idx);
                        pipe_s_axis.magnitude <= mag_buf(cordic_idx);
                        pipe_s_axis.valid     <= '1';
                        pipe_s_axis.last      <= '1' when cordic_idx = 1023 else '0';

                        if pipe_s_ready = '1' then
                            if cordic_idx = 1023 then
                                pipe_s_axis.valid <= '0';
                                state <= WAIT_IFFT;
                            else
                                cordic_idx <= cordic_idx + 1;
                            end if;
                        end if;

                    when WAIT_IFFT =>
                        s_ready <= '0';
                        pipe_s_axis.valid <= '0';
                        pipe_s_axis.last  <= '0';
                        -- Wait for the pipeline to finish outputting
                        if pipe_m_axis.valid = '1' and pipe_m_axis.last = '1' then
                            state <= IDLE;
                        end if;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture behavioral;
