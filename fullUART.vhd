library ieee;
use ieee.std_logic_1164.all;

entity fullUART is
    port(
      i_clock, i_resetBar, i_rw, i_select, i_RxD : in std_logic;
      i_data : in std_logic_vector(7 downto 0);
      i_addr : in std_logic_vector(1 downto 0);
      o_IRQ, o_TxD : out std_logic;
      o_data, o_TDR : out std_logic_vector(7 downto 0);
      
      o_SCCR, o_SCSR, o_recieveState : out std_logic_vector(7 downto 0);
      o_transmitState : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of fullUART is 

signal int_setRDRF, int_resetRDRF, int_setTDRE, int_resetTDRE, int_setOE, int_resetOE, int_setFE, int_resetFE : std_logic;
signal int_loadSCCR, int_loadTDR : std_logic;
signal int_RDRF, int_TDRE, int_OE, int_FE, int_TIE, int_RIE : std_logic;
signal int_TxD : std_logic;
signal int_BClk, int_BClkx8 : std_logic;

signal int_transmitState : std_logic_vector(3 downto 0);
signal int_recieveState : std_logic_vector(7 downto 0);

signal int_recieverOut, int_sccrOut, int_scsrOut, int_tdr, int_busValue : std_logic_vector(7 downto 0);
signal int_baudRateSel : std_logic_vector(2 downto 0);

component Reciever
    port(
        i_RxD, i_resetBar, i_BClkx8, i_select : in std_logic;
        i_RDRF, i_OE, i_FE : in std_logic;
        o_setRDRF, o_resetRDRF, o_setOE, o_resetOE, o_setFE, o_resetFE : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0);
        
        o_RDRout, o_RSRout : out std_logic_vector(7 downto 0);
        o_RCout : out std_logic_vector(7 downto 0);
        o_countBits, o_count8 : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component Transmitter
    port(
        i_resetBar, i_BClk, i_loadTDR, i_TDRE, i_select : in std_logic;
        i_busIn : in std_logic_vector(7 downto 0);
        o_setTDRE, o_resetTDRE : out std_logic;
        o_TxD : out std_logic;
        
        o_TSR : out std_logic_vector(9 downto 0);
        o_TDR : out std_logic_vector(7 downto 0);
        o_curState : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component SCCR
    port(
      i_clock, i_resetBar, i_load, i_select : in std_logic;
      i_busIn : in std_logic_vector(7 downto 0);
      o_busOut : out std_logic_vector(7 downto 0);
      o_TIE, o_RIE : out std_logic;
      o_baudRateSel : out std_logic_vector(2 downto 0)
    );
  end component;
  
  component SCSR
    port(
        i_setTDRE, i_resetTDRE, i_setRDRF, i_resetRDRF, i_setOE, i_resetOE, i_setFE, i_resetFE : in std_logic;
        i_clock, i_resetBar : in std_logic;
        o_TDRE, o_RDRF, o_OE, o_FE : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component BaudGenerator
    port(
        i_clockIn, i_resetBar : in std_logic;
        i_selPins : in std_logic_vector(2 downto 0);
        o_BClk, o_BClkx8 : out std_logic
    );
  end component;
  
  component AddressDecoder
    port(
        i_addr : in std_logic_vector(1 downto 0);
        i_rw : in std_logic;
        i_RDR, i_SCSR, i_SCCR, i_outside : in std_logic_vector(7 downto 0);
        o_busValue : out std_logic_vector(7 downto 0);
        o_loadSCCR, o_loadTDR : out std_logic
    );
  end component;

begin
  
  rcv: Reciever
    port map(
        i_RxD => i_RxD,
        i_resetBar => i_resetBar,
        i_select => i_select,
        i_BClkx8 => int_BClkx8,
        i_RDRF => int_RDRF,
        i_OE => int_OE, 
        i_FE => int_FE,
        o_setRDRF => int_setRDRF, 
        o_resetRDRF => int_resetRDRF, 
        o_setOE => int_setOE,
        o_resetOE => int_resetOE,
        o_setFE => int_setFE,
        o_resetFE => int_resetFE,
        o_busOut => int_recieverOut,
        o_RCout => int_recieveState    
    );
      
  tsm: Transmitter
    port map(
        i_resetBar => i_resetBar, 
        i_BClk => int_BClk,
        i_select => i_select,
        i_loadTDR => int_loadTDR,
        i_TDRE => int_TDRE,
        i_busIn => int_busValue,
        o_setTDRE => int_setTDRE,
        o_resetTDRE => int_resetTDRE,
        o_TxD => int_TxD,
        o_TDR => int_tdr,
        o_curState => int_transmitState
      );
      
  ccr: SCCR
    port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_load => int_loadSCCR,
        i_select => i_select,
        i_busIn => int_busValue,
        o_busOut => int_SCCROut,
        o_TIE => int_TIE,
        o_RIE => int_RIE,
        o_baudRateSel => int_baudRateSel
      );
      
  csr: SCSR
    port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_setTDRE => int_setTDRE,
        i_resetTDRE => int_resetTDRE,
        i_setRDRF => int_setRDRF, 
        i_resetRDRF => int_resetRDRF, 
        i_setOE => int_setOE,
        i_resetOE => int_resetOE,
        i_setFE => int_setFE,
        i_resetFE => int_resetFE,
        o_TDRE => int_TDRE,
        o_RDRF => int_RDRF,
        o_OE => int_OE,
        o_FE => int_FE,
        o_busOut => int_SCSROut
      );
      
  bg: BaudGenerator
    port map(
        i_clockIn => i_clock,
        i_resetBar => i_resetBar,
        i_selPins => int_baudRateSel,
        o_BClk => int_BClk,
        o_BClkx8 => int_BClkx8   
      );
      
  ad: AddressDecoder
    port map(
        i_addr => i_addr,
        i_rw => i_rw,
        i_RDR => int_recieverOut,
        i_SCSR => int_SCSROut,
        i_SCCR => int_SCCROut,
        i_outside => i_data,
        o_busValue => int_busValue,
        o_loadSCCR => int_loadSCCR,
        o_loadTDR => int_loadTDR   
    );
    
    o_IRQ <= (int_RIE and (int_RDRF or int_OE)) or (int_TIE and int_TDRE);
    o_TxD <=  int_TxD;
    o_data <= int_busValue;
    
    o_SCCR <= int_SCCROut;
    o_SCSR <= int_SCSROut;
    
    o_transmitState <= int_transmitState;
    o_recieveState <= int_recieveState;
    
    o_TDR <= int_tdr;
  
end architecture;