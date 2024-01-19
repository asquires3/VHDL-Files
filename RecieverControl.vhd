library ieee;
use ieee.std_logic_1164.all;

entity RecieverControl is
    port(
        i_BClkx8, i_resetBar, i_select : in std_logic;
        i_RDRF, i_OE, i_FE : in std_logic;
        i_RxD : in std_logic;
        o_setRDRF, o_resetRDRF, o_setOE, o_resetOE, o_setFE, o_resetFE : out std_logic;
        o_loadRSR, o_shiftRSR, o_loadRDR : out std_logic;
        
        o_curState : out std_logic_vector(7 downto 0);
        o_nextState : out std_logic_vector(7 downto 0);
        o_count4 : out std_logic_vector(1 downto 0);
        o_count8, o_countBits : out std_logic_vector(3 downto 0);
        o_allowLeaveFrom1, o_allowLeaveFrom2, o_moreThan7 : out std_logic
    );
end entity;

architecture rtl of RecieverControl is
  
  signal int_curState, int_nextState : std_logic_vector(7 downto 0);
  signal int_count8Value, int_countBitValue : std_logic_vector(3 downto 0);
  signal int_count4Value : std_logic_vector(1 downto 0);
  signal int_enableCount4, int_enableCount8, int_enableBitCount : std_logic;
  signal int_reset4Clocks, int_reset8Clocks, int_resetBitCount : std_logic;
  signal int_countBitsZero, int_moreThan7Out, int_moreThan7In : std_logic;
  
  signal int_allowLeaveFrom1, int_allowLeaveFrom2, int_allowLeaveFrom4, int_allowLeaveFrom5, int_allowLeaveFrom6, int_allowLeaveFrom7, int_resetReg : std_logic;
  

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
  
  --Starting state, waiting for start bit as well as being enabled with select
  int_nextState(0) <= (int_curState(0) and (i_RxD or not i_select)) or (int_curState(7) and int_allowLeaveFrom7);
  --Once start bit recieved, waits for 4 clocks
  int_nextState(1) <= (int_curState(0) and not i_RxD and i_select) or (int_curState(1) and not int_allowLeaveFrom1);
  --Waits for 7 clocks, loading RSR(0) while active, can also jump to state(4) if enough bits have been recieved
  int_nextState(2) <= (int_allowLeaveFrom1 and int_curState(1)) or 
                      (int_curState(3) and not int_moreThan7Out) or 
                      (int_curState(2) and not int_allowLeaveFrom2);
  --Shifts the Register in one clock cycle then jumps back to state(2)
  int_nextState(3) <= (int_allowLeaveFrom2 and int_curState(2) and not int_moreThan7Out);
  --Used to reset count8, to prevent a blip
  int_nextState(4) <= (int_curState(2) and int_moreThan7Out and int_allowLeaveFrom2) or (int_curState(4) and not  int_allowLeaveFrom4);
  
  --Used for finding framing errors, if RxD is not 1 here then there is an issue
  int_nextState(5) <= (int_curState(4) and int_allowLeaveFrom4) or (int_curState(5) and not int_allowLeaveFrom5);
  --Load RDRF
  int_nextState(6) <= (int_curState(5) and int_allowLeaveFrom5) or (int_curState(6) and not int_allowLeaveFrom6);
  --Wait for RDRF to be cleared
  int_nextState(7) <= (int_curState(6) and int_allowLeaveFrom6) or (int_curState(7) and not int_allowLeaveFrom7);
    
  
  --These are used to make sure that the counters go far enough and that it doesn't instantly leave since the
  --counter starts at 0000
  --allowed to leave after 4 clocks
  int_allowLeaveFrom1 <= int_curState(1) and (int_count4Value(1) and not int_count4Value(0));
  --allowed to leave after 7 clocks
  int_allowLeaveFrom2 <= int_curState(2) and (int_count8Value(3) and int_count8Value(2) and not int_count8Value(1) and not int_count8Value(0));
  --could be removed later
  int_allowLeaveFrom4 <= '1';
  --7 clocks, to prevent a blip
  int_allowLeaveFrom5 <= int_curState(5) and (int_count8Value(3) and int_count8Value(2) and not int_count8Value(1) and not int_count8Value(0));
  --after RDR is read at some point, maybe if RDRF is 0
  int_allowLeaveFrom6 <= '1';
  int_allowLeaveFrom7 <= not i_RDRF;
  
  
  --Allow certain counters to count at certain times
  int_enableBitCount <= int_curState(3);
  int_enableCount8 <= int_curState(2) or int_curState(3) or int_curState(5);
  int_enableCount4 <= int_curState(1);
  
  int_resetReg <= int_curState(0);
  --Keeps track if more than 7 bits have been recieved
  int_moreThan7In <= not int_resetReg and (int_moreThan7Out or (int_countBitValue(3) and not int_countBitValue(2) and not int_countBitValue(1) and not int_countBitValue(0)));
  
  --Reset the counters at certain points
  int_reset4Clocks <= int_curState(0) or int_curState(6);
  int_reset8Clocks <= int_curState(0) or int_curState(4) or int_curState(6);
  int_resetBitCount <= int_curState(0) or int_curState(6);
  
  	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_BClkx8,
				o_q => int_curState(0)
			);
			
  	states: for i in 1 to 7 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_BClkx8,
				o_q => int_curState(i)
			);
		end generate states;
			
  count4Clocks: nJohnsonRingCounter
    generic map(
      n => 2
    )
    port map(
      i_clock => i_BClkx8,
      i_enable => int_enableCount4,
      i_resetBar => i_resetBar,
      i_resetCount => int_reset4Clocks,
      o_value => int_count4Value
    );
  
  count8Clocks: nJohnsonRingCounter
    generic map(
      n => 4
    )
    port map(
      i_clock => i_BClkx8,
      i_enable => int_enableCount8,
      i_resetBar => i_resetBar,
      i_resetCount => int_reset4Clocks,
      o_value => int_count8Value
    );
    
  countBitsRecieved:  nJohnsonRingCounter
    generic map(
      n => 4
    )
    port map(
      i_clock => i_BClkx8,
      i_enable => int_enableBitCount,
      i_resetBar => i_resetBar,
      i_resetCount => int_resetBitCount,
      o_value => int_countBitValue
    );
    
  moreThan7BitsRecieved: enARdff_2
       port map(
          i_resetBar => i_resetBar,
          i_d => int_moreThan7In,
          i_enable => '1',
          i_clock => i_BClkx8,
          o_q => int_moreThan7Out
        );
        
        o_curState <= int_curState;
        o_nextState <= int_nextState;
        
        --Used for a testbench at one point
        o_allowLeaveFrom1 <= int_allowLeaveFrom1; 
        o_allowLeaveFrom2 <= int_allowLeaveFrom2;
        
        o_moreThan7 <= int_moreThan7Out;
        
        o_loadRSR <= int_curState(2);
        o_shiftRSR <= int_curState(3);
        --Only load RDR if the final state is reached and Framing Error has not occured
        o_loadRDR <=  int_curState(6) and not i_FE;
        
        o_resetRDRF <= int_curState(0);
        --Only set RDRF if the final state is reached and Framing Error has not occured
        o_setRDRF <= int_curState(6) and not i_FE;
        
        --if the RDR is full and a new char arrives
        o_setOE <= (int_curState(7) or int_curState(0)) and not i_RxD and i_RDRF;
        o_resetOE <= '0';
        
        --FE is when stop bit not found at the correct time
        o_setFE <= int_curState(5) and not i_RxD and int_allowLeaveFrom5;
        o_resetFE <= '0';
                
        --Also test bench at some point
        o_count8 <= int_count8Value;
        o_count4 <= int_count4Value;
        o_countBits <= int_countBitValue;
  
end architecture;