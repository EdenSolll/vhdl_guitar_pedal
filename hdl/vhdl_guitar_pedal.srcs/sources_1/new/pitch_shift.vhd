library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.all;

entity pitch_shift is
    generic (
        fft_len : integer := 1024;
        n : integer := 48;
        m : integer := 8
    );
    port (
        clk : in std_logic;
        exp_in : in mem_t;
        idx_in : in idx;
        shift_hertz : in std_logic_vector(M-1 downto 0);
        exp_out : out mem_t;
        idx_out : out idx;
        delays : out integer
    );
end entity pitch_shift;

architecture beh of pitch_shift is

    signal re : idx;
    signal im : idx;

begin

    for i in 0 to fft_len-1 generate
    end generate;

end architecture beh;
