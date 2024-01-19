library ieee;
use ieee.std_logic_1164.all;

ENTITY isZeroTwo IS
  PORT(
	    i_a : in std_logic_vector(1 downto 0);
		  o_isZero : out std_logic
	  );
END ENTITY isZeroTwo;

architecture basic of isZeroTwo is
	begin
	o_isZero <= not (i_a(1) or i_a(0));
end architecture;
