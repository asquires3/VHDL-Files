library ieee;
use ieee.std_logic_1164.all;

ENTITY isZeroFour IS
  PORT(
	    i_a : in std_logic_vector(3 downto 0);
		  o_isZero : out std_logic
	  );
END ENTITY isZeroFour;

architecture basic of isZeroFour is
	begin
	o_isZero <= not (i_a(3) or i_a(2) or i_a(1) or i_a(0));
end architecture;