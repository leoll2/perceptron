library ieee;
use ieee.std_logic_1164.all;

entity ENT_XNOR is
	port(	
		a : IN std_logic;
		b : IN std_logic;
		z : OUT std_logic
	);
end ENT_XNOR;

architecture internal of ENT_XNOR is
	
begin

	z <= a xnor b;

end internal;