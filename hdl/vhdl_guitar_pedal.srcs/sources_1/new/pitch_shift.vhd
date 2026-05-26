library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;
use work.all;

entity pitch_shift is
    generic (
        fft_len : integer := 1024;
        n : integer := depth;
        m : integer := 24
    );
    port (
        clk : in std_logic;
        exp_in : in freq_buffer;
        idx_in : in idx;
        shift : in std_logic_vector(M-1 downto 0);
        exp_out : out freq_buffer;
        idx_out : out idx;
        delays : out integer
    );
end entity pitch_shift;

architecture beh of pitch_shift is

    type reals is array(0 to fft_len-1) of real;

    signal re : reals;
    signal im : reals;

    signal mag : reals;
    signal phase : reals;

    signal re_t : reals;
    signal im_t : reals;

begin

    for i in 0 to fft_len-1 generate
        re(i) <= real(exp_in(i)(depth-1 downto 0));
        im(i) <= real(exp_in(i)((depth*2)-1 downto depth));

        mag(i) <= sqrt((re(i)*re(i))+(im(i)*im(i)));
        phase(i) <= arctan(im(i)/re(i)) + real(shift)/real((std_logic_vector(23 downto 0) <= (others => '1')));

        re_t <= mag(i) * cos(phase(i));
        im_t <= mag(i) * sin(phase(i));
    end generate;

end architecture beh;
