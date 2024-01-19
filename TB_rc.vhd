
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_RECIEVERCONTROL is
end entity TB_RECIEVERCONTROL;

architecture test_recievercontrol of TB_RECIEVERCONTROL is


  CONSTANT RECIEVER_CLK_PERIOD : time := 50 PS;
  CONSTANT TRANSMIT_CLK_PERIOD : time := 800 PS;
  
  signal reciever_clock, transmit_clock : std_logic;
  
  signal resetBar, RxD, alf2, alf1, rdrf, oe, fe : std_logic;
  
  signal curState, nextState : std_logic_vector(7 downto 0);
  signal countBits, count8 : std_logic_vector(3 downto 0);
  signal count4 : std_logic_vector(1 downto 0);
  
  begin
    rc: entity work.recievercontrol(rtl)
    port map(
      i_BClkx8 => reciever_clock,
      i_resetBar => resetBar,
      i_RxD => RxD,
      
      i_select => '1',
    
      i_RDRF => rdrf,
      i_OE => oe,
      i_FE => fe,
      
      o_curState => curState,
      o_nextState => nextState,
      
      o_allowLeaveFrom1 => alf1, 
      o_allowLeaveFrom2 => alf2, 
      
      o_count4 => count4,
      o_count8 => count8,
      o_countBits => countBits
  );
  
      reciever_clk_process : process
        begin
          reciever_clock<='0';
          wait for RECIEVER_CLK_PERIOD/2;
          reciever_clock<='1';
          wait for RECIEVER_CLK_PERIOD/2;
      end process;
      
      transmit_clk_process : process
        begin
          transmit_clock<='0';
          RxD <= '1';
          wait for TRANSMIT_CLK_PERIOD/2;
          transmit_clock<='1';
          RxD <= '0';
          wait for TRANSMIT_CLK_PERIOD/2;
      end process;
      
      rdrf <= '0';
      oe <= '0';
      fe <= '0';
      
      resetBar <= '0', '1' after 10 PS;
      
    end architecture;
