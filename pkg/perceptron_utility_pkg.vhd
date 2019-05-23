library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package perceptron_utility_pkg is
		-- Support types
        type weight_array is array(10 downto 0) of std_logic_vector(8 downto 0);
		type input_array is array(10 downto 1) of std_logic_vector(7 downto 0);
		-- Global Constants
		constant RegN : positive := 11; -- Number of weights
		constant BitX : positive := 8; -- Number of input bits
		constant BitW : positive := 9; -- Number of weight bits
		constant BitO : positive := 13; -- Number of arithmetic output bits
end package;