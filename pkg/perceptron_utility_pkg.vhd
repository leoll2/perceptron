library ieee;
use ieee.std_logic_1164.all;

package perceptron_utility_pkg is
		-- Support types
        type weight_array is array(10 downto 0) of std_logic_vector(8 downto 0);
		type input_array is array(10 downto 1) of std_logic_vector(7 downto 0);
		-- Global Constants
		constant RegW : positive := 11; -- Number of weights
        constant Regx : positive := 10; -- Number of inputs
		constant BitX : positive := 8; -- Number of input bits
		constant BitW : positive := 9; -- Number of weight bits
		constant BitO : positive := 14; -- Number of arithmetic output bits
		constant BitL : positive := 10; -- Number of optimized lut output bits (to be extended)
		constant BitY : positive := 16; -- Number of perceptron output bits
end package;