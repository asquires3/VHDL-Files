--Only enables the output if enable is high, otherwise 0000

library ieee;
use ieee.std_logic_1164.all;

entity enable4bit is
    port(
        i_value : in std_logic_vector(3 downto 0);
        i_enable : in std_logic;
        o_value : out std_logic_vector(3 downto 0)
    );
end entity;

architecture basic of enable4bit is
  
  begin 
  
  o_value(3) <= i_value(3) and i_enable;
  o_value(2) <= i_value(2) and i_enable;
  o_value(1) <= i_value(1) and i_enable;
  o_value(0) <= i_value(0) and i_enable;
  
end architecture;








