library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.MATH_REAL.all;
use work.globals.all;
use work.all;

entity polar_fft is
	generic (
		fft_len : integer := 1024;
		n       : integer := d_width;
		m       : integer := 24
	);
	port (
		clk         : in std_logic;
		rst         : in std_logic;
		word_select : in std_logic;
		real_data   : in std_logic_vector(23 downto 0);
		phase_out     : out ram_24bit;
		magnitude_out : out ram_24bit;
		fft_ready     : out std_logic
	);
end entity polar_fft;

architecture behavioral of polar_fft is
	-- FFT configuration constants
	constant s_config_tdata        : std_logic_vector(7 downto 0)  := "00000001";                 -- forward transform selected, optional fields not needed
	constant s_data_imaginary      : std_logic_vector(23 downto 0) := "000000000000000000000000"; -- all input data is real

	-- Foward FFT signals

	signal s_tlast                 : std_logic;                                                   -- intentionally unused signal
	signal master_clk              : std_logic;
	signal serial_clk              : std_logic;
	signal s_config_tvalid         : std_logic;
	signal s_config_tready         : std_logic;
	signal s_data_tvalid           : std_logic;
	signal s_data_tready           : std_logic;
	signal m_raw_data_tdata        : std_logic_vector(47 downto 0);
	signal m_valid_data_tdata      : std_logic_vector(47 downto 0);
	signal m_data_tuser            : std_logic_vector(23 downto 0);
	signal m_data_tvalid           : std_logic;
	signal m_data_tready           : std_logic;
	signal m_status_tvalid         : std_logic;
	signal m_raw_status_tdata      : std_logic_vector(7 downto 0);
	signal m_valid_status_tdata    : std_logic_vector(7 downto 0);
	signal m_axis_data_tlast       : std_logic;

	signal word_delay              : std_logic;

	signal aclk                    : std_logic;
	signal aresetn                 : std_logic;
	signal s_axis_cartesian_tvalid : std_logic;
	signal s_axis_cartesian_tlast  : std_logic;
	signal rectangular_tdata       : std_logic_vector(47 downto 0);
	signal m_axis_dout_tvalid      : std_logic;
	signal m_axis_dout_tlast       : std_logic;
	signal polar_tdata             : std_logic_vector(47 downto 0);

	signal magnitude_ram           : ram_24bit := (others => (others => '0'));
	signal phase_ram               : ram_24bit := (others => (others => '0'));

    signal config_done             : std_logic; 
    
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

-- Configuration Boot sequence
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
                        config_done <= '1'; 
                    end if;
                end if;
            end if;
        end if;
    end process;

	forward_fft : xfft_0
	port map(
		aclk                 => clk,
		aresetn              => (not rst),
		s_axis_config_tdata  => s_config_tdata,
		s_axis_config_tvalid => s_config_tvalid,
		s_axis_config_tready => s_config_tready,
		s_axis_data_tdata    => s_data_imaginary & real_data,
		s_axis_data_tvalid   => s_data_tvalid,
		s_axis_data_tready   => s_data_tready,
		s_axis_data_tlast    => '0',
		m_axis_data_tdata    => m_raw_data_tdata,
		m_axis_data_tuser    => open,
		m_axis_data_tvalid   => m_data_tvalid,
		m_axis_data_tlast    => m_axis_data_tlast
	);

  -- Ready FFT Input
  process(clk) is
      variable divider : std_logic := '0';
      variable ws_last : std_logic;
  begin
    if clk = '1' then
      if word_select /= ws_last then
        divider := not divider;
        if divider = '1' then
          s_data_tvalid <= '1';
        end if; -- divider = '1'
      end if; -- word_select /= ws_last
      ws_last := word_select;
    end if; --clk = '1'
  end process;

  -- Complete data handshake
  process(s_data_tready, clk) is
    variable transmitted : std_logic := '0';
  begin
    if s_data_tready = '1' and s_data_tvalid = '1' then
      transmitted := '1';
    else
      if transmitted = '1' then
        transmitted := '0';
        s_data_tvalid <= '0';
      end if; -- transmitted = '1'
    end if; -- s_data_tready = '1'
  end process;

    rectangular_to_polar : cordic_0
	port map(
		aclk                    => clk,
		aresetn                 => (not rst),
		s_axis_cartesian_tvalid => m_data_tvalid,
		s_axis_cartesian_tlast  => m_axis_data_tlast,
		s_axis_cartesian_tdata  => m_raw_data_tdata,
		m_axis_dout_tvalid      => m_axis_dout_tvalid,
		m_axis_dout_tlast       => m_axis_dout_tlast,
		m_axis_dout_tdata       => polar_tdata
	);

	process (clk)
		variable write_addr : integer range 0 to 1023 := 0;
	begin
		if rising_edge(clk) then
			fft_ready <= '0';
			if m_axis_dout_tvalid = '1' then
				phase_ram(write_addr)     <= polar_tdata(47 downto 24); -- top 24 bits = phase
				magnitude_ram(write_addr) <= polar_tdata(23 downto 0);  -- bottom 24 bits = magnitude
				if m_axis_dout_tlast = '1' then
					write_addr := 0;
					fft_ready <= '1';
				else
					write_addr := write_addr + 1;
				end if;
			end if;
		end if;
	end process;
	
	phase_out     <= phase_ram;
	magnitude_out <= magnitude_ram;

end architecture behavioral;
