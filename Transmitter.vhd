library ieee;
use ieee.std_logic_1164.all;


--Tranmits parallel to serial, starting with the lsb
entity Transmitter is
    port(
        i_resetBar, i_BClk, i_loadTDR, i_TDRE, i_select : in std_logic;
        i_busIn : in std_logic_vector(7 downto 0);
        o_setTDRE, o_resetTDRE : out std_logic;
        o_TxD : out std_logic;
        
        o_TSR : out std_logic_vector(9 downto 0);
        o_TDR : out std_logic_vector(7 downto 0);
        o_curState : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of Transmitter is
  
    signal int_TSRout : std_logic_vector(9 downto 0);
  
    signal int_TSRin : std_logic_vector(7 downto 0);
    signal int_state : std_logic_vector(3 downto 0);
    signal int_shiftCount : std_logic_vector(4 downto 0);
    
    signal int_TxD : std_logic;
    signal int_loadTSR, int_shiftTSR, int_setTDRE, int_resetTDRE, int_clearTDR : std_logic;
    
  component TSR
    port(
      i_BClk, i_resetBar : in std_logic;
      i_value : in std_logic_vector(7 downto 0);
      i_load, i_shift : in std_logic;
      o_TxD : out std_logic;
      o_value : out std_logic_vector(9 downto 0)
    );
  end component;
  
  component TDR
    port(
        i_load, i_resetBar, i_BClk, i_select, i_clear : in std_logic;
        i_busIn : in std_logic_vector(7 downto 0);
        o_valueOut : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component TransmitterControl
    port(
      i_BClk, i_resetBar, i_TDRE, i_select, i_loadTDR : in std_logic;
      o_loadTSR, o_shiftTSR, o_setTDRE, o_resetTDRE, o_clearTDR : out std_logic;
      
      o_curState : out std_logic_vector(3 downto 0);
      o_shiftCount : out std_logic_vector(4 downto 0)
    );
  end component;
    
  
begin
  
  shift: TSR
  port map(
    i_BCLk => i_BClk,
    i_resetBar => i_resetBar,
    i_value => int_TSRin,
    i_load => int_loadTSR,
    i_shift => int_shiftTSR,
    o_TxD => int_TxD,
    o_value => int_TSRout
  );
  
  data: TDR
  port map(
    i_BCLk => i_BClk,
    i_resetBar => i_resetBar,
    i_select => i_select,
    i_load => i_loadTDR,
    i_clear => int_clearTDR,
    i_busIn => i_busIn,
    o_valueOut => int_TSRin  
  );
  
  control: TransmitterControl
  port map(
    i_BCLk => i_BClk,
    i_resetBar => i_resetBar,
    i_TDRE => i_TDRE,
    i_select => i_select,
    i_loadTDR => i_loadTDR,
    o_setTDRE => int_setTDRE,
    o_resetTDRE => int_resetTDRE,
    o_clearTDR => int_clearTDR,
    o_loadTSR => int_loadTSR,
    o_shiftTSR => int_shiftTSR,
    o_curState => int_state,
    o_shiftCount => int_shiftCount    
  );
  
  o_setTDRE <= int_setTDRE;
  o_resetTDRE <= int_resetTDRE;
  
  o_TxD <= int_TxD;
  
  o_TDR <= int_TSRin;
  o_TSR <= int_TSRout;
  o_curState <= int_state;
  
end architecture;



