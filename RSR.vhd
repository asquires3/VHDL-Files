library ieee;
use ieee.std_logic_1164.all;

entity RSR is
    port(
        i_load, i_shift, i_resetBar, i_BClkx8 : in std_logic;
        i_RxD : in std_logic;
        o_value : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of RSR is
  
  signal int_RSRValue, int_appended : std_logic_vector(7 downto 0);
  
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
	
	component nBitOrrer
	 generic(
	   n: integer
	 );
	 port(
	   i_a, i_b : in std_logic_vector;
	   o_out : out std_logic_vector
	 );
	 end component;
  
begin
  
  appender: process(int_RSRValue, i_RxD)
    begin
      int_appended <= i_RxD & int_RSRValue(6 downto 0);
    end process;

  
  reg: shiftNBit
    generic map(
      n => 8,
      shift => 1
    )
    port map(
        i_clock => i_BCLkx8,
        i_resetBar => i_resetBar,
        i_load => i_load,
        i_shift => i_shift,
        i_value => int_appended,
        o_value => int_RSRValue        
    );
    
    --Change to 
    --o_value <= '0' & int_RSRValue(7 downto 1);
    --to remove parity
    o_value <= int_RSRValue;
  
end architecture;
