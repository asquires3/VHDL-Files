LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity sel1bit is
	port(i_a,i_b,i_sel : in STD_LOGIC;
			o_c : out STD_LOGIC);
end entity sel1bit;

--sel is 0 get b, sel is 1 get a
architecture basic of sel1bit is
begin
	sel1bit_behaviour : process is
		begin
		o_c <= (i_a NAND i_sel) NAND (i_b NAND (NOT i_sel));
		wait on i_a,i_b,i_sel;
		end process sel1bit_behaviour;
end architecture basic;
	