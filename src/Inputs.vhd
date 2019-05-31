library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity Inputs is
	port (
		x_in : IN input_array;
		x_out : OUT input_array;
		-- Basic Pins
		en : IN std_logic;
		clk : IN std_logic;
		resetn : IN std_logic
	);
end Inputs;

architecture internal of Inputs is
		
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
	for i IN 1 to RegX generate
		X_DFF : N_DFF
		generic map (Nbit => BitX)
		port map (
			n_d => x_in(i),
			en => en,
			clk => clk,
			resetn => resetn,
			n_q => x_out(i)
		);
	end generate GEN;
	
end internal;