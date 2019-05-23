library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity Arithmetic is
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
	signal xw1, xw2, xw3, xw4, xw5, xw6, xw7, xw8, xw9, xw10 : std_logic_vector ((BitX + BitW)-1 downto 0); -- 17 Bits
	
	-- xAxB is the signal for thew result of A + B
	signal x1x2, x3x4, x5x6, x7x8, x9x10  : std_logic_vector ((BitX + BitW) downto 0); -- 18 Bits
	
	-- x_low is the sum of 1, 2, 3 and 4
	-- x_mid is the sum of 5, 6 and bias
	-- x_high is the sum of 7, 8, 9, 10
	-- ext_bias is the bit extension of bias
	signal x_low, x_mid, x_high, ext_bias : std_logic_vector ((BitX + BitW)+1 downto 0); -- 19 Bits
		
	-- ext_x_mid is the extension of x_mid
	-- x_end is the sum of x_lowhigh and ext_x_mid
	signal x_lowhigh, ext_x_mid, x_end : std_logic_vector ((BitX + BitW)+2 downto 0); -- 20 Bits
	
	-- x_end_trunc the 8 bit truncated version
	signal x_end_trunc : std_logic_vector (BitO-1 downto 0); -- 13 Bits
	
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
	xw1 <= std_logic_vector(signed(x(1)) * signed(w(1)));
	xw2 <= std_logic_vector(signed(x(2)) * signed(w(2)));
	xw3 <= std_logic_vector(signed(x(3)) * signed(w(3)));
	xw4 <= std_logic_vector(signed(x(4)) * signed(w(4)));
	xw5 <= std_logic_vector(signed(x(5)) * signed(w(5)));
	xw6 <= std_logic_vector(signed(x(6)) * signed(w(6)));
	xw7 <= std_logic_vector(signed(x(7)) * signed(w(7)));
	xw8 <= std_logic_vector(signed(x(8)) * signed(w(8)));
	xw9 <= std_logic_vector(signed(x(9)) * signed(w(9)));
	xw10 <= std_logic_vector(signed(x(10)) * signed(w(10)));	
	
	-- First 5 adders
	x1x2 <= std_logic_vector(signed(xw1(16) & xw1) + signed(xw2(16) & xw2));
	x3x4 <= std_logic_vector(signed(xw3(16) & xw3) + signed(xw4(16) & xw4));
	x5x6 <= std_logic_vector(signed(xw5(16) & xw5) + signed(xw6(16) & xw6));
	x7x8 <= std_logic_vector(signed(xw7(16) & xw7) + signed(xw8(16) & xw8));
	x9x10 <= std_logic_vector(signed(xw9(16) & xw9) + signed(xw10(16) & xw10));
	
	-- Extending bias before addition
	ext_bias <=  bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias(8) & bias;
	
	-- Second 3 adders
	x_low <= std_logic_vector(signed(x1x2(17) & x1x2) + signed(x3x4(17) & x3x4));
	x_high <= std_logic_vector(signed(x7x8(17) & x7x8) + signed(x9x10(17) & x9x10));
	x_mid <= std_logic_vector(signed(x5x6(17) & x5x6) + signed(ext_bias));
	
	-- Second-last adder
	x_lowhigh <= std_logic_vector(signed(x_low(18) & x_low) + signed(x_high(18) & x_high));
	
	-- Extending x_mid to 20 bits
	ext_x_mid <= x_mid(18) & x_mid;
	
	-- Last adder
	x_end <= std_logic_vector(signed(x_lowhigh) + signed(ext_x_mid));
	
	-- Truncation to output
	x_end_trunc <= x_end(((BitX + BitW)+2) downto (((BitX + BitW)+2) - (BitO-1)));
	
	Y_DFF : N_DFF
		generic map (Nbit => BitO)
		port map (
			n_d => x_end_trunc,
			en => '1',
			clk => clk,
			resetn => resetn,
			n_q => y
		);
	
end internal;