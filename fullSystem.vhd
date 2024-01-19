

library ieee;
use ieee.std_logic_1164.all;

--full circuit for lab3, combining all the stuff for the traffic
--light to work, added a clock divider in lab4 to run it at 10Hz

entity fullSystem is 
  port(
    i_clock, i_resetBar : in std_logic;
    i_sscs : in std_logic;
    i_sw1_msb, i_sw1_d2, i_sw1_d1, i_sw1_lsb,
    i_sw2_msb, i_sw2_d2, i_sw2_d1, i_sw2_lsb : in std_logic;
    o_mstl, o_sstl : out std_logic_vector(2 downto 0);
	 o_bcd10, o_bcd11, o_bcd12, o_bcd13, o_bcd14, o_bcd15, o_bcd16 :out std_logic;
	 o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 :out std_logic;
    o_TxD : out std_logic;
    o_actualReset : out std_logic
          
    --o_stateTLC : out std_logic_vector(5 downto 0);
    --o_timerDone : out std_logic;
    --o_timerVal, o_timerLoadVal : out std_logic_vector(3 downto 0);
    
    --o_SCCR, o_SCSR : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of fullSystem is
  
  signal int_clock_1_Hz, int_resetBar, int_TxD : std_logic;
  signal int_msLight, int_ssLight : std_logic_vector(2 downto 0);
  
  signal int_bcd10, int_bcd11, int_bcd12, int_bcd13, int_bcd14, int_bcd15, int_bcd16 : std_logic;
  signal int_bcd0, int_bcd1, int_bcd2, int_bcd3, int_bcd4, int_bcd5, int_bcd6 : std_logic;
  
  signal int_stateTLC : std_logic_vector(5 downto 0);
  signal int_timerDone : std_logic;
  signal int_timerVal, int_timerLoadVal : std_logic_vector(3 downto 0);
  
  signal int_SCCR, int_SCSR : std_logic_vector(7 downto 0);
  
  component fullCircuit
    port(
      i_clock_50Mhz, i_clock_1Hz, i_resetBar : in std_logic;
      i_sscs : in std_logic;
      i_sw1_msb, i_sw1_d2, i_sw1_d1, i_sw1_lsb,
      i_sw2_msb, i_sw2_d2, i_sw2_d1, i_sw2_lsb : in std_logic;
      o_mstl, o_sstl  : out std_logic_vector(2 downto 0);
		o_bcd10, o_bcd11, o_bcd12, o_bcd13, o_bcd14, o_bcd15, o_bcd16 :out std_logic;
		o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 :out std_logic;
          
      o_state : out std_logic_vector(5 downto 0);
      o_timerDone : out std_logic;
      o_timerVal, o_timerLoadVal : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component UARTandFSM
    port(
      i_clock, i_resetBar : in std_logic;
      i_msLight, i_ssLight : in std_logic_vector(2 downto 0);
      o_TxD : out std_logic;
      
      o_SCSR, o_SCCR : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component debouncer
   port(
      i_clock : in std_logic;
      i_resetBar : in std_logic;
      i_in : in std_logic;
      o_value : out std_logic
    );
  end component;
  
  component clk_div
	 PORT(
		clock_50Mhz				: IN	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC
	 );
	end component;
	
  begin
    
    cd : clk_div
      port map(
        clock_50Mhz => i_clock,
        clock_1Hz => int_clock_1_Hz
    );
    
    lab3: fullCircuit
      port map(
      i_clock_50Mhz => i_clock,
      i_clock_1Hz => int_clock_1_Hz,
      i_resetBar => int_resetBar,
      i_sscs => i_sscs,
      i_sw1_msb => i_sw1_msb, 
      i_sw1_d2 => i_sw1_d2, 
      i_sw1_d1 => i_sw1_d1, 
      i_sw1_lsb => i_sw1_lsb,
      i_sw2_msb => i_sw2_msb, 
      i_sw2_d2 => i_sw2_d2, 
      i_sw2_d1 => i_sw2_d1, 
      i_sw2_lsb => i_sw2_lsb,
      o_mstl => int_msLight,
      o_sstl => int_ssLight,
		
		o_bcd0 => int_bcd0,
		o_bcd1 => int_bcd1, 
		o_bcd2 => int_bcd2, 
		o_bcd3 => int_bcd3, 
		o_bcd4 => int_bcd4, 
		o_bcd5 => int_bcd5, 
		o_bcd6 => int_bcd6,
		
		o_bcd10 => int_bcd10, 
		o_bcd11 => int_bcd11, 
		o_bcd12 => int_bcd12, 
		o_bcd13 => int_bcd13, 
		o_bcd14 => int_bcd14, 
		o_bcd15 => int_bcd15, 
		o_bcd16 => int_bcd16,
      
      o_timerVal => int_timerVal,
      o_state => int_stateTLC,
      o_timerLoadVal => int_timerLoadVal,
      o_timerDone => int_timerDone
    );
    
    uartStuff : UARTandFSM
      port map(
        i_clock => i_clock,
        i_resetBar => int_resetBar,
        i_msLight => int_msLight,
        i_ssLight => int_ssLight,
        o_TxD => int_TxD,
        
        o_SCCR => int_SCCR,
        o_SCSR => int_SCSR
      );
      
      resetBarDebounce : debouncer
        port map(
          i_clock => i_clock,
          i_resetBar => '1',
          i_in => i_resetBar,
          o_value => int_resetBar
        );
        
      o_TxD <= int_TxD;
      o_mstl <= int_msLight;
      o_sstl <= int_ssLight;
		
		o_bcd0 <= int_bcd0;
		o_bcd1 <= int_bcd1; 
		o_bcd2 <= int_bcd2; 
		o_bcd3 <= int_bcd3; 
		o_bcd4 <= int_bcd4; 
		o_bcd5 <= int_bcd5; 
		o_bcd6 <= int_bcd6;

		o_bcd10 <= int_bcd10; 
		o_bcd11 <= int_bcd11; 
		o_bcd12 <= int_bcd12; 
		o_bcd13 <= int_bcd13; 
		o_bcd14 <= int_bcd14; 
		o_bcd15 <= int_bcd15; 
		o_bcd16 <= int_bcd16;
      
      --o_timerVal <= int_timerVal;
      o_actualReset <= int_resetBar;
      
      --o_stateTLC <= int_stateTLC;
      --o_timerDone <= int_timerDone;
      --o_timerVal <= int_timerVal;
      --o_timerLoadVal <= int_timerLoadVal;
      
      --o_SCCR <= int_SCCR;
      --o_SCSR <= int_SCSR;
        
      end architecture;