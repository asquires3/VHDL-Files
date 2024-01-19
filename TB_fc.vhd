LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_FULLCIRCUIT is
end entity TB_FULLCIRCUIT;

architecture test_fullcircuit of TB_FULLCIRCUIT is

  CONSTANT CLK_PERIOD : time := 200 PS;
  CONSTANT CLK_PERIOD2 : time := 20000 PS;
  
  signal clock50Mhz, clock1Hz, resetBar, sscs : std_logic;
  signal msc, ssc, bcd1, bcd2 : std_logic_vector(3 downto 0);
  signal mstl, sstl : std_logic_vector(2 downto 0);
  
  signal state: std_logic_vector(5 downto 0);
  signal timerVal, timerLoadVal: std_logic_vector(3 downto 0);
  signal timerDone : std_logic;
  
  begin
    tlc: entity work.fullcircuit(rtl)
    port map(
		  i_clock_50MHz => clock50Mhz, 
		  i_clock_1Hz => clock1Hz,
		  i_resetBar => resetBar, 
      i_sscs => sscs,
      i_sw1_msb => '1',
      i_sw1_d2 => '0',
      i_sw1_d1 => '1',
      i_sw1_lsb => '0',
      i_sw2_msb => '0',
      i_sw2_d2 => '1',
      i_sw2_d1 => '1', 
      i_sw2_lsb => '0',
      o_mstl => mstl,
      o_sstl => sstl,
      o_bcd1 => bcd1,
      o_bcd2 => bcd2,
      
      o_state => state,
      o_timerDone => timerDone,
      o_timerVal => timerVal,
      o_timerLoadVal => timerLoadVal
  );
  
      clk_process : process
        begin
          clock50Mhz<='0';
          wait for CLK_PERIOD/2;
          clock50Mhz<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      clk_process2 : process
        begin
          clock1Hz<='0';
          wait for CLK_PERIOD2/2;
          clock1Hz<='1';
          wait for CLK_PERIOD2/2;
      end process;
      
      resetBar <= '0', '1' after 100 PS;
      sscs <= '0', '1' after 1500 PS;
      msc <= "1010";
      ssc <= "0110";
      
    end architecture;