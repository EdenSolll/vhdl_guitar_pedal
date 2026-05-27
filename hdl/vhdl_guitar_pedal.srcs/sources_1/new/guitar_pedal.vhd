library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.globals.all;
use work.all;

entity guitar_pedal is
	port (
		CLK100MHZ : in  std_logic;
		rst       : in  std_logic;
		sd_rx     : in  std_logic;
		sd_tx     : out std_logic
	);
end guitar_pedal;

architecture structural of guitar_pedal is

	signal master_clk  : std_logic;
	signal serial_clk  : std_logic;

	signal word_select : std_logic;

	signal l_data_rx   : std_logic_vector(d_width-1 downto 0);
	signal r_data_rx   : std_logic_vector(d_width-1 downto 0);
	signal l_data_tx   : std_logic_vector(d_width-1 downto 0);
	signal r_data_tx   : std_logic_vector(d_width-1 downto 0);

	signal data_sum    : unsigned(d_width downto 0);
	signal r_data_avg  : std_logic_vector(d_width-1 downto 0);
	signal q1_data : std_logic_vector(d_width-1 downto 0);

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

	component polar_fft is
		generic (
			fft_len : integer := 1024;
			n       : integer := d_width;
			m       : integer := 24
		);
		port (
			clk         : in std_logic;
			rst         : in std_logic;
			word_select : in std_logic;
			real_data   : in std_logic_vector(23 downto 0)
		);
	end component;

begin

	r_data_avg <= std_logic_vector(resize(shift_right(resize(unsigned(l_data_rx), 25) + resize(unsigned(r_data_rx), 25), 1), 24)); -- averages the left and right channels

	q1_data <= r_data_avg(d_width-1) & (((not r_data_avg) + '1') >> 1);

	m_clk : clk_wiz_0
	port map(
		clk_in1  => CLK100MHZ,
		reset    => rst,
		clk_out1 => master_clk
	);

	i2s_transceiver_0 : i2s_transceiver
	generic map(
		mclk_sclk_ratio => 4,
		sclk_ws_ratio   => 64,
		d_width         => 24
	)
	port map(
		reset_n   => rst,
		mclk      => master_clk,
		sclk      => serial_clk,
		ws        => word_select,
		sd_tx     => sd_tx,
		sd_rx     => sd_rx,
		l_data_tx => l_data_tx,
		r_data_tx => r_data_tx,
		l_data_rx => l_data_rx,
		r_data_rx => r_data_rx
	);

	polar_fft_0 : polar_fft
	generic map(
		fft_len => 1024,
		n       => 24,
		m       => 24
	)
	port map(
		clk         => CLK100MHZ,
		rst         => rst,
		word_select => word_select,
		real_data   => r_data_avg
	);

end structural;
