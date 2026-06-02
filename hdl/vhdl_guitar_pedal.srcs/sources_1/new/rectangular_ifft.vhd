library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;
use work.globals.all;
use work.all;

entity rectangular_ifft is
	generic (
		fft_len : integer := 1024;
		n       : integer := d_width;
		m       : integer := 24
	);
	port (
		clk         : in std_logic;
		rst         : in std_logic;
		input_valid : in std_logic;
		input_last  : in std_logic;
		input_phase_stream : in std_logic_vector(23 downto 0);
		input_magnitude_stream : in std_logic_vector(23 downto 0);
		real_audio_out : out std_logic_vector(23 downto 0);
		output_valid : out std_logic;
		output_last : out std_logic
	);
end entity rectangular_ifft;

architecture behavioral of rectangular_ifft is

    constant s_iconfig_tdata : std_logic_vector(7 downto 0) := "00000000"; 
    constant s_data_imaginary      : std_logic_vector(23 downto 0) := "000000000000000000000000"; -- all input data is real

    -- IFFT Configuration Signals
    signal s_config_tvalid   : std_logic := '0';
    signal s_config_tready   : std_logic;
    signal config_done       : std_logic := '0';

    -- CORDIC to IFFT connection signals
    signal cordic_dout_tvalid : std_logic;
    signal cordic_dout_tlast  : std_logic;
    signal cordic_dout_tdata  : std_logic_vector(47 downto 0);

    -- IFFT Output signals
    signal ifft_data_tdata    : std_logic_vector(47 downto 0);
    signal ifft_data_tvalid   : std_logic;
    signal ifft_data_tlast    : std_logic;

	component xfft_0
		port (
			aclk                       : in  std_logic;
			aresetn                    : in  std_logic;
			s_axis_config_tdata        : in  std_logic_vector(7 downto 0);
			s_axis_config_tvalid       : in  std_logic;
			s_axis_config_tready       : out std_logic;
			s_axis_data_tdata          : in  std_logic_vector(47 downto 0);
			s_axis_data_tvalid         : in  std_logic;
			s_axis_data_tready         : out std_logic;
			s_axis_data_tlast          : in  std_logic;
			m_axis_data_tdata          : out std_logic_vector(47 downto 0);
			m_axis_data_tuser          : out std_logic_vector(23 downto 0);
			m_axis_data_tvalid         : out std_logic;
			m_axis_data_tlast          : out std_logic;
		);
	end component;

	COMPONENT cordic_1
        PORT (
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            s_axis_phase_tvalid : IN STD_LOGIC;
            s_axis_phase_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            s_axis_cartesian_tvalid : IN STD_LOGIC;
            s_axis_cartesian_tlast : IN STD_LOGIC;
            s_axis_cartesian_tdata : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
            m_axis_dout_tvalid : OUT STD_LOGIC;
            m_axis_dout_tlast : OUT STD_LOGIC;
            m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
          );
        END COMPONENT;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_config_tvalid <= '0';
                config_done <= '0';
            else
                if config_done = '0' then
                    s_config_tvalid <= '1';
                    if s_config_tready = '1' then
                        s_config_tvalid <= '0';
                        config_done <= '1'; -- Config complete, stay here forever
                    end if;
                end if;
            end if;
        end if;
    end process;

    polar_to_rectangular : cordic_1
    port map(
        aclk                    => clk,
        aresetn                 => (not rst),
        s_axis_phase_tvalid     => input_valid,
        s_axis_phase_tdata      => input_phase_stream,
        s_axis_cartesian_tvalid => input_valid,
        s_axis_cartesian_tlast  => input_last,
        s_axis_cartesian_tdata  => input_magnitude_stream,
        m_axis_dout_tvalid      => cordic_dout_tvalid,
        m_axis_dout_tlast       => cordic_dout_tlast,
        m_axis_dout_tdata       => cordic_dout_tdata
    );

	inverse_fft : xfft_0
	port map(
		aclk                 => clk,
		aresetn              => (not rst),
		s_axis_config_tdata  => s_iconfig_tdata,
		s_axis_config_tvalid => s_config_tvalid,
		s_axis_config_tready => s_config_tready,
   		s_axis_data_tdata    => cordic_dout_tdata,
		s_axis_data_tvalid   => cordic_dout_tvalid,
		s_axis_data_tready   => open,
		s_axis_data_tlast    => cordic_dout_tlast, 
   		m_axis_data_tdata    => ifft_data_tdata,
		m_axis_data_tuser    => open,
		m_axis_data_tvalid   => ifft_data_tvalid,
		m_axis_data_tlast    => ifft_data_tlast
	);


	real_audio_out <= ifft_data_tdata(22 downto 0) & '0';
    
    output_valid   <= ifft_data_tvalid;
    output_last    <= ifft_data_tlast;

end architecture behavioral;
