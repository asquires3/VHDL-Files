LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity debouncer4BitToVec is
	port(i_clock, i_resetBar,
	     i_msb, i_d2, i_d1, i_lsb : in STD_LOGIC;
			o_value : out STD_LOGIC_VECTOR(3 downto 0));
end entity;
		
architecture rtl of debouncer4BitToVec is
  
  signal int_msb, int_d2, int_d1, int_lsb : std_logic;
  
  component debouncer
    port(
      i_clock : in std_logic;
      i_resetBar : in std_logic;
      i_in : in std_logic;
      o_value : out std_logic
    );
  end component;
  
  begin
    
  DB_MSB : debouncer
    port map(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_in => i_msb,
      o_value => int_msb
    );
    
    DB_d2 : debouncer
    port map(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_in => i_d2,
      o_value => int_d2
    );
    
    DB_d1 : debouncer
    port map(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_in => i_d1,
      o_value => int_d1
    );
    
    DB_LSB : debouncer
    port map(
      i_clock => i_clock,
      i_resetBar => i_resetBar,
      i_in => i_lsb,
      o_value => int_lsb
    );
    
    o_value <= int_msb & int_d2 & int_d1 & int_lsb;
    
  end architecture rtl;