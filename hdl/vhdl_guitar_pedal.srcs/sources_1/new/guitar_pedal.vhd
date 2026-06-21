library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.globals.all;
use work.all;

entity guitar_pedal is
	port (
		CLK100MHZ : in  std_logic;
		rst       : in  std_logic;
		
		-- pitch shifting inpits
		pitch_index : in std_logic_vector (2 downto 0); 
		
		-- Pmod I2S2 DAC (Line Out)
        tx_mclk   : out std_logic; -- Pin 1: Master Clock
        tx_lrck   : out std_logic; -- Pin 2: Word Select
        tx_sclk   : out std_logic; -- Pin 3: Serial Clock
        tx_sd     : out std_logic; -- Pin 4: Serial Data In

        -- Pmod I2S2 ADC (Line In)
        rx_mclk   : out std_logic; -- Pin 7: Master Clock
        rx_lrck   : out std_logic; -- Pin 8: Word Select
        rx_sclk   : out std_logic; -- Pin 9: Serial Clock
        rx_sd     : in  std_logic  -- Pin 10: Serial Data Out
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

	signal fft_phase_ram   : ram_24bit;
	signal fft_mag_ram     : ram_24bit;
	signal fft_frame_ready : std_logic;

	signal ps_phase_stream : std_logic_vector(23 downto 0);
	signal ps_magnitude_stream   : std_logic_vector(23 downto 0);
	signal ps_valid        : std_logic;
	signal ps_last         : std_logic;

    signal playback_ram    : audio_buffer_t := (others => (others => '0'));
	signal ifft_valid      : std_logic;

	signal processed_audio : std_logic_vector(23 downto 0);
	
	-- pitch shifting signals
	signal pitch_shift_ctl : signed(15 downto 0);
	signal inverse_pitch_shift_ctl : unsigned(17 downto 0); 

	-- overlap add process signals
    signal frame_start_addr : unsigned(9 downto 0) := (others => '0');
    signal write_offset     : unsigned(9 downto 0) := (others => '0');
    signal i2s_read_addr    : unsigned(9 downto 0) := (others => '0');
	signal ws_delay        : std_logic := '0';

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
	
	component pitch_rom is 
	port( 
	    clk                 : in  std_logic;
        pitch_index         : in  std_logic_vector(2 downto 0); 
        pitch_shift         : out signed(15 downto 0);
        inverse_pitch_shift : out unsigned(17 downto 0)
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

    -- Average the left and right channels so convert audio to mono

	r_data_avg <= std_logic_vector(resize(shift_right(resize(signed(l_data_rx), 25) + resize(signed(r_data_rx), 25), 1), 24)); -- averages the left and right channels

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
		reset_n   => (not rst),
		mclk      => master_clk,
		sclk      => serial_clk,
		ws        => word_select,
		sd_tx     => tx_sd,
		sd_rx     => rx_sd,
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
	
	pitch_rom_0 : pitch_rom
	port map(
	    clk => CLK100MHZ,
	    pitch_index => pitch_index,
	    pitch_shift => pitch_shift_ctl,
	    inverse_pitch_shift => inverse_pitch_shift_ctl
	);

	pitch_shifter_0 : pitch_shift
	port map(
		clk                     => CLK100MHZ,
		rst                     => rst,
		input_valid             => fft_frame_ready,
		pitch_shift             => pitch_shift_ctl,
		inverse_pitch_shift     => inverse_pitch_shift_ctl,
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

	-- Overlap-Add Buffer Process
    process(CLK100MHZ)
        variable absolute_write_addr : integer range 0 to 1023;
        variable current_val         : signed(23 downto 0);
        variable sum_val             : signed(23 downto 0);
    begin
        if rising_edge(CLK100MHZ) then


            ws_delay <= word_select;

            -- Detect the falling edge of Word Select
            if ws_delay = '1' and word_select = '0' then

                -- Route the fully accumulated audio out to the I2S transmitter
                r_data_tx <= playback_ram(to_integer(i2s_read_addr));
                l_data_tx <= playback_ram(to_integer(i2s_read_addr));

                -- CLEAR the memory address so it is clean for the next frames
                playback_ram(to_integer(i2s_read_addr)) <= (others => '0');

                -- Advance read pointer (naturally wraps back to 0)
                i2s_read_addr <= i2s_read_addr + 1;
            end if;


            if ifft_valid = '1' then

                -- Calculate circular address: Frame Start + current offset
                absolute_write_addr := to_integer(frame_start_addr + write_offset);

                -- Read existing data, add new sample, and write back
                current_val := signed(playback_ram(absolute_write_addr));
                sum_val     := current_val + signed(processed_audio);
                playback_ram(absolute_write_addr) <= std_logic_vector(sum_val);

                -- Manage write offset and frame hopping
                if write_offset = 1023 then
                    write_offset <= (others => '0');
                    -- Shift the start of the next frame forward by the Hop Size (256)
                    frame_start_addr <= frame_start_addr + 256;
                else
                    write_offset <= write_offset + 1;
                end if;
            end if;

        end if;
    end process;

    -- Send internal clocks out to the DAC (Line Out)
    tx_mclk <= master_clk;
    tx_lrck <= word_select;
    tx_sclk <= serial_clk;

    -- Send internal clocks out to the ADC (Line In)
    rx_mclk <= master_clk;
    rx_lrck <= word_select;
    rx_sclk <= serial_clk;

end structural;
