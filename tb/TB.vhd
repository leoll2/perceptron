library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vector_array_pkg.all;

entity TB is
end TB;

architecture bhv of TB is

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
	signal n_en_tb : std_logic_vector(10 downto 0) := "11111111111";
	signal x_tb : input_array;
	signal w_tb : weight_array;
    signal y_tb : std_logic_vector(15 downto 0);
    -----------------------------------------------------------------------------------
    -- Component to test (DUT) declaration
    -----------------------------------------------------------------------------------
	component Perceptron is
		port(
			x : IN input_array;
			w : IN weight_array;
			y : OUT std_logic_vector;
			n_en : IN std_logic_vector;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Perceptron;

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;
	x_tb <= (others => "10000000"); --(others => "00000001"); --(1 => "00100000", others => "00000001");
	w_tb <= (others => "100000000"); --(others => "000000001"); --(1 => "101000000", others => "000011111");
	resetn_tb <= '0' after T_RESET;

	TB_Perceptron : Perceptron
		port map(
			x => x_tb,
			w => w_tb,
			y => y_tb,
			n_en => n_en_tb,
			clk => clk_tb,
			resetn => resetn_tb
		);

	process(clk_tb)	
		variable t : integer := 0;		
	begin	
		if (rising_edge(clk_tb)) then
			case(t) is
				when 3 => n_en_tb <= (others => '0');
				when 10 => end_sim <= '0';
				when others => null;			
			end case;
			t := t + 1;
		end if;		
	end process;
	
end bhv;