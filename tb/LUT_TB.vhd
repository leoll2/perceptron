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
				when 0 => x_tb <= "00000" & "00000000"; 	-- Fractional Value:  0/256 		| Actual Value: 0
				when 2 => x_tb <= "11111" & "11111111"; 	-- Fractional Value:  -1/256 		| Actual Value: -0,00390625
				when 4 => x_tb <= "00000" & "00000001"; 	-- Fractional Value:  1/256 		| Actual Value: 0,00390625
				when 6 => x_tb <= "01111" & "11111111"; 	-- Fractional Value:  4095/256 		| Actual Value: 15,99609375
				when 8 => x_tb <= "01111" & "11111110"; 	-- Fractional Value:  4094/256 		| Actual Value: 15,9921875
				when 10 => x_tb <= "10000" & "00000000"; 	-- Fractional Value:  -4096/256 	| Actual Value: -16
				when 12 => x_tb <= "10000" & "00000001"; 	-- Fractional Value:  -4095/256 	| Actual Value: -15,99609375
				when 14 => x_tb <= "00001" & "10101010"; 	-- Fractional Value:  426/256 		| Actual Value: 1,6640625
				when 16 => x_tb <= "11110" & "10101010"; 	-- Fractional Value:  -342/256 		| Actual Value: -1,3359375
				when 18 => x_tb <= "00010" & "11001100"; 	-- Fractional Value:  716/256 		| Actual Value: 2,796875
				when 20 => end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
end bhv;