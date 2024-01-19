library ieee;
use ieee.std_logic_1164.all;

entity TDR is
    port(
        i_load, i_resetBar, i_BClk, i_select, i_clear : in std_logic;
        i_busIn : in std_logic_vector(7 downto 0);
        o_valueOut : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of TDR is
  
  signal int_loadTDR : std_logic;
  signal int_valueOut, int_valueIn, int_clearExpanded : std_logic_vector(7 downto 0);
  
 	component shiftNBit
		generic(
			n: integer;
			shift: integer
		);
		port(
			i_clock, i_load, i_shift, i_resetBar : in std_logic;
      i_value : in std_logic_vector;
      o_value : out std_logic_vector
		);
	end component;
  
begin
  
  expansion: process(i_clear)
    begin
      int_clearExpanded <= (others => not i_clear);
    end process;
    
  int_valueIn <= i_busIn and int_clearExpanded;
  int_loadTDR <= i_load and i_select;
  
  reg: shiftNBit
    generic map(
      n => 8,
      shift => 1
    )
    port map(
      i_clock => i_BClk,
      i_resetBar => i_resetBar,
      i_load => int_loadTDR,
      i_shift => '0',
      i_value => int_valueIn,
      o_value => int_valueOut
    );
    
    o_valueOut <= int_valueOut;
    
end architecture;