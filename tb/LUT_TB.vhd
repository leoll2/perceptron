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
				when 0 => x_tb <= "00000" & "00000000";
				when 2 => end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
end bhv;