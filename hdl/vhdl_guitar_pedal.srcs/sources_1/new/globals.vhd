library ieee;
use ieee.std_logic_1164.all;

package globals is
	constant fft_len : integer := 1024;
	constant d_width   : integer := 24;
	type freq_buffer is array (0 to fft_len - 1) of std_logic_vector((d_width * 2) - 1 downto 0);
	type idx is array (0 to fft_len - 1) of std_logic_vector(d_width - 1 downto 0);
	type ram_24bit is array (0 to 1023) of std_logic_vector(23 downto 0); -- Block RAM type for storing phase and magnitude
end;
