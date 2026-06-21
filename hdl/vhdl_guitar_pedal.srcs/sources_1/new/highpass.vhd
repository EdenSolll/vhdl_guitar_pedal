library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.all;

entity highpass is
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
end entity highpass;

architecture beh of highpass is

constant threshold : std_logic_vector(n downto 0) := (other => '0') or '000001';

begin

    for i in 0 to fft_len-1 generate
        if mag_in(i) < threshold then -- 1/64 ~= 1.5%
          mag_out(i) <= (others => '0');
        else
          mag_out(i) <= mag_in(i);
        end if;

        phase_out(i) <= phase_in(i);
    end generate;

end architecture beh;
