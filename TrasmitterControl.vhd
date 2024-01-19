library ieee;
use ieee.std_logic_1164.all;

entity TransmitterControl is
    port(
      i_BClk, i_resetBar, i_TDRE, i_select, i_loadTDR : in std_logic;
      o_setTDRE, o_resetTDRE : out std_logic;
      o_loadTSR, o_shiftTSR, o_clearTDR : out std_logic;
      
      o_curState : out std_logic_vector(3 downto 0);
      o_shiftCount : out std_logic_vector(4 downto 0)
    );
end entity;

architecture rtl of TransmitterControl is
  
  signal int_curState, int_nextState : std_logic_vector(3 downto 0);
  signal int_shiftCount : std_logic_vector(4 downto 0);
  
  signal int_setTDRE, int_resetTDRE, int_loadTSR, int_shiftTSR : std_logic;
  signal int_enableCountShifts, int_resetShifts : std_logic;
  signal int_allowEntry3 : std_logic;


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
    
	component nJohnsonRingCounter
	  generic(
	   n: integer
	  );
	  port(
	   i_clock, i_enable, i_resetBar, i_resetCount: in std_logic;
	   o_value: out std_logic_vector
	  );
	  end component;
  
begin
    
    --Wait for not TDRE, if a new value is entered into TDR
    int_nextState(0) <= int_curState(3) or (int_curState(0) and not (i_select and i_loadTDR));
    --Load the value into TSR
    int_nextState(1) <= int_curState(0) and i_loadTDR and i_select; 
    --Start Shifting, onyl do it 10 times
    int_nextState(2) <= int_curState(1) or (int_curState(2) and not int_allowEntry3);
    --Holding state, change later?
    int_nextState(3) <= int_curState(2) and int_allowEntry3;
    
    int_allowEntry3 <= int_shiftCount(4) and not int_shiftCount(3) and not int_shiftCount(2) and not int_shiftCount(1) and not int_shiftCount(0);
  
    int_enableCountShifts <= int_curState(2);
    int_resetShifts <= int_curState(0);
    
    	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_BClk,
				o_q => int_curState(0)
			);
			
  	states: for i in 1 to 3 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_BClk,
				o_q => int_curState(i)
			);
		end generate states;
		
	countShifts: nJohnsonRingCounter
    generic map(
      n => 5
    )
    port map(
      i_clock => i_BClk,
      i_enable => int_enableCountShifts,
      i_resetBar => i_resetBar,
      i_resetCount => int_resetShifts,
      o_value => int_shiftCount
    );
    
    o_resetTDRE <= int_curState(1);
    o_setTDRE <= int_curState(0);
    
    o_loadTSR <= int_curState(1);
    o_clearTDR <= int_curState(3);
    o_shiftTSR <= int_curState(2);
    
    o_curState <= int_curState;
    o_shiftCount <= int_shiftCount;
		
end architecture;
