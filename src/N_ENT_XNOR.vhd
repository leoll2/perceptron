library ieee;
use ieee.std_logic_1164.all;

entity N_ENT_XNOR is
	generic (Nbit : positive);
	port(	
		n_a : IN std_logic_vector;
		n_b : IN std_logic_vector;
		n_z : OUT std_logic_vector
	);
end N_ENT_XNOR;

architecture internal of N_ENT_XNOR is

	signal s_n_a, s_n_b, s_n_z : std_logic_vector(Nbit-1 downto 0);

	component ENT_XNOR is
		port(	
			a : IN std_logic;
			b : IN std_logic;
			z : OUT std_logic
		);
	end component ENT_XNOR;
	
begin

	s_n_a <= n_a;
	s_n_b <= n_b;

	GEN:
	for i in Nbit-1 downto 0 generate
		NXN: ENT_XNOR
		port map(
			a => s_n_a(i),
			b => s_n_b(i),
			z => s_n_z(i)
		);
	end generate GEN;
	
	n_z <= s_n_z;
	
end internal;