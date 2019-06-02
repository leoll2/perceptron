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
	resetn_tb <= '0' after T_CLK + (T_CLK / 4);

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
			-- To get represented values divide Value by 2^8 (in case of x_tb) or by 2^9 (in case of w_tb)
				when 0 =>
					x_tb <= (others => "00000000"); -- Value: 0
					w_tb <= (others => "000000000"); -- Value: 0
				when 1 =>
					x_tb <= (others => "00000001"); -- Value: 1
					w_tb <= (0 => "000000000", others => "000000001"); -- Value: 1
				when 2 => 
					x_tb <= (others => "11111111"); -- Value: -1
					w_tb <= (0 => "000000000", others => "111111111"); -- Value: -1
				when 3 => 
					x_tb <= (others => "01111111"); -- Value: 127
					w_tb <= (others => "011111111"); -- Value: 255
				when 4 => 
					x_tb <= (others => "10000000"); -- Value: -128
					w_tb <= (0 => "011111111", others => "100000000"); -- Value: -256, Bias: 255
				when 5 => 
					x_tb <= (others => "10000000"); -- Value: -128
					w_tb <= (0 => "100000000", others => "011111111"); -- Value: 255
				when 6 => 
					x_tb <= (others => "01111111"); -- Value: 127
					w_tb <= (others => "100000000"); -- Value: -256
				when 7 => 
					x_tb <= (1 => "00010101", others => "00000000"); -- Value: 1 => 23
					w_tb <= (1 => "000000011", others => "000000000"); -- Value: 1 => 3
				when 8 => 
					x_tb <= (1 => "00010101", 2 => "00000001", others => "00000000"); -- Value: 1 => 23, 2 => 1
					w_tb <= (1 => "000000011", 2 => "000000001", others => "000000000"); -- Value: 1 => 3, 2 => 1
				when 9 => 
					x_tb <= (1 => "01000000", 2 => "01000000", 3 => "01000000", others => "00000000"); -- Value: 1, 2, 3 => 64
					w_tb <= (1 => "010000000", 2 => "010000000", 3 => "010000000", others => "000000000"); -- Value: 1, 2, 3 => 128
				when 10 => 
					end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
	
end bhv;