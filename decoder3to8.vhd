
library ieee;
use ieee.std_logic_1164.all;

entity decoder3to8 is
    port(
        i_sel : in std_logic_vector(2 downto 0);
        i_enable : in std_logic;
        o_value : out std_logic_vector(7 downto 0)
    );
end entity;

architecture basic of decoder3to8 is
  
  begin 
  
  o_value(7) <= (i_sel(2) and i_sel(1) and i_sel(0)) and i_enable;
  o_value(6) <= (i_sel(2) and i_sel(1) and not i_sel(0)) and i_enable;
  o_value(5) <= (i_sel(2) and not i_sel(1) and i_sel(0)) and i_enable;
  o_value(4) <= (i_sel(2) and not i_sel(1) and not i_sel(0)) and i_enable;
  o_value(3) <= (not i_sel(2) and i_sel(1) and i_sel(0)) and i_enable;
  o_value(2) <= (not i_sel(2) and i_sel(1) and not i_sel(0)) and i_enable;
  o_value(1) <= (not i_sel(2) and not i_sel(1) and i_sel(0)) and i_enable;
  o_value(0) <= (not i_sel(2) and not i_sel(1) and not i_sel(0)) and i_enable;
  
end architecture;





