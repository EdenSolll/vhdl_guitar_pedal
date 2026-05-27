library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.globals.all;
use work.all;

entity guitar_pedal is
	port
	(
		CLK100MHZ : in  std_logic;
		rst       : in  std_logic;
		sd_rx     : in  std_logic;
		sd_tx     : out std_logic
	);
end guitar_pedal;

architecture behavioral of guitar_pedal is

  signal master_clk           : std_logic;
  signal serial_clk           : std_logic;

  signal word_select          : std_logic;

	signal l_data_rx            : std_logic_vector(23 downto 0);
	signal r_data_rx            : std_logic_vector(23 downto 0);
	signal l_data_tx            : std_logic_vector(23 downto 0);
	signal r_data_tx            : std_logic_vector(23 downto 0);

	signal data_sum             : unsigned(25 downto 0);
	signal r_data_avg           : std_logic_vector(23 downto 0);

	component i2s_transceiver is
		generic
		(
			mclk_sclk_ratio : integer := 4;
			sclk_ws_ratio   : integer := 64;
			d_width         : integer := 24);
		port
		(
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
		port
		(
			CLK_IN1  : in  std_logic;
			reset    : in  std_logic;
			clk_out1 : out std_logic
		);
	end component;

begin

	r_data_avg <= std_logic_vector(resize(shift_right(resize(unsigned(l_data_rx), 25) + resize(unsigned(r_data_rx), 25), 1), 24)); -- averages the left and right channels

	m_clk : clk_wiz_0
	port map (
     clk_in1 => CLK100MHZ,
     reset => rst,
     clk_out1 => master_clk
           );

	i2s_transceiver_0 : i2s_transceiver
	generic map(
      mclk_sclk_ratio => 4,
      sclk_ws_ratio => 64,
      d_width => 24
	)
	port map(
      reset_n => rst,
      mclk => master_clk,
      sclk => serial_clk,
      ws => word_select,
      sd_tx => sd_tx,
      sd_rx => sd_rx,
      l_data_tx => l_data_tx,
      r_data_tx => r_data_tx,
      l_data_rx => l_data_rx,
      r_data_rx => r_data_rx
    );

end behavioral;
