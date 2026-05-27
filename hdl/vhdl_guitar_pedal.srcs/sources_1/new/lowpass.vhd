library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.all;

entity lowpass is
    generic (
        fft_len : integer := 1024;
        n : integer := d_width;
        m : integer := 24
    );
    port (
        reset : in std_logic;
        clk : in std_logic;
        mag_in : in freq_buffer;
        phase_in : in freq_buffer;
        mag_out : out freq_buffer;
        phase_out : out freq_buffer
    );
end entity lowpass;

architecture beh of lowpass is

begin

    for i in 0 to fft_len-1 generate

    end generate;

end architecture beh;
