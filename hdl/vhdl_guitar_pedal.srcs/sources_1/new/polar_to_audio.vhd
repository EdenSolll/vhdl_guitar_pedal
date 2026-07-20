library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;

entity polar_to_audio is
    port (
        clk   : in std_logic;
        rst   : in std_logic;

        -- Input: Streaming polar (phase + magnitude)
        s_axis   : in  t_polar_forward;
        s_ready  : out std_logic;

        -- Output: Streaming audio
        m_axis   : out t_axis_forward;
        m_ready  : in  std_logic
    );
end entity polar_to_audio;

architecture structural of polar_to_audio is
    -- Constants
    -- Inverse FFT configuration 
    constant INV_FFT_CONFIG : std_logic_vector(23 downto 0) := "000000000000000000000000";
    constant DATA_IMAGINARY : std_logic_vector(23 downto 0) := (others => '0');

    -- Signals
    -- IFFT output / CORDIC input
    signal fft_tdata  : std_logic_vector(47 downto 0);
    signal fft_tvalid : std_logic;
    signal fft_tlast  : std_logic;
    
    signal cordic_tdata  : std_logic_vector(47 downto 0);
    signal cordic_tvalid : std_logic;
    signal cordic_tlast  : std_logic;

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

    -- Polar to Rectangular CORDIC (statically configured)
    pol2rect_inst : cordic_1
    port map(
        aclk                    => clk,
        aresetn                 => (not rst),
        s_axis_phase_tvalid     => s_axis.valid,
        s_axis_phase_tdata      => std_logic_vector(s_axis.phase),
        s_axis_cartesian_tvalid => s_axis.valid,
        s_axis_cartesian_tlast  => s_axis.last,
        s_axis_cartesian_tdata  => DATA_IMAGINARY & std_logic_vector(s_axis.magnitude),
        m_axis_dout_tvalid      => cordic_tvalid,
        m_axis_dout_tlast       => cordic_tlast,
        m_axis_dout_tdata       => cordic_tdata
    );

    -- Inverse FFT (static configuration for inverse FFT)
    inv_fft_inst : xfft_0
    port map(
        aclk                 => clk,
        aresetn              => (not rst),
        s_axis_config_tdata  => INV_FFT_CONFIG,
        s_axis_config_tvalid => '1',
        s_axis_config_tready => open,
        s_axis_data_tdata    => cordic_tdata,
        s_axis_data_tvalid   => cordic_tvalid,
        s_axis_data_tready   => s_ready,
        s_axis_data_tlast    => cordic_tlast,
        m_axis_data_tdata    => fft_tdata,
        m_axis_data_tuser    => open,
        m_axis_data_tvalid   => fft_tvalid,
        m_axis_data_tlast    => fft_tlast
    );

    -- Output audio
    m_axis.data  <= signed(fft_tdata(23 downto 0));
    m_axis.valid <= fft_tvalid;
    m_axis.last  <= fft_tlast;

end architecture structural;