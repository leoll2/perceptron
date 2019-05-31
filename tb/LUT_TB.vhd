library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity LUT_TB is
end LUT_TB;

architecture bhv of LUT_TB is

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
	signal x_tb : std_logic_vector(BitO-1 downto 0) := (others => '0');
    signal y_tb : std_logic_vector(BitY-1 downto 0);
    -----------------------------------------------------------------------------------
    -- Component to test (DUT) declaration
    -----------------------------------------------------------------------------------
	component SigmoidLUT is
		port(
			x : IN std_logic_vector;
			y : OUT std_logic_vector;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component SigmoidLUT;

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;
	resetn_tb <= '0' after T_CLK + (T_CLK / 4);

	I_SigmoidLUT : SigmoidLUT
	port map(
		x => x_tb,
		y => y_tb,
		clk => clk_tb,
		resetn => resetn_tb
	);

	process(clk_tb)	
		variable t : integer := 0;		
	begin
		if (rising_edge(clk_tb)) then
			case(t) is
				when 0 => x_tb <= "00000" & "000000000"; 	-- Fractional Value:  0/512 		| Actual Value: 0				| Expected Result: 
				when 2 => x_tb <= "11111" & "111111111"; 	-- Fractional Value:  -1/512 		| Actual Value: -0,001953125	| Expected Result: 
				when 4 => x_tb <= "00000" & "000000001"; 	-- Fractional Value:  1/512 		| Actual Value: 0,001953125		| Expected Result: 
				when 6 => x_tb <= "01111" & "111111111"; 	-- Fractional Value:  8191/512 		| Actual Value: 15,998046875	| Expected Result: 
				when 8 => x_tb <= "01111" & "111111110"; 	-- Fractional Value:  8190/512 		| Actual Value: 15,998046875	| Expected Result: 
				when 10 => x_tb <= "10000" & "000000000"; 	-- Fractional Value:  -8192/512 	| Actual Value: -16				| Expected Result: 
				when 12 => x_tb <= "10000" & "000000001"; 	-- Fractional Value:  -8191/512 	| Actual Value: -15,998046875	| Expected Result: 
				when 14 => x_tb <= "00001" & "101010101"; 	-- Fractional Value:  853/512 		| Actual Value: 1,666015625		| Expected Result: 
				when 16 => x_tb <= "11110" & "101010101"; 	-- Fractional Value:  -683/512 		| Actual Value: -1,333984375	| Expected Result: 
				when 18 => x_tb <= "00010" & "110011001"; 	-- Fractional Value:  1433/512 		| Actual Value: 2,798828125     | Expected Result: 
				when 20 => end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
end bhv;