library ieee;
use ieee.std_logic_1164.all;

--sel pins    target baud rate
--000         38400                
--001         19200            
--010         9600              
--011         4800             
--100         2400           
--101         1200        
--110         600        
--111         300        


--incoming clock from the Altera Board is 50MHz

--Working guud

entity BaudGenerator is
    port(
        i_clockIn, i_resetBar : in std_logic;
        i_selPins : in std_logic_vector(2 downto 0);
        o_BClk, o_BClkx8 : out std_logic
    );
end entity;

architecture rtl of BaudGenerator is
  
  signal int_count8Done, int_count81Done, int_BClkx8, int_BClk, int_BClkHold : std_logic;
  signal int_count8Value : std_logic_vector(3 downto 0);
  signal int_decoderValue, int_adderOut, int_currentCount : std_logic_vector (7 downto 0);
  signal int_count81 : std_logic_vector(40 downto 0);
  
	component nJohnsonRingCounter
	  generic(
	   n: integer
	  );
	  port(
	   i_clock, i_enable, i_resetBar, i_resetCount: in std_logic;
	   o_value: out std_logic_vector
	  );
	  end component;
	  
	  component decoder3to8
      port(
        i_sel : in std_logic_vector(2 downto 0);
        i_enable : in std_logic;
        o_value : out std_logic_vector(7 downto 0)
      );
    end component;
	  
	component nFullAdderSubtractor
		generic(n: integer);
		port(
			i_subControl : in std_logic; --1 for subtraction
			i_a : in std_logic_vector;
			i_b : in std_logic_vector;
			o_carryOut : out std_logic;
			o_sumOut : out std_logic_vector;
			o_overflow : out std_logic
		);
	end component;
	  
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
	
		
	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
  
begin
  
   divide81: nJohnsonRingCounter
    generic map(n => 41)
    port map(
      i_clock => i_clockIn,
      i_resetBar => i_resetBar,
      i_enable => '1',
      i_resetCount => int_count81Done,
      o_value => int_count81
    );
    
    int_count81Done <= int_count81(40) and not int_count81(39);
    
  divide256: nFullAdderSubtractor
    generic map(
      n => 8
    )
    port map(
      i_subControl => '0',
      i_a => int_currentCount,
      i_b => "00000001",
      o_sumOut => int_adderOut
  );
  
  
  --int_count8Done <= int_count8Value(3) and not int_count8Value(2);
  int_count8Done <= int_count8Value(2);
  
  divide8: nJohnsonRingCounter
    generic map(n => 4)
    port map(
      i_clock => int_BClkx8,
      i_resetBar => i_resetBar,
      i_enable => '1',
      i_resetCount => int_count8Done,
      o_value => int_count8Value
    );
  
  currentCount: shiftNBit
    generic map(
      n => 8,
      shift => 1
    )
    port map(
      i_clock => int_count81Done,
      i_load => '1',
      i_shift => '0',
      i_resetBar => i_resetBar,
      i_value => int_adderOut,
      o_value => int_currentCount
    );
    
    rateSel: decoder3to8
      port map(
        i_sel => i_selPins,
        i_enable => '1',
        o_value => int_decoderValue
      );
      
      
      int_BClkHold <= int_BClk xor int_count8Done;
      
      BCLkHolder: enARdff_2
        port map(
          i_resetBar => i_resetBar,
          i_clock => int_BClkx8,
          i_enable => '1',
          i_d => int_BClkHold,
          o_q => int_BClk
        );
    
    int_BClkx8 <= (int_decoderValue(7) and int_currentCount(7)) or
                (int_decoderValue(6) and int_currentCount(6)) or 
                (int_decoderValue(5) and int_currentCount(5)) or
                (int_decoderValue(4) and int_currentCount(4)) or
                (int_decoderValue(3) and int_currentCount(3)) or
                (int_decoderValue(2) and int_currentCount(2)) or
                (int_decoderValue(1) and int_currentCount(1)) or
                (int_decoderValue(0) and int_currentCount(0));
                
    o_BClkx8 <= int_BClkx8;
    o_BClk <= int_BClk;
  
  
end architecture;
