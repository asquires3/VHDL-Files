
library ieee;
use ieee.std_logic_1164.all;

ENTITY fourbitadder IS

  PORT(
	    i_carryIn : in std_logic;
	    i_a : in std_logic_vector(3 downto 0);
	    i_b : in std_logic_vector(3 downto 0);
	    o_carryOut : out std_logic;
	    o_SumOut : out std_logic_vector(3 downto 0)
	  );
	  
END ENTITY fourbitadder;

architecture rtl of fourbitadder is

signal int_Sum, int_CarryOut : STD_LOGIC_VECTOR (3 downto 0);

COMPONENT oneBitAdder
	PORT(
		i_CarryIn		: IN	STD_LOGIC;
		i_Ai, i_Bi		: IN	STD_LOGIC;
		o_Sum, o_CarryOut	: OUT	STD_LOGIC);
	END COMPONENT;
	
BEGIN

lsb: oneBitAdder
      PORT MAP(
            i_CarryIn => i_carryIn,
            i_Ai => i_a(0),
            i_Bi => i_b(0),
            o_sum => int_Sum(0),
            o_CarryOut => int_CarryOut(0));

b1: oneBitAdder
      PORT MAP(
            i_CarryIn => int_CarryOut(0),
            i_Ai => i_a(1),
            i_Bi => i_b(1),
            o_sum => int_Sum(1),
            o_CarryOut => int_CarryOut(1));


b2: oneBitAdder
      PORT MAP(      
            i_CarryIn => int_CarryOut(1),
            i_Ai => i_a(2),
            i_Bi => i_b(2),
            o_sum => int_Sum(2),
            o_CarryOut => int_CarryOut(2));


msb: oneBitAdder
      PORT MAP(
            i_CarryIn => int_CarryOut(2),
            i_Ai => i_a(3),
            i_Bi => i_b(3),
            o_sum => int_Sum(3),
            o_CarryOut => int_CarryOut(3));


o_SumOut <= int_Sum;
o_carryOut <= int_CarryOut(3);

end rtl;
