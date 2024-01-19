LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity comparator4bit is
	port(
		i_a,i_b : in std_logic_vector(3 downto 0);
		o_aGreaterEQ : out std_logic
	);
end entity;

architecture rtl of comparator4bit is

	--S is used to represent the same bit, either 1 or 0
	--compares 2 4 bit numbers, treating them as unsigned
	--if a is greater or equal
	begin
	o_aGreaterEQ <= (i_a(3) and not i_b(3)) --a has msb 1 and b doesnt, 1XXX vs 0XXX
				or ((i_a(3) xnor i_b(3)) and i_a(2) and not i_b(2)) --a and b have same msb, different bit 2, S1XX vs S0XX
				or (((i_a(3) xnor i_b(3)) and (i_a(2) xnor i_b(2))) and i_a(1) and not i_b(1)) --SS1X vs SS0X
				or (((i_a(3) xnor i_b(3)) and (i_a(2) xnor i_b(2)) and (i_a(1) xnor i_b(1)) and i_a(0) and not i_b(0))) --SSS1 vs SSS0
				or (((i_a(3) xnor i_b(3)) and (i_a(2) xnor i_b(2)) and (i_a(1) xnor i_b(1)) and (i_a(0) xnor i_b(0)))); --SSSS vs SSSS, same number
end architecture;