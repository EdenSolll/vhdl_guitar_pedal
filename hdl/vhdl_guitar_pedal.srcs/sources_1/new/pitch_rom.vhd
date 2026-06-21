library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pitch_rom is
    port (
        clk                 : in  std_logic;
        pitch_index         : in  std_logic_vector(2 downto 0);
        pitch_shift         : out signed(15 downto 0);
        inverse_pitch_shift : out unsigned(17 downto 0)
    );
end entity pitch_rom;

architecture behavioral of pitch_rom is

    type shift_array_t is array (0 to 7) of signed(15 downto 0);
    type inv_array_t   is array (0 to 7) of unsigned(17 downto 0);

    -- Q10.8 Pitch Shift Table
    -- Format: X"0100" = 1.0 (No Shift)
    constant SHIFT_LUT : shift_array_t := (
        0 => X"0100",  -- Unison / Bypass     (Ratio: 1.0)
        1 => X"0133",  -- Minor 3rd Up        (Ratio: ~1.20)
        2 => X"0140",  -- Major 3rd Up        (Ratio: 1.25)
        3 => X"0155",  -- Perfect 4th Up      (Ratio: ~1.33)
        4 => X"0180",  -- Perfect 5th Up      (Ratio: 1.5)
        5 => X"0200",  -- Octave Up           (Ratio: 2.0)
        6 => X"00AA",  -- Perfect 4th Down    (Ratio: ~0.66)
        7 => X"0080"   -- Octave Down         (Ratio: 0.5)
    );

    -- Inverse Shift Table 
    constant INV_SHIFT_LUT : inv_array_t := (
        0 => "00" & X"0100",  -- 1 / 1.0    = 1.0000 (X"0100")
        1 => "00" & X"00D5",  -- 1 / 1.2    = 0.8333 (X"00D5")
        2 => "00" & X"00CD",  -- 1 / 1.25   = 0.8000 (X"00CD")
        3 => "00" & X"00C0",  -- 1 / 1.333  = 0.7500 (X"00C0")
        4 => "00" & X"00AA",  -- 1 / 1.5    = 0.6666 (X"00AA")
        5 => "00" & X"0080",  -- 1 / 2.0    = 0.5000 (X"0080")
        6 => "00" & X"0180",  -- 1 / 0.666  = 1.5000 (X"0180")
        7 => "00" & X"0200"   -- 1 / 0.5    = 2.0000 (X"0200")
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            pitch_shift         <= SHIFT_LUT(to_integer(unsigned(pitch_index)));
            inverse_pitch_shift <= INV_SHIFT_LUT(to_integer(unsigned(pitch_index)));
        end if;
    end process;
end architecture behavioral;