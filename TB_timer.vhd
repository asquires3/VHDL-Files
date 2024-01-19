LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_TIMER is
end entity TB_TIMER;

architecture test_timer of TB_TIMER is

  CONSTANT CLK_PERIOD : time := 100 PS;
  
  signal resetBar, clock, timerFinished, enabled : std_logic;
  signal countValue, timerValue : std_logic_vector(3 downto 0);
  
  begin
    
    tim: entity work.timer(rtl)
    port map(
		  i_resetBar => resetBar,
		  i_clock_50Mhz => clock,
		  i_clock_1Hz => clock,
		  i_enabled => enabled,
		  i_countValue => countValue,
		  o_timerFinished => timerFinished,
		  o_timerValue => timerValue     
    );
    
    clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      resetBar <= '0', '1' AFTER 100 PS;
      countValue <= "0011", "1001" AFTER 1000 PS;
      enabled <= '1', '0' AFTER 2000 PS;
end architecture;