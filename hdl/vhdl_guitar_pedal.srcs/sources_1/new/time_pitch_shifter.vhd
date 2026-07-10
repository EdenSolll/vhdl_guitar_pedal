library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.audio_stream_pkg.all;

entity time_pitch_shifter is
	port (
		clk           : in  std_logic;
		rst           : in  std_logic;
		s_axis        : in  t_axis_forward;
		s_ready       : out std_logic;
		m_axis        : out t_axis_forward;
		m_ready       : in  std_logic;
		pitch_control : in  signed(15 downto 0)
	);
end entity;

architecture Behavioral of time_pitch_shifter is
	signal circular_buffer      : t_audio_buffer := (others => (others => '0'));

	-- Read/write pointers
	signal write_ptr            : unsigned(13 downto 0);
	signal addr_A               : unsigned(13 downto 0);
	signal addr_B               : unsigned(13 downto 0);

	-- 26-bit accumulators (14 bits address, 12 bits fraction)
	signal read_accum_A         : unsigned(25 downto 0)  := (others => '0');
	signal read_accum_B         : unsigned(25 downto 0)  := to_unsigned(33554432, 26);

	-- Crossfade control
	signal fade_counter         : unsigned(7 downto 0)   := (others => '0');
	signal fade_out_A           : std_logic              := '0';

	-- Gain signals
	signal rom_index            : integer range 0 to 255 := 0;
	signal gain_B               : signed(13 downto 0);
	signal gain_A               : signed(13 downto 0);

	-- Interpolation signals
	-- Raw samples from buffer
	signal sample_A0, sample_A1 : signed(23 downto 0);
	signal sample_B0, sample_B1 : signed(23 downto 0);

	-- Difference and fractional part
	signal diff_A, diff_B       : signed(23 downto 0);
	signal frac_A, frac_B       : unsigned(11 downto 0);

	-- Interpolated outputs
	signal interp_A, interp_B   : signed(23 downto 0);

	-- Multiplier results
	signal mult_result_A        : signed(37 downto 0) := (others => '0');
	signal mult_result_B        : signed(37 downto 0) := (others => '0');

	-- Final output register
	signal sample_out_reg       : signed(23 downto 0) := (others => '0');

	component crossfade_rom is
		port (
			clk             : in  std_logic;
			fade_index      : in  integer range 0 to 255;
			crossfade_const : out signed(13 downto 0)
		);
	end component;
begin

	rom_inst : crossfade_rom
	port map(
		clk             => clk,
		fade_index      => rom_index,
		crossfade_const => gain_B
	);

	gain_A    <= to_signed(4096, 14) - gain_B;
	rom_index <= to_integer(fade_counter);

	process (clk)
		variable addr_A_int : integer range 0 to 16383;
		variable addr_B_int : integer range 0 to 16383;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				write_ptr      <= (others => '0');
				read_accum_A   <= (others => '0');
				read_accum_B   <= to_unsigned(33554432, 26);
				fade_counter   <= (others => '0');
				fade_out_A     <= '0';
				sample_out_reg <= (others => '0');
				s_ready        <= '1';
				m_axis.valid   <= '0';
				m_axis.last    <= '0';

				-- Reset interpolation pipeline
				sample_A0      <= (others => '0');
				sample_A1      <= (others => '0');
				sample_B0      <= (others => '0');
				sample_B1      <= (others => '0');
				diff_A         <= (others => '0');
				diff_B         <= (others => '0');
				frac_A         <= (others => '0');
				frac_B         <= (others => '0');
				interp_A       <= (others => '0');
				interp_B       <= (others => '0');

			else
				-- Default assignments
				s_ready      <= '1';
				m_axis.valid <= '0';

				-- Process input if valid and downstream is ready
				if s_axis.valid = '1' and m_ready = '1' then

					-- Write input to buffer
					circular_buffer(to_integer(write_ptr)) <= s_axis.data;
					write_ptr                              <= write_ptr + 1;

					-- Update read pointers
					addr_A                                 <= read_accum_A(25 downto 12);
					addr_B                                 <= read_accum_B(25 downto 12);

					-- Extract fractional parts for interpolation
					frac_A                                 <= read_accum_A(11 downto 0);
					frac_B                                 <= read_accum_B(11 downto 0);

					-- Step accumulators
					read_accum_A                           <= read_accum_A + unsigned(resize(pitch_control, 26));
					read_accum_B                           <= read_accum_B + unsigned(resize(pitch_control, 26));

					-- Trigger crossfade 
					if (addr_A >= write_ptr) and (fade_out_A = '0') then
						fade_out_A   <= '1';
						fade_counter <= (others => '0');
					end if;

					if fade_out_A = '1' then
						if fade_counter < 255 then
							fade_counter <= fade_counter + 1;
						else
							fade_out_A <= '0';
						end if;
					end if;

					-- Read new samples for interpolation
					addr_A_int := to_integer(addr_A);
					addr_B_int := to_integer(addr_B);

					-- Sample 0 (current)
					sample_A0 <= circular_buffer(addr_A_int);
					sample_B0 <= circular_buffer(addr_B_int);

					-- Sample 1 (next, with wrap-around)
					if addr_A_int = 16383 then
						sample_A1 <= circular_buffer(0);
					else
						sample_A1 <= circular_buffer(addr_A_int + 1);
					end if;

					if addr_B_int = 16383 then
						sample_B1 <= circular_buffer(0);
					else
						sample_B1 <= circular_buffer(addr_B_int + 1);
					end if;

					-- Compute difference 
					diff_A   <= sample_A1 - sample_A0;
					diff_B   <= sample_B1 - sample_B0;

					-- Linear interpolation to handle artifacts and aliasing
					-- interpolation = sample0 + (sample1 - sample0) * frac / 4096 (resized to 24 bits)
					interp_A <= sample_A0 + resize(
						shift_right(diff_A * signed('0' & frac_A), 12), 24
						);
					interp_B <= sample_B0 + resize(
						shift_right(diff_B * signed('0' & frac_B), 12), 24
						);

					-- Multiply with crossfade gains 
					mult_result_A <= interp_A * gain_A;
					mult_result_B <= interp_B * gain_B;

                    sample_out_reg <= resize(
                        mult_result_A(35 downto 12) + mult_result_B(35 downto 12), 24
                        );
                    m_axis.data  <= sample_out_reg;
                    m_axis.valid <= '1'; -- set new sample control signal
                    m_axis.last  <= '0'; -- time-domain ignores frame boundaries
				end if;
			end if;
		end if;
	end process;
end Behavioral;
