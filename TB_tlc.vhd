LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_TLC is
end entity TB_TLC;

architecture test_tlc of TB_TLC is

  CONSTANT TIMER_PERIOD : time := 600 PS;
  CONSTANT CLK_PERIOD : time := 100 PS;
  
  signal resetBar, clock, timerDone, ssS, enableTimer : std_logic;
  signal state : std_logic_vector (5 downto 0);
  signal msc, ssc, timerLoadValue : std_logic_vector(3 downto 0);
  signal msLight, ssLight : std_logic_vector(2 downto 0);
  
  begin
    tlc: entity work.trafficLightController(rtl)
    port map(
		  i_clock => clock, 
		  i_resetBar => resetBar, 
		  i_timerDone => timerDone, 
		  i_ssSensor => ssS,
		  i_msc => msc, 
		  i_ssc => ssc,
		  o_state => state, 
		  o_timerLoadValue => timerLoadValue,
		  o_msLight => msLight, 
		  o_ssLight => ssLight,
		  o_enableTimer => enableTimer
  );
    
    clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
     
     timer_process : process 
        begin
          ssS<='1';
          timerDone<='0';
          wait for 5*TIMER_PERIOD/6;
          ssS<='0';
          timerDone<='1';
          wait for TIMER_PERIOD/6;
      end process;
      
      resetBar <= '0', '1' AFTER 100 PS;
      msc <= "1100";
      ssc <= "1000";
      
end architecture;
