
--Only enables the output if enable is high, otherwise 0000

library ieee;
use ieee.std_logic_1164.all;

entity enable8bit is
    port(
        i_value : in std_logic_vector(7 downto 0);
        i_enable : in std_logic;
        o_value : out std_logic_vector(7 downto 0)
    );
end entity;

architecture basic of enable8bit is
  
  begin 
  
  o_value(7) <= i_value(7) and i_enable;
  o_value(6) <= i_value(6) and i_enable;
  o_value(5) <= i_value(5) and i_enable;
  o_value(4) <= i_value(4) and i_enable;
  o_value(3) <= i_value(3) and i_enable;
  o_value(2) <= i_value(2) and i_enable;
  o_value(1) <= i_value(1) and i_enable;
  o_value(0) <= i_value(0) and i_enable;
  
end architecture;









