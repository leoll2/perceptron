library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vector_array_pkg is
        type weight_array is array(10 downto 0) of std_logic_vector(8 downto 0);
		type input_array is array(10 downto 1) of std_logic_vector(7 downto 0);
end package;