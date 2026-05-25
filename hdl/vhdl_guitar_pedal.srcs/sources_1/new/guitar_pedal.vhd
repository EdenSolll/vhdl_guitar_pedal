Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
use IEEE.NUMERIC_STD.ALL;
Use work.All;

Entity guitar_pedal Is
  port (
  CLK100MHZ : in std_logic;
  rst       : in std_logic;
  sd_rx     : in std_logic;
  sd_tx     : out std_logic
       );
End guitar_pedal;

Architecture Behavioral Of guitar_pedal Is

	Component xfft_0
		Port
		(
			aclk                       : In  Std_logic;
			aresetn                    : In  Std_logic;
			s_axis_config_tdata        : In  Std_logic_vector(7 Downto 0);
			s_axis_config_tvalid       : In  Std_logic;
			s_axis_config_tready       : Out Std_logic;
			s_axis_data_tdata          : In  Std_logic_vector(47 Downto 0);
			s_axis_data_tvalid         : In  Std_logic;
			s_axis_data_tready         : Out Std_logic;
			s_axis_data_tlast          : In  Std_logic;
			m_axis_data_tdata          : Out Std_logic_vector(47 Downto 0);
			m_axis_data_tuser          : Out Std_logic_vector(23 Downto 0);
			m_axis_data_tvalid         : Out Std_logic;
			m_axis_data_tlast          : Out Std_logic;
			m_axis_status_tdata        : Out Std_logic_vector(7 Downto 0);
			m_axis_status_tvalid       : Out Std_logic;
			event_frame_started        : Out Std_logic;
      event_tlast_unexpected     : Out Std_logic;
      event_tlast_missing        : Out Std_logic;
      event_data_in_channel_halt : Out Std_logic
		);
	End Component;

	Component i2s_transceiver Is
		Generic
		(
			mclk_sclk_ratio : Integer := 4;
			sclk_ws_ratio   : Integer := 64;
			d_width         : Integer := 24);
		Port
		(
			reset_n   : In  Std_logic;
			mclk      : In  Std_logic;
			sclk      : Out Std_logic;
			ws        : Out Std_logic;
			sd_tx     : Out Std_logic;
			sd_rx     : In  Std_logic;
			l_data_tx : In  Std_logic_vector(d_width - 1 Downto 0);
			r_data_tx : In  Std_logic_vector(d_width - 1 Downto 0);
			l_data_rx : Out Std_logic_vector(d_width - 1 Downto 0);
			r_data_rx : Out Std_logic_vector(d_width - 1 Downto 0));
	End Component;

  component clk_wiz_0
    port (
      CLK_IN1  : in  std_logic;
      reset    : in  std_logic;
      clk_out1 : out std_logic
    );
  end component;

  constant s_config_tdata   : std_logic_vector(7 downto 0) := "00000001"; -- forward transform selected, optional fields not needed
  constant s_data_imaginary : std_logic_vector(23 downto 0) := "000000000000000000000000"; -- all input data is real

  signal l_data_rx   : std_logic_vector(23 downto 0);
  signal r_data_rx   : std_logic_vector(23 downto 0);
  signal l_data_tx   : std_logic_vector(23 downto 0);
  signal r_data_tx   : std_logic_vector(23 downto 0);

  signal data_sum   : unsigned(25 downto 0);
  signal r_data_avg : std_logic_vector(23 downto 0);

  -- FFT signals

  signal s_tlast     : std_logic; -- intentionally unused signal
  signal master_clk  : std_logic;
  signal serial_clk  : std_logic;
  signal word_select : std_logic;
  signal s_config_tvalid : std_logic;
  signal s_config_tready : std_logic;
  signal s_data_tvalid : std_logic;
  signal s_data_tready : std_logic;
  signal m_raw_data_tdata  : std_logic_vector(47 downto 0);
  signal m_valid_data_tdata  : std_logic_vector(47 downto 0);
  signal m_data_tvalid : std_logic;
  signal m_data_tready : std_logic;
  signal m_status_tvalid : std_logic;
  signal m_raw_status_tdata  : std_logic_vector(7 downto 0);
  signal m_valid_status_tdata  : std_logic_vector(7 downto 0);


Begin

  r_data_avg <= std_logic_vector(resize(shift_right(resize(unsigned(l_data_rx), 25) + resize(unsigned(r_data_rx), 25), 1), 24)); -- averages the left and right channels

	m_clk : clk_wiz_0
	Port Map
		(clk_in1 => CLK100MHZ, reset => rst, clk_out1 => master_clk);

	i2s_transceiver_0 : i2s_transceiver
	Generic
	Map(
	mclk_sclk_ratio => 4, sclk_ws_ratio => 64, d_width => 24
	)
	Port
	Map(reset_n => rst, mclk => master_clk, sclk => serial_clk, ws => word_select, sd_tx => sd_tx, sd_rx => sd_rx,
	l_data_tx => l_data_tx, r_data_tx => r_data_tx, l_data_rx => l_data_rx, r_data_rx => r_data_rx);

	fft : xfft_0
	Port
	Map (
	aclk                       => CLK100MHZ,
	aresetn                    => (not rst),
	s_axis_config_tdata        => s_config_tdata,
	s_axis_config_tvalid       => s_config_tvalid,
	s_axis_config_tready       => s_config_tready,
	s_axis_data_tdata          => s_data_imaginary & r_data_avg,
  s_axis_data_tvalid         => s_data_tvalid,
	s_axis_data_tready         => s_data_tready,
	s_axis_data_tlast          => s_tlast, -- ignore signal
	m_axis_data_tdata          => m_raw_data_tdata,
-- m_axis_data_tuser          => m_data_tuser,
	m_axis_data_tvalid         => m_data_tvalid,
--	m_axis_data_tlast          => m_axis_data_tlast,
	m_axis_status_tdata        => m_raw_status_tdata,
	m_axis_status_tvalid       => m_status_tvalid
--	event_frame_started        => event_frame_started,
-- 	event_tlast_unexpected     => event_tlast_unexpected,
-- 	event_tlast_missing        => event_tlast_missing,
-- 	event_data_in_channel_halt => event_data_in_channel_halt
	);

  process
  begin
    wait until s_config_tready = '1';
      s_config_tvalid <= '1';
      wait until rising_edge(CLK100MHZ);
      s_config_tvalid <= '0';
  end process;

  process
  begin
    wait until s_data_tready = '1';
      s_data_tvalid <= '1';
      wait until rising_edge(CLK100MHZ);
        s_data_tvalid <= '0';
  end process;

  m_valid_status_tdata <= m_raw_status_tdata when m_status_tvalid = '1';

  m_valid_data_tdata <= m_raw_data_tdata when m_data_tvalid = '1';

End Behavioral;
