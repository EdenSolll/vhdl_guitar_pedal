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

	type audio_buffer_t is array (0 to 1023) of std_logic_vector(23 downto 0);

	signal master_clk  : std_logic;
	signal serial_clk  : std_logic;
	signal word_select : std_logic;

	signal l_data_rx   : std_logic_vector(d_width-1 downto 0);
	signal r_data_rx   : std_logic_vector(d_width-1 downto 0);
	signal l_data_tx   : std_logic_vector(d_width-1 downto 0);
	signal r_data_tx   : std_logic_vector(d_width-1 downto 0);
	signal r_data_avg  : std_logic_vector(d_width-1 downto 0);
	
	signal data_sum    : unsigned(d_width downto 0);

	signal fft_phase_ram   : ram_24bit;
	signal fft_mag_ram     : ram_24bit;
	signal fft_frame_ready : std_logic;
	
	signal ps_phase_stream : std_logic_vector(23 downto 0);
	signal ps_magnitude_stream   : std_logic_vector(23 downto 0);
	signal ps_valid        : std_logic;
	signal ps_last         : std_logic;
	
    signal playback_ram    : audio_buffer_t := (others => (others => '0'));
	signal ifft_valid      : std_logic;
    signal ifft_write_addr : integer range 0 to 1023 := 0;
	signal i2s_read_addr   : integer range 0 to 1023 := 0;
	signal ws_delay        : std_logic := '0';
	
	signal processed_audio : std_logic_vector(23 downto 0);
	
    constant ctrl_pitch_shift : signed(15 downto 0) := X"0180";       -- Q10.8 = 1.5
	constant ctrl_inv_shift   : unsigned(17 downto 0) := "00" & X"AAB0"; -- 1 / 1.5 = 0.6666 (Q10.8)
	
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
            real_data   : in std_logic_vector(23 downto 0);
            phase_out     : out ram_24bit;
            magnitude_out : out ram_24bit;
            fft_ready     : out std_logic
		);
	end component;
	
    component rectangular_ifft is
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
    end component;
    
    component pitch_shift is
		port (
			clk                     : in  std_logic;
			rst                     : in  std_logic;
			input_valid             : in  std_logic;
			pitch_shift             : in  signed(15 downto 0);
			inverse_pitch_shift     : in  unsigned(17 downto 0);
			input_phase             : in  ram_24bit;
			input_magnitude         : in  ram_24bit;
			output_phase_stream     : out std_logic_vector(23 downto 0);
			output_magnitude_stream : out std_logic_vector(23 downto 0);
			output_valid            : out std_logic;
			output_last             : out std_logic
		);
	end component;

begin

	r_data_avg <= std_logic_vector(resize(shift_right(resize(unsigned(l_data_rx), 25) + resize(unsigned(r_data_rx), 25), 1), 24)); -- averages the left and right channels

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
		real_data   => r_data_avg,
		phase_out     => fft_phase_ram,
		magnitude_out => fft_mag_ram,
		fft_ready     => fft_frame_ready
	);
	
	pitch_shifter_0 : pitch_shift
	port map(
		clk                     => CLK100MHZ,
		rst                     => rst,
		input_valid             => fft_frame_ready,
		pitch_shift             => ctrl_pitch_shift,
		inverse_pitch_shift     => ctrl_inv_shift,
		input_phase             => fft_phase_ram,
		input_magnitude         => fft_mag_ram,
		output_phase_stream     => ps_phase_stream,
		output_magnitude_stream => ps_magnitude_stream,
		output_valid            => ps_valid,
		output_last             => ps_last
	);
	
	rectangular_ifft_0 : rectangular_ifft
	port map(
		clk                    => CLK100MHZ,
		rst                    => rst,
		input_valid            => ps_valid,
		input_last             => ps_last,
		input_phase_stream     => ps_phase_stream,
		input_magnitude_stream => ps_magnitude_stream,
		real_audio_out         => processed_audio,
		output_valid           => ifft_valid,
		output_last            => open
	);
	
	process(CLK100MHZ)
	begin
		if rising_edge(CLK100MHZ) then
			-- The IFFT pulses this flag when a new sample shoots out
			if ifft_valid = '1' then 
				playback_ram(ifft_write_addr) <= processed_audio;
				
				if ifft_write_addr = 1023 then
					ifft_write_addr <= 0;
				else
					ifft_write_addr <= ifft_write_addr + 1;
				end if;
			end if;
		end if;
	end process;

	process(master_clk)
	begin
		if rising_edge(master_clk) then
			ws_delay <= word_select;
			-- Detect the falling edge of the Word Select clock 
			if ws_delay = '1' and word_select = '0' then
				if i2s_read_addr = 1023 then
					i2s_read_addr <= 0;
				else
					i2s_read_addr <= i2s_read_addr + 1;
				end if;
			end if;
		end if;
	end process;
	
	r_data_tx <= playback_ram(i2s_read_addr);
	l_data_tx <= playback_ram(i2s_read_addr);

end structural;
