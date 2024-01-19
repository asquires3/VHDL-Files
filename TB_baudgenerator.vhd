
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_BAUDGENERATOR is
end entity TB_BAUDGENERATOR;

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

architecture test_baudgenerator of TB_BAUDGENERATOR is
  
  --this is the time of 50MHz divided by 1000, so effectively one real second is 1000000000(billion) PS
  CONSTANT CLK_PERIOD : time := 20 PS;
  
  signal resetBar, clock : std_logic;
  signal selPins : std_logic_vector(2 downto 0);
  signal bclk, bclkx8 : std_logic;
  
  signal t_time : integer := 0;
  signal bclkx8Count : integer := 0;
  signal bclkCount : integer := 0;
  signal freq8 : integer := 0;
  signal freq : integer := 0;
  
  begin
    
   trackerClock: process(bclk)
      begin
        if bclk = '1' then
          bclkCount <= bclkCount + 1;
        end if;
      end process;
      
      trackerX8: process(bclkx8)
      begin
          if bclkx8 = '1' then 
          bclkx8Count <= bclkx8Count + 1;
        end if;
        end process;
      
      --trackerTime: process(clock)
      --begin
       --   t_time <= t_time + 20000;
       -- end process;
      
      --freqProcess: process(bclkx8)
        --begin
         -- if t_time > 0 then
         -- freq <= bclkCount/t_time;
         -- freq8 <= bclkx8Count/t_time;
        --end if;
        --end process;
          
    
    bg: entity work.baudgenerator(rtl)
    port map(
        i_clockIn => clock,
        i_resetBar => resetBar,
        i_selPins => selPins,
        o_BClk => bclk, 
        o_BClkx8 => bclkx8
    );
    
    clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      resetBar <= '0', '1' AFTER 1 PS;
      selPins <= "000";
      
end architecture;
