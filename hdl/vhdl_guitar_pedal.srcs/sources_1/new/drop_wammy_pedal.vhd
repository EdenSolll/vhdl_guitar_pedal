library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.audio_stream_pkg.all;

entity drop_wammy_pedal is
    port (
        clk   : in std_logic;
        rst   : in std_logic; 
        s_axis  : in t_axis_forward; 
        s_ready : out std_logic;
        m_axis  : out t_axis_forward;
        m_ready : in std_logic;
        pitch_control   : in signed(15 downto 0);
        inverse_pitch   : in unsigned(17 downto 0); 
        mode : in std_logic;    -- '0' = time domain, '1' = freq domain 
        bypass : in std_logic   -- '0' = pitch shift, '1' = bypass (dry pass-through)
    );
end drop_wammy_pedal;

architecture structural of drop_wammy_pedal is

    -- Time-Domain Signals
    signal time_out      : t_axis_forward;
    signal time_ready    : std_logic;

    -- Frequency-Domain Signals
    signal fft_phase_frame   : t_phase_frame;
    signal fft_mag_frame     : t_mag_frame;
    signal fft_frame_ready   : std_logic;
    signal polar_stream      : t_polar_forward;   -- freq_pitch_shifter to IFFT wrapper
    signal polar_stream_ready : std_logic;        -- IFFT wrapper to pitch shifter
    signal freq_out          : t_axis_forward;    -- IFFT wrapper to output mux
    signal freq_ready        : std_logic;         -- IFFT wrapper back to upstream
    signal polar_fft_ready   : std_logic;         -- polar_fft_wrapper to upstream

    -- Component declarations
    component time_pitch_shifter is
        port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            s_axis        : in  t_axis_forward;
            s_ready       : out std_logic;
            m_axis        : out t_axis_forward;
            m_ready       : in  std_logic;
            pitch_control : in  signed(15 downto 0)
        );
    end component;

    component polar_fft_wrapper is
        port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            s_axis        : in  t_axis_forward;
            s_ready       : out std_logic;
            phase_out     : out t_phase_frame;
            magnitude_out : out t_mag_frame;
            fft_ready     : out std_logic
        );
    end component;
    
    component freq_pitch_shifter is
        port (
            clk                 : in  std_logic;
            rst                 : in  std_logic;
            phase_in            : in  t_phase_frame;
            magnitude_in        : in  t_mag_frame;
            input_valid         : in  std_logic;
            m_axis              : out t_polar_forward;
            m_ready             : in  std_logic;
            pitch_control       : in  signed(15 downto 0);
            inverse_pitch_shift : in  unsigned(17 downto 0)
        );
    end component;

    component rectangular_ifft_wrapper is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            s_axis  : in  t_polar_forward;
            s_ready : out std_logic;
            m_axis  : out t_axis_forward;
            m_ready : in  std_logic
        );
    end component;

begin

    -- Time domain pitch shifter instantiation 
    time_inst : time_pitch_shifter
    port map (
        clk           => clk,
        rst           => rst,
        s_axis        => s_axis,
        s_ready       => time_ready,
        m_axis        => time_out,
        m_ready       => m_ready,
        pitch_control => pitch_control
    );

    -- Freqency Domain pitch shifter effect chain
    -- FFT + Rect-to-Polar 
    polar_fft_inst : polar_fft_wrapper
    port map (
        clk           => clk,
        rst           => rst,
        s_axis        => s_axis,           
        s_ready       => polar_fft_ready,              
        phase_out     => fft_phase_frame,
        magnitude_out => fft_mag_frame,
        fft_ready     => fft_frame_ready
    );

    -- Freqency Pitch Shift (Phase Vocoder)
    freq_pitch_inst : freq_pitch_shifter
    port map (
        clk                 => clk,
        rst                 => rst,
        phase_in            => fft_phase_frame,
        magnitude_in        => fft_mag_frame,
        input_valid         => fft_frame_ready,
        m_axis              => polar_stream,
        m_ready             => polar_stream_ready,         
        pitch_control       => pitch_control,
        inverse_pitch_shift => inverse_pitch
    );

    -- Step 3: Polar-to-Rect + IFFT
    rectangular_ifft_inst : rectangular_ifft_wrapper
    port map (
        clk     => clk,
        rst     => rst,
        s_axis  => polar_stream,
        s_ready => polar_stream_ready,
        m_axis  => freq_out,
        m_ready => m_ready                      
    );

    s_ready <= time_ready when mode = '0' else polar_fft_ready;

    -- Output MUX process 
    process(clk)
    begin
        if rising_edge(clk) then
            if bypass = '1' then
                -- Bypass: pass through
                m_axis.data  <= s_axis.data;
                m_axis.valid <= s_axis.valid;
                m_axis.last  <= s_axis.last;
            else
                -- Effect Select: time or freq output
                if mode = '0' then
                    m_axis.data  <= time_out.data;
                    m_axis.valid <= time_out.valid;
                    m_axis.last  <= time_out.last;
                elsif mode = '1' then
                    m_axis.data  <= freq_out.data;
                    m_axis.valid <= freq_out.valid;
                    m_axis.last  <= freq_out.last;
                end if;
            end if;
        end if;
    end process;
end structural;