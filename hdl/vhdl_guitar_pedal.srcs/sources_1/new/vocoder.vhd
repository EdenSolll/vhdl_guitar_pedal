library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.globals.all;
use work.all;

entity vocoder is
  port (
    clk : in std_logic;
    rst : in std_logic
       );
end entity vocoder;

architecture behavioral of vocoder is
  signal current_phase : ram_24bit := (others => (others => '0'));
  signal previous_phase : ram_24bit := (others => (others => '0'));

begin

  process(clk)
		variable slice_index : integer range 0 to 1023 := 0;

    variable expected_advance : signed(23 downto 0);
    variable phase_difference : signed(23 downto 0);
    variable phase_deviation : signed(23 downto 0);
    variable unwrapped_phase : signed(23 downto 0);
  begin
    if rising_edge(clk) then
      expected_advance := to_signed(slice_index * 4194304, 24);

      phase_difference := (signed(current_phase(slice_index)) - signed(previous_phase(slice_index)));

      phase_deviation := phase_difference - expected_advance;

      unwrapped_phase := resize(expected_advance, 26) + resize(phase_deviation, 26);

      previous_phase <= current_phase;

    end if;
    if slice_index = 1023 then
      slice_index := 0;
    end if;
  end process;


end architecture behavioral;
