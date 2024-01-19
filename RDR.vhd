library ieee;
use ieee.std_logic_1164.all;

entity RDR is
    port(
      i_BClkx8, i_resetBar : in std_logic;
      i_load : in std_logic;
      i_valueIn : in std_logic_vector(7 downto 0);
      o_busOut : out std_logic_vector (7 downto 0)
    );
end entity;

architecture rtl of RDR is
  
  signal int_valueOut : std_logic_vector(7 downto 0);
  
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
  
  reg: shiftNBit
    generic map(
      n => 8,
      shift => 1
    )
    port map(
      i_clock => i_BClkx8,
      i_resetBar => i_resetBar,
      i_load => i_load,
      i_shift => '0',
      i_value => i_valueIn,
      o_value => int_valueOut
    );
    
    o_busOut <= int_valueOut;
  
end architecture;
