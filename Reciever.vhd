library ieee;
use ieee.std_logic_1164.all;

--Recieves serial conveerts to parallel,
--recieves lsb first
entity Reciever is
    port(
        i_RxD, i_resetBar, i_BClkx8, i_select : in std_logic;
        i_RDRF, i_OE, i_FE : in std_logic;
        o_setRDRF, o_resetRDRF, o_setOE, o_resetOE, o_setFE, o_resetFE : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0);
        
        o_RDRout, o_RSRout : out std_logic_vector(7 downto 0);
        o_RCout : out std_logic_vector(7 downto 0);
        o_countBits, o_count8 : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of Reciever is
  
  signal int_setRDRF, int_resetRDRF, int_setOE, int_resetOE, int_setFE, int_resetFE, int_loadRDR, int_loadRSR, int_shiftRSR : std_logic;
  signal int_RDRout, int_RSRout : std_logic_vector(7 downto 0);
  signal int_RCout : std_logic_vector(7 downto 0);
  signal int_countBits, int_count8 : std_logic_vector(3 downto 0);
 
  component RDR
    port(
      i_BClkx8, i_resetBar : in std_logic;
      i_load : in std_logic;
      i_valueIn : in std_logic_vector(7 downto 0);
      o_busOut : out std_logic_vector (7 downto 0)      
    );
  end component;
  
  component RSR
    port(
        i_load, i_shift, i_resetBar, i_BClkx8 : in std_logic;
        i_RxD : in std_logic;
        o_value : out std_logic_vector(7 downto 0)    
    );
  end component;
  
  component RecieverControl
    port(
        i_BClkx8, i_resetBar, i_select : in std_logic;
        i_RDRF, i_OE, i_FE : in std_logic;
        i_RxD : in std_logic;
        o_setRDRF, o_resetRDRF, o_setOE, o_resetOE, o_setFE, o_resetFE : out std_logic;
        o_loadRSR, o_shiftRSR, o_loadRDR : out std_logic;
        
        o_curState : out std_logic_vector(7 downto 0);
        o_nextState : out std_logic_vector(7 downto 0);
        o_count4 : out std_logic_vector(1 downto 0);
        o_count8, o_countBits : out std_logic_vector(3 downto 0);
        o_allowLeaveFrom1, o_allowLeaveFrom2, o_moreThan7 : out std_logic    
    );
  end component;
  
begin
  
  shift: RSR
    port map(
      i_BClkx8 => i_BClkx8,
      i_resetBar => i_resetBar,
      i_load => int_loadRSR,
      i_shift => int_shiftRSR,
      i_RxD => i_RxD,
      o_value => int_RSRout
    );
    
  data: RDR
    port map(
      i_BClkx8 => i_BClkx8,
      i_resetBar => i_resetBar,
      i_load => int_loadRDR,
      i_valueIn => int_RSRout,
      o_busOut => int_RDRout      
    );
    
  control: RecieverControl
    port map(
      i_BClkx8 => i_BClkx8,
      i_resetBar => i_resetBar,
      i_select => i_select,
      i_RDRF => i_RDRF,
      i_OE => i_OE,
      i_FE => i_FE,
      i_RxD => i_RxD,
      o_setRDRF => int_setRDRF, 
      o_resetRDRF => int_resetRDRF,
      o_setOE => int_setOE, 
      o_resetOE => int_resetOE, 
      o_setFE => int_setFE, 
      o_resetFE => int_resetFE,
      o_loadRSR => int_loadRSR, 
      o_shiftRSR => int_shiftRSR, 
      o_loadRDR => int_loadRDR,
      o_curState => int_RCout,
      o_countBits => int_countBits,
      o_count8 => int_count8
    );
    
    
      o_setRDRF <= int_setRDRF;
      o_resetRDRF <= int_resetRDRF;
      o_setOE <= int_setOE;
      o_resetOE <= int_resetOE;
      o_setFE <= int_setFE;
      o_resetFE <= int_resetFE;
      
      o_busOut <= int_RDRout;
      
      o_RSROut <= int_RSRout;
      o_RDRout <= int_RDRout;
      o_RCout <= int_RCout;
      o_countBits <= int_countBits;
      o_count8 <= int_count8;
    
end architecture;


