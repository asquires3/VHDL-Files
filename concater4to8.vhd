

library ieee;
use ieee.std_logic_1164.all;

entity concater4to8 is 
  port(
    i_a, i_b : in std_logic_vector(3 downto 0);
    o_out :out std_logic_vector(7 downto 0)
  );
end entity;
-- concacts out as a then b a3a2a1a0b3b2b1b0
architecture rtl of concater4to8 is
	begin
		o_out(7) <= i_a(3);
		o_out(6) <= i_a(2);
		o_out(5) <= i_a(1);
		o_out(4) <= i_a(0);
		o_out(3) <= i_b(3);
		o_out(2) <= i_b(2);
		o_out(1) <= i_b(1);
		o_out(0) <= i_b(0);
end architecture;