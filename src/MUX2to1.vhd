library ieee;
use ieee.std_logic_1164.all;

entity MUX_2to1 is
	port(	
		x : IN std_logic;
		y : IN std_logic;
		c : IN std_logic;
		z : OUT std_logic
	);
end MUX_2to1;

architecture internal of MUX_2to1 is

begin

	z <= (x AND not(c)) OR (y AND c);
	
end internal;