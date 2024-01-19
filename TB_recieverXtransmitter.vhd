

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_RECIEVERXTRANSMITTER is
end entity TB_RECIEVERXTRANSMITTER;

architecture test_recieverXtransmitter of TB_RECIEVERXTRANSMITTER is


  CONSTANT RECIEVER_CLK_PERIOD : time := 50 PS;
  CONSTANT TRANSMIT_CLK_PERIOD : time := 400 PS;
  
  signal reciever_clock, transmit_clock : std_logic;
  
  signal resetBar, TxD : std_logic;
  
  signal rdr, rsr : std_logic_vector(7 downto 0);
  signal stateR : std_logic_vector(7 downto 0);
  signal cb, c8 : std_logic_vector(3 downto 0);
  
  signal set_rdrf, reset_rdrf, set_oe, reset_oe, set_fe, reset_fe, rdrf : std_logic;
  
  signal setTDRE, resetTDRE, loadTDR, TDRE : std_logic;
  
  signal tsr : std_logic_vector(9 downto 0);
  signal tdr, busIn : std_logic_vector(7 downto 0);
  signal stateT : std_logic_vector(3 downto 0);
  
  begin
    r: entity work.reciever(rtl)
    port map(
      i_BClkx8 => reciever_clock,
      i_resetBar => resetBar,
      i_RxD => TxD,
      
      i_select => '1',
      
      i_RDRF => rdrf,
      i_OE => '0',
      i_FE => '0',
      
      o_setRDRF => set_rdrf, 
      o_resetRDRF => reset_rdrf, 
      o_setOE => set_oe, 
      o_resetOE => reset_oe, 
      o_setFE => set_fe, 
      o_resetFE => reset_fe,
  
      o_RCout => stateR,
      o_RSRout => rsr,
      o_RDRout => rdr,
      o_countBits => cb,
      o_count8 => c8
  );
  
  t: entity work.transmitter(rtl)
    port map(
        i_resetBar => resetBar, 
        i_BClk => transmit_clock, 
        i_loadTDR => loadTDR, 
        i_TDRE => TDRE,
        i_busIn => busIn,
      
        i_select => '1',
        
        o_setTDRE => setTDRE, 
        o_resetTDRE => resetTDRE,
        o_TxD => TxD,
        
        o_TSR => tsr,
        o_TDR => tdr,
        o_curState => stateT
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
          wait for TRANSMIT_CLK_PERIOD/2;
          transmit_clock<='1';
          wait for TRANSMIT_CLK_PERIOD/2;
      end process;   
      
      resetBar <= '0', '1' after 10 PS;
      rdrf <= '0', '1' after 2000 PS;
      
      TDRE <= '1', '0' after 500 PS;
      loadTDR <= '1';
      --RDR should have this value around 6000PS
      busIn <= "00000111";
      
    end architecture;


