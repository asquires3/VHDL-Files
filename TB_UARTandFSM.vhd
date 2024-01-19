
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_UARTandFSM is
end entity TB_UARTandFSM;

architecture test_uartandfsm of TB_UARTandFSM is

  --run for 11000000PS

  CONSTANT CLK_PERIOD : time := 100 PS; -- clock of FSM, actual clock after division for uart has period 131200PS
  CONSTANT UART_PERIOD  : time := 131200 PS;

  signal i: integer := 0;

  signal clock, resetBar, irq, rwBar, txd, sendRW : std_logic;
  signal msLight, ssLight : std_logic_vector(2 downto 0);
  signal busIn, busOut, char, charRDR, sccr, scsr, recieveState, tdr, rdr :std_logic_vector(7 downto 0);
  signal address, sendADDR : std_logic_vector(1 downto 0);
  signal sel : std_logic;
  
  signal TXDOuts : std_logic_vector(90 downto 0);
  
  signal curStateFSM, nextStateFSM, counter, transmitState : std_logic_vector(3 downto 0); 
  signal curMs, curSS : std_logic_vector(2 downto 0);
  
  
  --shamelessly stolen from https://stackoverflow.com/questions/15406887/vhdl-convert-vector-to-string
  function to_string ( a: std_logic_vector) return string is
  variable b : string (1 to a'length) := (others => NUL);
    variable stri : integer := 1; 
      begin
       for i in a'range loop
          b(stri) := std_logic'image(a((i)))(2);
          stri := stri+1;
        end loop;
      return b;
    end function;
    
  begin
    
    uartfsm: entity work.uart_fsm(rtl)
    port map(
        i_clock => clock,
        i_resetBar => resetBar,
        i_IRQ => irq,
        i_msLight => msLight,
        i_ssLight => ssLight,
        i_busIn => busIn,
        o_r_wBar => rwBar,
        o_address => address,
        o_select => sel,
        o_busOut => busOut,
        
        o_curState => curStateFSM,
        o_nextState => nextStateFSM,
        o_counter => counter,
        o_curMs => curMS,
        o_curSs => curSS
    );
    
    sendinguart: entity work.fulluart(rtl)
    port map(
      i_clock => clock,
      i_resetBar => resetBar,
      i_rw => rwBar,
      i_select => sel,
      i_RxD => '1',
      i_data => busOut,
      i_addr => address,
      o_IRQ => irq,
      o_TxD => txd,
      
      o_SCCR => sccr,
      o_SCSR => scsr,
      
      o_transmitState => transmitState,
      
      o_TDR => tdr
    );
    
    recievinguart: entity work.fulluart(rtl)
      port map(
        i_clock => clock,
        i_resetBar => resetBar,
        i_rw => sendRW,
        i_select => '1',
        i_RxD => txd,
        i_data => "00000000",
        i_addr => sendADDR,
        
        o_data => rdr,
        
        o_recieveState => recieveState  
      );
      
    fetchTXD: process
      begin
        wait for UART_PERIOD;
          TXDOuts(i) <= txd;
          i <= i+1;
      end process;
    
    fetchChar: process(rdr)
      begin
        charRDR <= "0" & rdr(7 downto 1);
        report to_string(charRDR);
      end process;
      
    clk : process
        begin
          clock <= '0';
          wait for CLK_PERIOD/2;
          clock <= '1';
          wait for CLK_PERIOD/2;
      end process;
       
      resetBar <= '0', '1' after 100 PS;
      
      char <= "0" & busOut(7 downto 1);
      msLight <= "100", "010" after 600 PS;
      ssLight <= "001";
      busIn <= "00000000";
      
      sendRW <= '0', '1' after 300 PS;
      sendADDR <= "10", "00" after 300 PS;
end architecture;


