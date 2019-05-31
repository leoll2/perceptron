library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.perceptron_utility_pkg.all;

entity Perceptron is
	port(
		x : IN input_array;
		w : IN weight_array;
		y : OUT std_logic_vector(BitY-1 downto 0);
		-- Basic Pins
		en : IN std_logic;
		clk : IN std_logic;
		resetn : IN std_logic
	);

end Perceptron;

architecture internal of Perceptron is

	signal s_w_out : weight_array;
    signal s_x_out : input_array;
	signal s_arith : std_logic_vector(BitO-1 downto 0);

	component SigmoidLUT is
		port(
			x : IN std_logic_vector;
			y : OUT std_logic_vector;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component SigmoidLUT;

	component Arithmetic is
		port (
			x : IN input_array;
			w : IN weight_array;
			y : OUT std_logic_vector;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Arithmetic;
	
	component Weights is
		port (
			w_in : IN weight_array;
			w_out : OUT weight_array;
			en : IN std_logic;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Weights;
    
    component Inputs is
		port (
			x_in : IN input_array;
			x_out : OUT input_array;
			en : IN std_logic;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Inputs;

begin

    I_Input : Inputs
	port map(
		x_in => x,
		x_out => s_x_out,
		en => en,
		clk => clk,
		resetn => resetn
	);

	I_Weights : Weights
	port map(
		w_in => w,
		w_out => s_w_out,
		en => en,
		clk => clk,
		resetn => resetn
	);
	
	I_Arithmetic : Arithmetic
	port map(
		x => s_x_out,
		w => s_w_out,
		y => s_arith,
		clk => clk,
		resetn => resetn
	);
	
	I_SigmoidLUT : SigmoidLUT
	port map(
		x => s_arith,
		y => y,
		clk => clk,
		resetn => resetn
	);

end internal;