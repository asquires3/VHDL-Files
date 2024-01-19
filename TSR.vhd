library ieee;
use ieee.std_logic_1164.all;

entity TSR is
    port(
      i_BClk, i_resetBar : in std_logic;
      i_value : in std_logic_vector(7 downto 0);
      i_load, i_shift : in std_logic;
      o_value : out std_logic_vector(9 downto 0);
      o_TxD : out std_logic
    );
end entity;

architecture rtl of TSR is
  
  signal int_valueIn, int_valueOut : std_logic_vector(9 downto 0);
  signal int_enable : std_logic;
  
	component enARdff_2
       port(
          i_resetBar : in std_logic;
          i_d : in std_logic;
          i_enable : in std_logic;
          i_clock : in std_logic;
          o_q, o_qBar : out std_logic);
    end component;
    
	component enARdFF_2_high
       port(
          i_resetBar : in std_logic;
          i_d : in std_logic;
          i_enable : in std_logic;
          i_clock : in std_logic;
          o_q, o_qBar : out std_logic);
    end component;
  
begin
  
  --adds 01 to the end, 1 for the stop bit and also active high
  --0 is used for the start bit and will become high after the first shift
    
    int_enable <= i_load or i_shift;
    
	 --this is just used to caluculate shifts
    createInput: process(i_value, int_valueOut, i_shift, i_load)
      begin
        int_valueIn(0) <= (i_shift AND int_valueOut(1) and not i_load) or (i_load and '1') or (not i_shift and int_valueOut(0) and not i_load);
        int_valueIn(1) <= (i_shift AND int_valueOut(2) and not i_load) or (i_load and '0') or (not i_shift and int_valueOut(1) and not i_load);
        
        int_valueIn(9) <= (i_shift and int_valueOut(0) and not i_load) or (i_load and i_value(7)) or (not i_shift and int_valueOut(9) and not i_load);
    
        for k in 0 to 6 loop
          int_valueIn(k+2) <= (i_shift AND int_valueOut(k+3) and not i_load) or (i_load and i_value(k)) or (not i_shift and int_valueOut(k+2) and not i_load);
        end loop;
      end process;
      
    b_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_valueIn(0),
				i_enable => int_enable,
				i_clock => i_BClk,
				o_q => int_valueOut(0)
			);
			
  	bits: for i in 1 to 9 generate
		b_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_valueIn(i),
				i_enable => int_enable,
				i_clock => i_BClk,
				o_q => int_valueOut(i)
			);
		end generate bits;
    
  o_value <= int_valueOut;
  o_TxD <= int_valueOut(0);
  
  
end architecture;
