library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audio_stream_pkg.all;
use work.hanning_window_rom.all;

entity polar_fft is
	generic (
		fft_len : integer := C_FFT_LEN;    -- 1024 bit fft
		n       : integer := C_AUDIO_WIDTH -- 24 bit samples
	);
	port (
		clk           : in  std_logic;
		rst           : in  std_logic;

		-- Streaming audio input
		s_axis        : in  t_axis_forward; -- data, valid, last
		s_ready       : out std_logic;

		-- Output phase and magnitude arrays
		phase_out     : out t_phase_frame;
		magnitude_out : out t_mag_frame;
		fft_ready     : out std_logic -- pulses high for one cycle when frame is ready
	);
end entity polar_fft;

architecture behavioral of polar_fft is

	-- FFT configuration constants
	constant s_config_tdata   : std_logic_vector(23 downto 0) := "000000000000000000000001"; -- forward FFT
	constant s_data_imaginary : std_logic_vector(23 downto 0) := (others => '0');            -- all input is real

	-- FFT / CORDIC internal signals
	signal s_config_tvalid    : std_logic;
	signal s_config_tready    : std_logic;
	signal s_data_tvalid      : std_logic;
	signal s_data_tready      : std_logic;
	signal s_data_tlast       : std_logic;
	signal s_data_tdata       : std_logic_vector(47 downto 0);
	signal m_raw_data_tdata   : std_logic_vector(47 downto 0);
	signal m_data_tvalid      : std_logic;
	signal m_axis_data_tlast  : std_logic;

	signal m_axis_dout_tvalid : std_logic;
	signal m_axis_dout_tlast  : std_logic;
	signal polar_tdata        : std_logic_vector(47 downto 0);

	-- Pipeline registers for timing closure
	signal mult_pipe          : signed(47 downto 0)  := (others => '0');
	signal valid_pipe         : std_logic            := '0';
	signal last_pipe          : std_logic            := '0';

	-- Frame storage buffers
	signal input_ram          : t_audio_frame        := (others => (others => '0'));

	signal write_ptr          : unsigned(9 downto 0) := (others => '0');
	signal read_offset        : unsigned(9 downto 0) := (others => '0');

	-- State machine 
	type state_t is (IDLE, COLLECT, STREAM_BURST, WAIT_READY);
	signal current_state : state_t       := IDLE;

	-- Frame output RAMs
	signal magnitude_ram : t_mag_frame   := (others => (others => '0'));
	signal phase_ram     : t_phase_frame := (others => (others => '0'));

	-- Config done flag
	signal config_done   : std_logic     := '0';

	-- FFT and CORDIC Component declarations
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

	-- Configuration initalization
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				s_config_tvalid <= '0';
				config_done     <= '0';
			else
				if config_done = '0' then
					s_config_tvalid <= '1';
					if s_config_tready = '1' then
						s_config_tvalid <= '0';
						config_done     <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	-- FSM process
	process (clk)
		variable multiply_result : signed(47 downto 0);
		variable raw_sample      : signed(23 downto 0);
	begin
		if rising_edge(clk) then
			if rst = '1' then
				write_ptr     <= (others => '0');
				read_offset   <= (others => '0');
				s_data_tvalid <= '0';
				s_data_tlast  <= '0';
				current_state <= IDLE;
				s_ready       <= '1';
				fft_ready     <= '0';
				mult_pipe     <= (others => '0');
				valid_pipe    <= '0';
				last_pipe     <= '0';
			else
				-- default assignments
				s_ready   <= '0';
				fft_ready <= '0';

				case current_state is

				    -- IDLE: wait for the first sample
					when IDLE =>
						s_ready <= '1'; -- we can accept
						if s_axis.valid = '1' and s_ready = '1' then
							-- start collecting a new frame
							input_ram(to_integer(write_ptr)) <= s_axis.data;
							write_ptr                        <= write_ptr + 1;
							current_state                    <= COLLECT; -- set collect state
						end if;

					-- COLLECT: gather 1024 samples, expecting 'last' on sample 1023
					when COLLECT =>
						s_ready <= '1';
						if s_axis.valid = '1' then
							input_ram(to_integer(write_ptr)) <= s_axis.data;

							if s_axis.last = '1' then
								-- frame complete - start burst
								write_ptr     <= (others => '0');
								read_offset   <= (others => '0');
								current_state <= STREAM_BURST;
								s_ready       <= '0'; -- stop accepting during processing
							else
								write_ptr <= write_ptr + 1;
							end if;
						end if;

						-- STREAM_BURST: feed the FFT with all 1024 samples
					when STREAM_BURST =>
						s_ready <= '0'; -- not ready while streaming
						-- read from input_ram using read_offset and multiply
						raw_sample      := input_ram(to_integer(read_offset));
						multiply_result := raw_sample * hanning_rom(to_integer(read_offset));
						-- send result to pipeline register 
						mult_pipe  <= multiply_result;
						valid_pipe <= '1'; -- we always have a valid result in the pipeline
						last_pipe  <= '1' when read_offset = 1023 else
							'0';
						-- pass pipelined signals to FFT
						-- truncate to 24 bits (fractional bits saved for rounding later)

						s_data_tdata  <= s_data_imaginary & std_logic_vector(mult_pipe(46 downto 23));
						s_data_tvalid <= valid_pipe;
						s_data_tlast  <= last_pipe;

						if s_data_tready = '1' then
							if read_offset = 1023 then
								current_state <= WAIT_READY; -- wait for FFT to finish
							else
								read_offset <= read_offset + 1;
							end if;
						end if;

						-- WAIT_READY: wait for the FFT + CORDIC to output the frame
					when WAIT_READY =>
						s_ready       <= '0';
						s_data_tvalid <= '0';
						s_data_tlast  <= '0';

						-- once output finished set state back to IDLE 
						if fft_ready = '1' then
							current_state <= IDLE;
						end if;

					when others =>
						current_state <= IDLE;
				end case;
			end if;
		end if;
	end process;

	-- Instantiate the forward FFT
	forward_fft : xfft_0
	port map(
		aclk                 => clk,
		aresetn              => (not rst),
		s_axis_config_tdata  => s_config_tdata,
		s_axis_config_tvalid => s_config_tvalid,
		s_axis_config_tready => s_config_tready,
		s_axis_data_tdata    => s_data_tdata,
		s_axis_data_tvalid   => s_data_tvalid,
		s_axis_data_tready   => s_data_tready,
		s_axis_data_tlast    => s_data_tlast,
		m_axis_data_tdata    => m_raw_data_tdata,
		m_axis_data_tuser    => open,
		m_axis_data_tvalid   => m_data_tvalid,
		m_axis_data_tlast    => m_axis_data_tlast
	);

	-- Instantiate the rectangular-to-polar CORDIC IP
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

	-- Pass the CORDIC output into phase/magnitude RAMs
	process (clk)
		variable write_addr : integer range 0 to 1023 := 0;
	begin
		if rising_edge(clk) then
			fft_ready <= '0';

			if rst = '1' then
				write_addr := 0;
				phase_ram     <= (others => (others => '0'));
				magnitude_ram <= (others => (others => '0'));
			else
				if m_axis_dout_tvalid = '1' then
					-- Store phase and magnitude
					phase_ram(write_addr)     <= signed(polar_tdata(47 downto 24));
					magnitude_ram(write_addr) <= signed(polar_tdata(23 downto 0));

					if m_axis_dout_tlast = '1' then
						write_addr := 0;  -- once last sample read reset write adrr to 0
						fft_ready <= '1'; -- set the fft ready flag to accept next sample
					else
						write_addr := write_addr + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Set outputs
	phase_out     <= phase_ram;
	magnitude_out <= magnitude_ram;

end architecture behavioral;
