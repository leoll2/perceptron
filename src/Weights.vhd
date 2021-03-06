library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity Weights is
	port (
		-- The Bias weight is the number 0
		w_in : IN weight_array;
		w_out : OUT weight_array;
		-- Basic Pins
		en : IN std_logic;
		clk : IN std_logic;
		resetn : IN std_logic
	);
end Weights;

architecture internal of Weights is
		
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

	GEN:
	for i IN 0 to RegW-1 generate
		W_DFF : N_DFF
		generic map (Nbit => BitW)
		port map (
			n_d => w_in(i),
			en => en,
			clk => clk,
			resetn => resetn,
			n_q => w_out(i)
		);
	end generate GEN;
	
end internal;