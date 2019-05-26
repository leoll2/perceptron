library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity Arithmetic_TB is
end Arithmetic_TB;

architecture bhv of Arithmetic_TB is

	-----------------------------------------------------------------------------------
    -- Testbench constants
    -----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns;
	constant T_RESET : time := 25 ns;
	-----------------------------------------------------------------------------------
    -- Testbench signals
    -----------------------------------------------------------------------------------
	signal clk_tb : std_logic := '0';
	signal resetn_tb : std_logic := '1';
	signal end_sim : std_logic := '1';
	signal x_tb : input_array := (others => "00000000");
	signal w_tb : weight_array := (others => "000000000");
    signal y_tb : std_logic_vector(BitO-1 downto 0);
    -----------------------------------------------------------------------------------
    -- Component to test (DUT) declaration
    -----------------------------------------------------------------------------------
	component Arithmetic is
		port (
			-- Perceptron Inputs/Outputs (-1,1)
			x : IN input_array;
			w : IN weight_array;
			y : OUT std_logic_vector (BitO-1 downto 0);
			-- Basic Pins
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Arithmetic;

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;
	resetn_tb <= '0' after T_RESET;

	TB_Arithmetic : Arithmetic
		port map(
			x => x_tb,
			w => w_tb,
			y => y_tb,
			clk => clk_tb,
			resetn => resetn_tb
		);

	process(clk_tb)	
		variable t : integer := 0;		
	begin	
		if (rising_edge(clk_tb)) then
			case(t) is
				when 1 => 
					x_tb <= (others => "10000000");
					w_tb <= (others => "100000000");
				when 10 => 
					end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
	
end bhv;