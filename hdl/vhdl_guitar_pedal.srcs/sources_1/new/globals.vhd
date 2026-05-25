library ieee;
use ieee.std_logic_1164.all;
package globals is
	type freq_buffer is array (0 to 1023) of std_logic_vector(47 downto 0);
end;
