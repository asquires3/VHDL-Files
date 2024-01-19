
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_TRANSMITTER is
end entity TB_TRANSMITTER;

architecture test_transmitter of TB_TRANSMITTER is

  --run for about 1900PS, it will repeat after a while

  CONSTANT CLK_PERIOD : time := 100 PS;
  
  signal clock : std_logic;
  
  signal resetBar, txd, setTDRE, resetTDRE, loadTDR, TDRE, sel : std_logic;
  
  signal rdrf, oe, fe : std_logic;
  
  signal tsr : std_logic_vector(9 downto 0);
  signal tdr, busIn, SCSRout : std_logic_vector(7 downto 0);
  signal state : std_logic_vector(3 downto 0);
  
  
  begin
    t: entity work.transmitter(rtl)
    port map(
        i_resetBar => resetBar, 
        i_BClk => clock, 
        i_loadTDR => loadTDR, 
        i_TDRE => TDRE,
        i_busIn => busIn,
      
        i_select => sel,
        
        o_setTDRE => setTDRE, 
        o_resetTDRE => resetTDRE,
        o_TxD => txd,
        
        o_TSR => tsr,
        o_TDR => tdr,
        o_curState => state
    );
    
    scsr: entity work.scsr(rtl)
      port map(
        i_clock => clock,
        i_resetBar => resetBar,
        i_setTDRE => setTDRE,
        i_resetTDRE => resetTDRE,
        i_setRDRF => '0', 
        i_resetRDRF => '1', 
        i_setOE => '0',
        i_resetOE => '1',
        i_setFE => '0',
        i_resetFE => '1',
        o_TDRE => TDRE,
        o_RDRF => rdrf,
        o_OE => oe,
        o_FE => fe,
        o_busOut => SCSRout
    );
  
      clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process; 
      
      resetBar <= '0', '1' after 10 PS;
      loadTDR <= '1';
      sel <= '0', '1' after 600 PS;
      busIn <= "11001100";
      
    end architecture;


