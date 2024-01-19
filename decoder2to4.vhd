

library ieee;
use ieee.std_logic_1164.all;

entity decoder2to4 is
    port(
        i_sel : in std_logic_vector(1 downto 0);
        i_enable : in std_logic;
        o_value : out std_logic_vector(3 downto 0)
    );
end entity;

architecture basic of decoder2to4 is
  
  begin 
  
  o_value(3) <= (i_sel(1) and i_sel(0)) and i_enable;
  o_value(2) <= (i_sel(1) and not i_sel(0)) and i_enable;
  o_value(1) <= (not i_sel(1) and i_sel(0)) and i_enable;
  o_value(0) <= (not i_sel(1) and not i_sel(0)) and i_enable;
  
end architecture;






