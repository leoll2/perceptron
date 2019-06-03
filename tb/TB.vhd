library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity TB is
end TB;

architecture bhv of TB is

	-----------------------------------------------------------------------------------
    -- Testbench constants
    -----------------------------------------------------------------------------------
	constant T_CLK   : time := 10 ns;
	constant T_RESET : time := 15 ns;
	-----------------------------------------------------------------------------------
    -- Testbench signals
    -----------------------------------------------------------------------------------
	signal clk_tb : std_logic := '0';
	signal resetn_tb : std_logic := '1';
	signal end_sim : std_logic := '1';
	signal en_tb : std_logic := '0';
	signal x_tb : input_array := (others => "00000000");
	signal w_tb : weight_array := (others => "000000000");
    signal y_tb : std_logic_vector(BitY-1 downto 0);
    -----------------------------------------------------------------------------------
    -- Component to test (DUT) declaration
    -----------------------------------------------------------------------------------
	component Perceptron is
		port(
			x : IN input_array;
			w : IN weight_array;
			y : OUT std_logic_vector;
			en : IN std_logic;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Perceptron;

begin

	clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;
	resetn_tb <= '0' after T_CLK + (T_CLK / 4);

	TB_Perceptron : Perceptron
		port map(
			x => x_tb,
			w => w_tb,
			y => y_tb,
            en => en_tb,
			clk => clk_tb,
			resetn => resetn_tb
		);

	process(clk_tb)	
		variable t : integer := 0;		
	begin	
		if (rising_edge(clk_tb)) then
			case(t) is
				-- To get represented values divide 'Value' by 2^7 (in case of x_tb) or by 2^8 (in case of w_tb)
				when 0 =>
					x_tb <= (others => "10000000"); -- Value: -128
					w_tb <= (0 => "100000000", others => "011111111"); -- Value: 255, Bias: -256
                    en_tb <= '1';
                when 1 =>
                    en_tb <= '0';
                when 5 => 
					x_tb <= (others => "01000000"); -- Value: 64
					w_tb <= (others => "110000000"); -- Value: -128
                    en_tb <= '1';
                when 6 =>
                    en_tb <= '0';
                when 10 => 
					x_tb <= (others => "00000000"); -- Value: 0
					w_tb <= (others => "000000000"); -- Value: 0
                    en_tb <= '1';
                when 11 =>
                    en_tb <= '0';
                when 15 => 
					x_tb <= (others => "01000000"); -- Value: 64
					w_tb <= (others => "010000000"); -- Value: 128
                    en_tb <= '1';
                when 16 =>
                    en_tb <= '0';
                when 20 =>
					x_tb <= (others => "10000000"); -- Value: -128
					w_tb <= (0 => "011111111", others => "100000000"); -- Value: -256, Bias: 255
                    en_tb <= '1';
                when 21 =>
                    en_tb <= '0';
                when 25 => 
					end_sim <= '0';		
                when others =>
                    null;		
			end case;
			t := t + 1;
		end if;		
	end process;
	
end bhv;