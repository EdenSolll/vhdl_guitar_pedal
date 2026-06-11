library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.globals.all;
use work.all;

entity pitch_shift is
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
end entity pitch_shift;

architecture behavioral of pitch_shift is

	type fractional_phase_ram is array (0 to 1023) of std_logic_vector(41 downto 0);

	type state_t is (IDLE, PROCESSING);
	signal current_state     : state_t              := IDLE;

	signal previous_phase    : ram_24bit            := (others => (others => '0'));
	signal accumulated_phase : fractional_phase_ram := (others => (others => '0'));

begin

	process (clk)
		variable write_index           : integer range 0 to 1023 := 0; -- Q10.8 Format
		variable virtual_read_index    : unsigned(17 downto 0)   := (others => '0');
		variable ram_index             : integer range 0 to 2047 := 0;

		variable expected_advance      : signed(23 downto 0);
		variable phase_difference      : signed(23 downto 0);
		variable phase_deviation       : signed(23 downto 0);
		variable unwrapped_phase       : signed(25 downto 0);

		variable scaled_phase          : signed(41 downto 0);
		variable new_accumulated_phase : signed(41 downto 0);

	begin
		if rising_edge(clk) then
			if rst = '1' then
				current_state <= IDLE;
				output_valid  <= '0';
				output_last   <= '0';
			else

				case current_state is

						-- IDLE state: Wait for the FFT to finish a frame
					when IDLE =>
						output_valid <= '0';
						output_last  <= '0';
						write_index        := 0;
						virtual_read_index := (others => '0');

						if input_valid = '1' then
							current_state <= PROCESSING; -- Trigger received! Start the loop.
						end if;

						-- PROCESSING state: Process 1024 bins, then stop.
					when PROCESSING =>
						ram_index := to_integer(virtual_read_index(17 downto 8));

                        if write_index < 512 then
                            if ram_index < 512 then

                                expected_advance      := signed(shift_left(resize(virtual_read_index, 24), 14)); -- calculate expected advance using the fractional pointer

                                -- Phase tracking math (Automatic Modulo 2*PI wrapping)
                                phase_difference      := signed(input_phase(ram_index)) - signed(previous_phase(ram_index));
                                phase_deviation       := phase_difference - expected_advance;
                                unwrapped_phase       := resize(expected_advance, 26) + resize(phase_deviation, 26);

                                scaled_phase          := unwrapped_phase * pitch_shift;

                                -- Accumulate the phase into the output bin
                                new_accumulated_phase := signed(accumulated_phase(write_index)) + scaled_phase;

                                -- Save the outputs
                                accumulated_phase(write_index) <= std_logic_vector(new_accumulated_phase);
                                previous_phase(write_index)      <= input_phase(write_index);
                                output_phase_stream            <= std_logic_vector(new_accumulated_phase(35 downto 12));

                                -- move the magnitude to the new bin
                                output_magnitude_stream        <= input_magnitude(ram_index);
                                output_valid                   <= '1';
                            else
                                -- pitch shift past nyquest frequency should get silenced
                                output_phase_stream     <= (others => '0');
                                output_magnitude_stream <= (others => '0');
                                output_valid            <= '1';
                            end if;
                        else
                               -- Negative Frequencies (Bins 512 to 1023) just set to zeros
                            output_phase_stream     <= (others => '0');
                            output_magnitude_stream <= (others => '0');
                            output_valid            <= '1';
                        end if;

						-- Advance the Pointers
						if write_index = 1023 then
							output_last   <= '1';
							current_state <= IDLE; -- Frame is finished, set back to IDLE state
						else
							write_index        := write_index + 1;
							virtual_read_index := virtual_read_index + inverse_pitch_shift;
							output_last <= '0';
						end if;

				end case;
			end if;
		end if;
	end process;

end architecture behavioral;
