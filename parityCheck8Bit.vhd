LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity parityCheck8Bit is
	port(i_in : in STD_LOGIC_VECTOR(7 downto 0);
			 o_value : out STD_LOGIC);
			
end entity parityCheck8Bit;

architecture basic of parityCheck8Bit is
  begin
    o_value <= (((i_in(7) xnor i_in(6)) xnor (i_in(5) xnor i_in(4))) xnor ((i_in(3) xnor i_in(2)) xnor (i_in(1) xnor i_in(0))));
end architecture basic;