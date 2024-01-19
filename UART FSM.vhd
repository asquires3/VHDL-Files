library ieee;
use ieee.std_logic_1164.all;

--since we are only sending, no need to worry about OE

--runs of system clock, since it isnt needed to count,
--state changes are based on IRQs
entity UART_FSM is
    port(
        i_clock, i_resetBar : in std_logic;
        i_IRQ : in std_logic;
        i_msLight, i_ssLight : in std_logic_vector(2 downto 0);
        i_busIn : in std_logic_vector(7 downto 0); --not used since all we do is send data out
        o_r_wBar : out std_logic;
        o_address : out std_logic_vector(1 downto 0);
        o_select : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0);
        
        o_curState, o_nextState, o_counter : out std_logic_vector(3 downto 0);
        o_curMs, o_curSs : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of UART_FSM is
  
  constant TIEEnable : std_logic := '1';
  constant RIEEnable : std_logic := '1';
  constant BaudRate : std_logic_vector(2 downto 0) := "000";
  
  --first 7 bits are character, last is parity
  constant int_M : std_logic_vector(7 downto 0) := "10011010"; --10011010
  constant int_S : std_logic_vector(7 downto 0) := "10100110"; --10100110
  constant int_g : std_logic_vector(7 downto 0) := "11001111"; --has parity 11001111
  constant int_y : std_logic_vector(7 downto 0) := "11110011"; --has parity 11110011
  constant int_r : std_logic_vector(7 downto 0) := "11100100"; --11100100
  constant int_underscore : std_logic_vector(7 downto 0) := "10111110"; --10111110
  constant int_carriage : std_logic_vector(7 downto 0) := "00011011"; --has parity 00011011
  
  signal int_increment, int_resetCount, int_stateChange, int_leave, int_waitedOneClock : std_logic;
  
  signal int_expandedMS0, int_expandedMS1, int_expandedMS2, int_expandedSS0, int_expandedSS1, int_expandedSS2, int_stateZeroExp, int_stateTwoExp : std_logic_vector(7 downto 0);
  signal int_sel0, int_sel1, int_sel2, int_sel3, int_sel4, int_sel5 : std_logic_vector(7 downto 0);
  
  signal int_mainCharSel, int_sideCharSel, int_charSel, int_dataSel : std_logic_vector(7 downto 0);
  signal int_counter : std_logic_vector(3 downto 0);
  signal int_curState, int_nextState : std_logic_vector(3 downto 0);
  
  signal int_curSSState, int_curMSState : std_logic_vector(2 downto 0);
  
	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT enARdFF_2_high
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;    
	
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
    
    --expands out to 8 bit vector so i can bitwise or them with the char
    lightExpansion: process(i_msLight, i_ssLight)
      begin
        int_expandedMS0 <= (others => i_msLight(0));
        int_expandedMS1 <= (others => i_msLight(1));
        int_expandedMS2 <= (others => i_msLight(2));
        int_expandedSS0 <= (others => i_ssLight(0));
        int_expandedSS1 <= (others => i_ssLight(1));
        int_expandedSS2 <= (others => i_ssLight(2));
      end process;
      
      --converts counter values to a 8 bit vector to be anded bitwise in choosing the next character
      --int_set0 will always be selecting 'M', int_sel1 selects between the 3 possible states, 'r','y','g'
      --int_sel2 is '_', int_sel3 is 'S', int_sel4 again chooses between states, and int_sel5 is the carriage
    counterExpansion: process(int_counter)
      begin
        --all of these will either be all ones or all zeros, and only one can be all one at a time
        int_sel0 <= (others => (not int_counter(3) and not int_counter(2) and not int_counter(1) and not int_counter(0))); --0000
        int_sel1 <= (others => (not int_counter(3) and not int_counter(2) and not int_counter(1) and int_counter(0))); --0001
        int_sel2 <= (others => (not int_counter(3) and not int_counter(2) and int_counter(1) and int_counter(0))); --0011
        int_sel3 <= (others => (not int_counter(3) and int_counter(2) and int_counter(1) and int_counter(0))); --0111
        int_sel4 <= (others => (int_counter(3) and int_counter(2) and int_counter(1) and int_counter(0))); --1111
        int_sel5 <= (others => (int_counter(3) and int_counter(2) and int_counter(1) and not int_counter(0))); --1110
        
        int_leave <= (int_counter(3) and int_counter(2) and not int_counter(1) and not int_counter(0)); --1100
      end process;
    
    stateExpansion: process(int_curState)
     begin
      int_stateZeroExp <= (others => int_curState(0));
      int_stateTwoExp <= (others => int_curState(2));
     end process;
  
    --These choose what character to send from 'r', 'g', and 'y'
    int_mainCharSel <= (int_expandedMS0 and int_r) or (int_expandedMS1 and int_y) or (int_expandedMS2 and int_g);
    int_sideCharSel <= (int_expandedSS0 and int_r) or (int_expandedSS1 and int_y) or (int_expandedSS2 and int_g);
    
    int_charSel <= (int_sel0 and int_M) or (int_sel1 and int_mainCharSel) or (int_sel2 and int_underscore) or (int_sel3 and int_S)
                    or (int_sel4 and int_sideCharSel) or (int_sel5 and int_carriage);
    
    --If in state 2, send a char, otherwise if in 0 send the initial SCCR value
    int_dataSel <= (int_stateTwoExp and int_charSel) or (int_stateZeroExp and (TIEEnable & RIEEnable & "000" & BaudRate));                
    
    --Detect a change in the state of the traffic lights
    int_stateChange <= (int_curMSState(2) xor i_msLight(2)) or (int_curMSState(1) xor i_msLight(1)) or (int_curMSState(1) xor i_msLight(1))
                      or (int_curSSState(2) xor i_ssLight(2)) or (int_curSSState(1) xor i_ssLight(1)) or (int_curSSState(1) xor i_ssLight(1));   
    
    --Used to set SCCR, always leaves
    int_nextState(0) <= '0';
    
    --Waits for a state change on one of the lights
    int_nextState(1) <= int_curState(0) or (int_curState(3) and int_leave) or (int_curState(1) and not int_stateChange);
    --This is a cycle that sends the characters one at a time, waiting for IRQ before sending the next char
    int_nextState(2) <= (int_curState(1) and int_stateChange) or (int_curState(2) and i_IRQ) or (int_curState(3) and not int_leave and i_IRQ);
    int_nextState(3) <= (int_curState(2) and not i_IRQ) or (int_curState(3) and not i_IRQ and not int_leave);
   	
   	int_resetCount <= int_curState(1) or int_curState(0);
   	int_increment <= int_curState(3);
   	
   	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(0)
			);
			
  	states: for i in 1 to 3 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(i)
			);
		end generate states;
                    
    msState_2: enARdFF_2_high
      port map(
				i_resetBar => i_resetBar,
				i_d => i_msLight(2),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curMSState(2)
      );
      
    msStates: for i in 0 to 1 generate
      msState_i: enARdFF_2
      port map(
				i_resetBar => i_resetBar,
				i_d => i_msLight(i),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curMSState(i)
      );
    end generate msStates;
                    
    ssState_0: enARdFF_2_high
      port map(
				i_resetBar => i_resetBar,
				i_d => i_ssLight(0),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curSSState(0)
      );
      
    ssStates: for i in 1 to 2 generate
      ssState_i: enARdFF_2
      port map(
				i_resetBar => i_resetBar,
				i_d => i_ssLight(i),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curSSState(i)
      );
    end generate ssStates;
      
    counter: component nJohnsonRingCounter
      generic map(
        n => 4
      )
      port map(
        i_clock => int_increment,
        i_enable => '1',
        i_resetBar => i_resetBar,
        i_resetCount => int_resetCount,
        o_value => int_counter
    );
    
    o_r_wBar <= '0';
    o_address(0) <= '0';
    o_address(1) <= int_curState(0);
    
    o_select <= int_curState(2) or int_curState(0);
    o_busOut <= int_dataSel;
    
    o_curState <= int_curState;
    o_nextState <= int_nextState;
    o_counter <= int_counter;
    o_curMs <= int_curMSState;
    o_curSs <= int_curSSState;
  
end architecture;