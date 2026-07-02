library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;

entity audio_to_polar is
    port (
        clk   : in std_logic;
        rst   : in std_logic;

        -- Input: Streaming audio
        s_axis   : in  t_axis_forward;   -- data, valid, last
        s_ready  : out std_logic;        -- Ready to accept

        -- Output: Streaming polar (phase + magnitude)
        m_axis   : out t_polar_forward;
        m_ready  : in  std_logic         -- Ready to output
    );
end entity audio_to_polar;

architecture structural of audio_to_polar is

    -- Constants
    -- Forward FFT configuration 
    constant FWD_FFT_CONFIG : std_logic_vector(23 downto 0) := "000000000000000000000001";
    constant DATA_IMAGINARY : std_logic_vector(23 downto 0) := (others => '0');

    -- Signals
    -- FFT output / CORDIC input
    signal fft_tdata  : std_logic_vector(47 downto 0);
    signal fft_tvalid : std_logic;
    signal fft_tready : std_logic;
    signal fft_tlast  : std_logic;

    -- CORDIC output 
    signal cordic_tdata  : std_logic_vector(47 downto 0);
    signal cordic_tvalid : std_logic;
    signal cordic_tlast  : std_logic;

    -- Component declarations
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

    component cordic_0
        port (
            aclk                    : in  std_logic;
            aresetn                 : in  std_logic;
            s_axis_cartesian_tvalid : in  std_logic;
            s_axis_cartesian_tlast  : in  std_logic;
            s_axis_cartesian_tdata  : in  std_logic_vector(47 downto 0);
            m_axis_dout_tvalid      : out std_logic;
            m_axis_dout_tlast       : out std_logic;
            m_axis_dout_tdata       : out std_logic_vector(47 downto 0)
        );
    end component;

begin

    -- Forward FFT (static config)
    fwd_fft_inst : xfft_0
    port map(
        aclk                 => clk,
        aresetn              => (not rst),
        s_axis_config_tdata  => FWD_FFT_CONFIG, -- Always forward transform
        s_axis_config_tvalid => '1',      -- Always valid
        s_axis_config_tready => open,     
        s_axis_data_tdata    => DATA_IMAGINARY & std_logic_vector(s_axis.data),
        s_axis_data_tvalid   => s_axis.valid,
        s_axis_data_tready   => s_ready,
        s_axis_data_tlast    => s_axis.last,
        m_axis_data_tdata    => fft_tdata,
        m_axis_data_tuser    => open,
        m_axis_data_tvalid   => fft_tvalid,
        m_axis_data_tlast    => fft_tlast
    );

    -- Rectangular to Polar CORDIC (statically configured)
    rect2pol_inst : cordic_0
    port map(
        aclk                    => clk,
        aresetn                 => (not rst),
        s_axis_cartesian_tvalid => fft_tvalid,
        s_axis_cartesian_tlast  => fft_tlast,
        s_axis_cartesian_tdata  => fft_tdata,
        m_axis_dout_tvalid      => cordic_tvalid,
        m_axis_dout_tlast       => cordic_tlast,
        m_axis_dout_tdata       => cordic_tdata
    );

    -- Split CORDIC outputs into magnitude and phase 
    m_axis.phase     <= signed(cordic_tdata(47 downto 24));
    m_axis.magnitude <= signed(cordic_tdata(23 downto 0));
    m_axis.valid     <= cordic_tvalid;
    m_axis.last      <= cordic_tlast;

end architecture structural;