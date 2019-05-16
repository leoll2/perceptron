library ieee;
use ieee.std_logic_1164.all;

entity N_DFF is
	generic (Nbit : positive);
	port(	
		n_d : IN std_logic_vector;
		en : IN std_logic;
		clk : IN std_logic;
		resetn : IN std_logic;
		n_q : OUT std_logic_vector
	);
end N_DFF;

architecture internal of N_DFF is
		
	component DFF is 
		port(
			d : IN std_logic;
			en : IN std_logic;
			clk : IN std_logic;
			resetn : IN std_logic;
			q : OUT std_logic
		);
	end component DFF;
	
begin

	GEN: 
	for i IN 0 to Nbit-1 generate
		I_DFF : DFF 
		port map (
			d => n_d(i),
			en => en,
			clk => clk,
			resetn => resetn,
			q => n_q(i)
		);
	end generate GEN;
	
end internal;