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

	component xfft_0
		port
		(
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
			m_axis_status_tdata        : out std_logic_vector(7 downto 0);
			m_axis_status_tvalid       : out std_logic;
			event_frame_started        : out std_logic;
			event_tlast_unexpected     : out std_logic;
			event_tlast_missing        : out std_logic;
			event_data_in_channel_halt : out std_logic
		);
	end component;

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

	signal l_data_rx            : std_logic_vector(23 downto 0);
	signal r_data_rx            : std_logic_vector(23 downto 0);
	signal l_data_tx            : std_logic_vector(23 downto 0);
	signal r_data_tx            : std_logic_vector(23 downto 0);

	signal data_sum             : unsigned(25 downto 0);
	signal r_data_avg           : std_logic_vector(23 downto 0);

	-- FFT configuration constants

	constant s_config_tdata     : std_logic_vector(7 downto 0)  := "00000001";                 -- forward transform selected, optional fields not needed
	constant s_iconfig_tdata    : std_logic_vector(7 downto 0)  := "00000000";                 -- inverse transform selected, optional fields not needed
	constant s_data_imaginary   : std_logic_vector(23 downto 0) := "000000000000000000000000"; -- all input data is real

	-- Foward FFT signals

	signal s_tlast              : std_logic;                                                   -- intentionally unused signal
	signal master_clk           : std_logic;
	signal serial_clk           : std_logic;
	signal word_select          : std_logic;
	signal s_config_tvalid      : std_logic;
	signal s_config_tready      : std_logic;
	signal s_data_tvalid        : std_logic;
	signal s_data_tready        : std_logic;
	signal m_raw_data_tdata     : std_logic_vector(47 downto 0);
	signal m_valid_data_tdata   : std_logic_vector(47 downto 0);
  signal m_data_tuser         : std_logic_vector(23 downto 0);
	signal m_data_tvalid        : std_logic;
	signal m_data_tready        : std_logic;
	signal m_status_tvalid      : std_logic;
	signal m_raw_status_tdata   : std_logic_vector(7 downto 0);
	signal m_valid_status_tdata : std_logic_vector(7 downto 0);
  signal m_axis_data_tlast    : std_logic;

  signal word_delay           : std_logic;

  signal freqs : freq_buffer := (others => (others => '0'));

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
      mclk_sclk_ratio => 4, sclk_ws_ratio => 64, d_width => 24
	)
	port map(
      reset_n => rst, mclk => master_clk, sclk => serial_clk, ws => word_select, sd_tx => sd_tx, sd_rx => sd_rx,
      l_data_tx => l_data_tx, r_data_tx => r_data_tx, l_data_rx => l_data_rx, r_data_rx => r_data_rx);

	forward_fft : xfft_0
	port map (
      aclk                 => CLK100MHZ,
      aresetn              => (not rst),
      s_axis_config_tdata  => s_config_tdata,
      s_axis_config_tvalid => s_config_tvalid,
      s_axis_config_tready => s_config_tready,
      s_axis_data_tdata    => s_data_imaginary & r_data_avg,
      s_axis_data_tvalid   => s_data_tvalid,
      s_axis_data_tready   => s_data_tready,
      s_axis_data_tlast    => s_tlast, -- ignore signal
      m_axis_data_tdata    => m_raw_data_tdata,
      m_axis_data_tuser    => m_data_tuser,
      m_axis_data_tvalid   => m_data_tvalid,
      m_axis_data_tlast    => m_axis_data_tlast,
      m_axis_status_tdata  => m_raw_status_tdata,
      m_axis_status_tvalid => m_status_tvalid
      --	event_frame_started        => event_frame_started,
      -- 	event_tlast_unexpected     => event_tlast_unexpected,
      -- 	event_tlast_missing        => event_tlast_missing,
      -- 	event_data_in_channel_halt => event_data_in_channel_halt
	);

	process(CLK100MHZ)
	begin
    if rising_edge(CLK100MHZ) then
      word_delay <= word_select;
      if (word_select = '1' and word_delay = '0') then
        if s_config_tready = '1' then
          s_config_tvalid <= '1';
        end if;
      else
        s_config_tvalid <= '0';
      end if;
    end if;
  end process;

	process(CLK100MHZ)
	begin
    if rising_edge(CLK100MHZ) then
      word_delay <= word_select;
      if (word_select = '1' and word_delay = '0') then
        if s_data_tready = '1' then
          s_data_tvalid <= '1';
        end if;
      else
        s_data_tvalid <= '0';
      end if;
    end if;
	end process;

	m_valid_status_tdata <= m_raw_status_tdata when m_status_tvalid = '1';

	m_valid_data_tdata <= m_raw_data_tdata when m_data_tvalid = '1';

end behavioral;
