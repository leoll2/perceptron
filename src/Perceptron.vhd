library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vector_array_pkg.all;

entity Perceptron is
	generic (
		RegN : positive := 11 -- Number of weights
	);
	port(
		x : IN input_array;
		w : IN weight_array;
		y : OUT std_logic_vector(7 downto 0);
		-- STD_Vector of enablers
		n_en : IN std_logic_vector (RegN-1 downto 0);
		-- Basic Pins
		clk : IN std_logic;
		resetn : IN std_logic
	);

end Perceptron;

architecture internal of Perceptron is

	signal s_w_out : weight_array;
	signal s_y_lut : std_logic_vector(19 downto 0);

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
			n_en : IN std_logic_vector;
			clk : IN std_logic;
			resetn : IN std_logic
		);
	end component Weights;

begin

	I_Weights : Weights
	port map(
		w_in => w,
		w_out => s_w_out,
		n_en => n_en,
		clk => clk,
		resetn => resetn
	);
	
	I_Arithmetic : Arithmetic
	port map(
		x => x,
		w => s_w_out,
		y => s_y_lut,
		clk => clk,
		resetn => resetn
	);
	
	I_SigmoidLUT : SigmoidLUT
	port map(
		x => s_y_lut,
		y => y,
		clk => clk,
		resetn => resetn
	);

end internal;