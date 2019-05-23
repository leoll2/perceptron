library ieee;
use ieee.std_logic_1164.all;

entity N_MUX_2to1 is
	generic (Nbit : positive);
	port(	
		n_x : IN std_logic_vector;
		n_y : IN std_logic_vector;
		c : IN std_logic;
		n_z : OUT std_logic_vector
	);
end N_MUX_2to1;

architecture internal of N_MUX_2to1 is
	
	component MUX_2to1 is
		port(	
			x : IN std_logic;
			y : IN std_logic;
			c : IN std_logic;
			z : OUT std_logic
		);
	end component;

begin

	GEN:
	for i in 0 to Nbit-1 generate
		MyMUX: MUX_2to1 
			port map(n_x(i), n_y(i), c, n_z(i));
	end generate GEN;
	
end internal;