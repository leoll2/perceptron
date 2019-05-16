library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vector_array_pkg.all;

entity Arithmetic is
	generic (
		BitX : positive := 8; -- Number of input bits
		BitW : positive := 9; -- Number of weight bits
		BitO : positive := 20 -- Number of output bits
	);
	port (
		-- Perceptron Inputs/Outputs (-1,1)
		x : IN input_array;
		w : IN weight_array;
		y : OUT std_logic_vector (BitO-1 downto 0);
		-- Basic Pins
		clk : IN std_logic;
		resetn : IN std_logic
	);
end Arithmetic;

architecture internal of Arithmetic is
	
	-- logic_vector to assign bias input to manage its indexes
	signal bias : std_logic_vector (BitW-1 downto 0);
	
	-- signals for the weighted inputs
	signal xw1, xw2, xw3, xw4, xw5, xw6, xw7, xw8, xw9, xw10 : signed ((BitX + BitW)-1 downto 0); -- 17 Bits
	
	-- xAxB is the signal for thew result of A + B
	signal x1x2, x3x4, x5x6, x7x8, x9x10 : std_logic_vector ((BitX + BitW)-1 downto 0); -- 17 Bits
	
	-- concatenation of previous inputs with addition overflow
	signal x1x2_ow, x3x4_ow, x5x6_ow, x7x8_ow, x9x10_ow : std_logic_vector ((BitX + BitW) downto 0); -- 18 Bits
	
	-- x_low is the sum of 1, 2, 3 and 4	
	-- x_mid is the sum of 5, 6 and bias
	-- x_high is the sum of 7, 8, 9, 10
	-- ext_bias is the bit extension of bias
	signal x_low, x_mid, x_high, ext_bias : std_logic_vector ((BitX + BitW) downto 0); -- 18 Bits
	
	-- x_lowhigh is the sum of x_low and x_high
	-- concatenation of previous inputs with addition overflow
	signal x_low_ow, x_high_ow, x_lowhigh : std_logic_vector ((BitX + BitW)+1 downto 0); -- 19 Bits
	
	-- ext_x_mid is the extension of x_mid
	-- x_end is the sum of x_lowhigh and ext_x_mid
	signal x_lowhigh_ow, ext_x_mid, x_end : std_logic_vector ((BitX + BitW)+2 downto 0); -- 20 Bits
	
	-- x_end_trunc the 8 bit truncated version
	signal x_end_trunc : std_logic_vector (BitO-1 downto 0); -- 8 Bits
	
	component N_DFF is
		generic (Nbit : positive);
		port (
			n_d : IN std_logic_vector;
			en : IN std_logic;
			clk : IN std_logic;
			resetn : IN std_logic;
			n_q : OUT std_logic_vector
		);
	end component N_DFF;
	
begin
	
	-- Bias assignment from array
	bias <= w(0);
	
	-- Producing weighted inputs	
	xw1 <= (signed(x(1)) * signed(w(1)));
	xw2 <= (signed(x(2)) * signed(w(2)));
	xw3 <= (signed(x(3)) * signed(w(3)));
	xw4 <= (signed(x(4)) * signed(w(4)));
	xw5 <= (signed(x(5)) * signed(w(5)));
	xw6 <= (signed(x(6)) * signed(w(6)));
	xw7 <= (signed(x(7)) * signed(w(7)));
	xw8 <= (signed(x(8)) * signed(w(8)));
	xw9 <= (signed(x(9)) * signed(w(9)));
	xw10 <= (signed(x(10)) * signed(w(10)));	
	
	-- First 5 adders
	x1x2 <= std_logic_vector(xw1 + xw2);
	x3x4 <= std_logic_vector(xw3 + xw4);
	x5x6 <= std_logic_vector(xw5 + xw6);
	x7x8 <= std_logic_vector(xw7 + xw8);
	x9x10 <= std_logic_vector(xw9 + xw10);
	
	-- Managing first 5 adders overflows and concatenating	
	x1x2_ow <= ((xw1(16) AND xw2(16)) OR (not(x1x2(16)) AND xw1(16)) OR (not(x1x2(16)) AND xw2(16))) & x1x2;
	x3x4_ow <= ((xw3(16) AND xw4(16)) OR (not(x3x4(16)) AND xw3(16)) OR (not(x3x4(16)) AND xw4(16))) & x3x4;
	x5x6_ow <= ((xw5(16) AND xw6(16)) OR (not(x5x6(16)) AND xw5(16)) OR (not(x5x6(16)) AND xw6(16))) & x5x6;
	x7x8_ow <= ((xw7(16) AND xw8(16)) OR (not(x7x8(16)) AND xw7(16)) OR (not(x7x8(16)) AND xw8(16))) & x7x8;
	x9x10_ow <= ((xw9(16) AND xw10(16)) OR (not(x9x10(16)) AND xw9(16)) OR (not(x9x10(16)) AND xw10(16))) & x9x10;	
	
	-- Extending bias befor addition
	ext_bias <=  bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias;
	
	-- Second 3 adders
	x_low <= std_logic_vector(signed(x1x2_ow) + signed(x3x4_ow));
	x_high <= std_logic_vector(signed(x7x8_ow) + signed(x9x10_ow));
	x_mid <= std_logic_vector(signed(x5x6_ow) + signed(ext_bias));
	
	-- Concatenating with overflow bit
	x_low_ow <= ((x1x2_ow(17) AND (x3x4_ow(17))) OR (not(x_low(17)) AND (x3x4_ow(17))) OR (x1x2_ow(17) AND (not(x_low(17))))) & x_low;
	x_high_ow <= ((x7x8_ow(17) AND (x9x10_ow(17))) OR (not(x_high(17)) AND (x7x8_ow(17))) OR (x9x10_ow(17) AND (not(x_high(17))))) & x_high;
	
	-- Second-last adder
	x_lowhigh <= std_logic_vector(signed(x_low_ow) + signed(x_high_ow));
	x_lowhigh_ow <= ((x_low_ow(18) AND x_high_ow(18)) OR (not(x_lowhigh(18)) AND x_high_ow(18)) OR (x_low_ow(18) AND not(x_lowhigh(18)))) & x_lowhigh;
	
	-- Extending x_mid to 20 bits
	ext_x_mid <= x_mid(17) & x_mid(17) & x_mid;
	
	-- Last adder
	x_end <= std_logic_vector(signed(x_lowhigh_ow) + signed(ext_x_mid));
	
	-- Truncation to output
	--x_end_trunc <= x_end(((BitX + BitW)+2) downto (((BitX + BitW)+2) - (BitO-1)));
	
	Y_DFF : N_DFF
		generic map (Nbit => BitO)
		port map (
			n_d => x_end,--_trunc,
			en => '1',
			clk => clk,
			resetn => resetn,
			n_q => y
		);
	
end internal;