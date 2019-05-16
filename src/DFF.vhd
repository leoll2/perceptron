library ieee;
use ieee.std_logic_1164.all;

entity DFF is 
	port(
		d : IN std_logic;
		en : IN std_logic;
		clk : IN std_logic;
		resetn : IN std_logic;
		q : OUT std_logic
	);
end DFF;

architecture internal of DFF is
begin
	dff_p0: process(resetn, clk)
		begin
			if (resetn = '1') then -- Directed to work with Vivado
				q <= '0';
			elsif (rising_edge(clk)) then
				if en = '1' then 
					q <= d;
				end if;
			end if;
		end process;
end internal;