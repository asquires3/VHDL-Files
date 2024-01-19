library ieee;
use ieee.std_logic_1164.ALL;

entity ssLight is
	port(
		i_a: in std_logic_vector(5 downto 0);
		o_light: out std_logic_vector(2 downto 0)
	);
end entity;

architecture basic of ssLight is
	begin
	o_light(2) <= i_a(4);
	o_light(1) <= i_a(5);
	o_light(0) <= i_a(0) or i_a(1) or i_a(2) or i_a(3);
end architecture;