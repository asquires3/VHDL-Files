
library ieee;
use ieee.std_logic_1164.all;

--full circuit for lab3, combining all the stuff for the traffic
--light to work, added a clock divider in lab4 to run it at 10Hz

entity fullCircuit is 
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
end entity;

architecture rtl of fullCircuit is 

signal int_timerLoadValue, int_timerCurrentValue : std_logic_vector(3 downto 0);
signal int_msLight, int_ssLight : std_logic_vector(2 downto 0);
signal int_timerDone, int_timerEnable, int_sscs : std_logic;

signal int_bcd10, int_bcd11, int_bcd12, int_bcd13, int_bcd14, int_bcd15, int_bcd16 : std_logic;
signal int_bcd0, int_bcd1, int_bcd2, int_bcd3, int_bcd4, int_bcd5, int_bcd6 : std_logic;

signal int_msc, int_ssc : std_logic_vector(3 downto 0);

signal int_state : std_logic_vector(5 downto 0);

component bcd4bit
  port(
  	 i_bcd : in std_logic_vector(3 downto 0);
	 o_bcd10, o_bcd11, o_bcd12, o_bcd13, o_bcd14, o_bcd15, o_bcd16 :out std_logic;
	 o_bcd0, o_bcd1, o_bcd2, o_bcd3, o_bcd4, o_bcd5, o_bcd6 :out std_logic
  );
end component;

component trafficLightController
  port(
		i_clock, i_resetBar, i_timerDone, i_ssSensor : in std_logic;
		i_msc, i_ssc : in std_logic_vector(3 downto 0);
		o_enableTimer : out std_logic;
		o_timerLoadValue : out std_logic_vector(3 downto 0);
		o_state : out std_logic_vector(5 downto 0);
		o_msLight, o_ssLight : out std_logic_vector(2 downto 0)
  );
end component;

component timer
  port(		
    i_resetBar, i_clock_50Mhz, i_clock_1hz, i_enabled : in std_logic;
		i_countValue : in std_logic_vector(3 downto 0);
		o_timerFinished  : out std_logic;
		o_timerValue : out std_logic_vector(3 downto 0)
  );
end component;

component debouncer4BitToVec
  port(i_clock, i_resetBar,
	     i_msb, i_d2, i_d1, i_lsb : in STD_LOGIC;
			o_value : out STD_LOGIC_VECTOR(3 downto 0)    
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

begin
  
  debMSC : debouncer4BitToVec
    port map(
      i_clock => i_clock_50Mhz,
      i_resetBar => i_resetBar,
      i_msb => i_sw1_msb,
      i_d2 => i_sw1_d2,
      i_d1 => i_sw1_d1,
      i_lsb => i_sw1_lsb,
      o_value => int_msc
  );
  
  debSSC : debouncer4BitToVec
    port map(
      i_clock => i_clock_50Mhz,
      i_resetBar => i_resetBar,
      i_msb => i_sw2_msb,
      i_d2 => i_sw2_d2,
      i_d1 => i_sw2_d1,
      i_lsb => i_sw2_lsb,
      o_value => int_ssc
  );
  
  debSSCS : debouncer
    port map(
      i_clock => i_clock_50Mhz,
      i_resetBar => i_resetBar,
      i_in => i_sscs,
      o_value => int_sscs
  );
  
  tim: timer
    port map(
      i_resetBar => i_resetBar,
      i_clock_50Mhz => i_clock_50Mhz,
      i_clock_1Hz => i_clock_1Hz,
      i_enabled => int_timerEnable,
      i_countValue => int_timerLoadValue,
      o_timerFinished  => int_timerDone,
      o_timerValue => int_timerCurrentValue
    );
    
  tlc: trafficLightController
    port map(
      i_clock => i_clock_1hz,
      i_resetBar => i_resetBar,
      i_timerDone => int_timerDone,
      i_ssSensor => int_sscs,
      i_msc => int_msc,
      i_ssc => int_ssc,
      o_timerLoadValue => int_timerLoadValue,
      o_enableTimer => int_timerEnable,
      o_msLight => int_msLight,
      o_ssLight => int_ssLight,
      
      o_state => int_state
    );
    
  bcd: bcd4bit
    port map(
      i_bcd => int_timerCurrentValue,
		
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
		o_bcd16 => int_bcd16
  );
  
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
  
  o_state <= int_state;
  o_timerDone <= int_timerDone;
  o_timerVal <= int_timerCurrentValue;
  o_timerLoadVal <= int_timerLoadValue;
  
end architecture;