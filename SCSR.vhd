library ieee;
use ieee.std_logic_1164.all;


--bits 7-0
--7 = TDRE, Transmit Data Register Empty
--6 = RDRF, Recieve Data Register Full
--5-2 = 0
--1 = OE, Overrun Error
--0 = FE, Framing Error
entity SCSR is
    port(
        i_setTDRE, i_resetTDRE, i_setRDRF, i_resetRDRF, i_setOE, i_resetOE, i_setFE, i_resetFE : in std_logic;
        i_clock, i_resetBar : in std_logic;
        o_TDRE, o_RDRF, o_OE, o_FE : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of SCSR is
  
  signal int_TDREin, int_RDRFin, int_OEin, int_FEin : std_logic;
  signal int_TDREout, int_RDRFout, int_OEout, int_FEout : std_logic;
  signal int_valueOut : std_logic_vector(7 downto 0);
  
  component enARdff_2
    port(
     i_resetBar : in std_logic;
     i_d : in std_logic;
     i_enable : in std_logic;
     i_clock : in std_logic;
     o_q, o_qBar : out std_logic
    );
  end component;
  
  component enARdff_2_high
    port(
     i_resetBar : in std_logic;
     i_d : in std_logic;
     i_enable : in std_logic;
     i_clock : in std_logic;
     o_q, o_qBar : out std_logic
    );
  end component;
  
begin
  
      int_TDREin <= i_setTDRE and not i_resetTDRE;
      int_RDRFin <= i_setRDRF and not i_resetRDRF;
      int_OEin <= i_setOE and not i_resetOE;
      int_FEin <= i_setFE and not i_resetFE;
      int_valueOut <= int_TDREout & int_RDRFout & "0000" & int_OEout & int_FEout;
    
    TDRE: enARdff_2_high
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_enable => '1',
        i_d => int_TDREin,
        o_q => int_TDREout
      );
      
      RDRF: enARdff_2
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_enable => '1',
        i_d => int_RDRFin,
        o_q => int_RDRFout
      );
      
      OE: enARdff_2
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_enable => '1',
        i_d => int_OEin,
        o_q => int_OEout
      );
      
      FE: enARdff_2
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_enable => '1',
        i_d => int_FEin,
        o_q => int_FEout
      );
      
      o_busOut <= int_valueOut;
      o_TDRE <= int_TDREout;
      o_RDRF <= int_RDRFout;
      o_OE <= int_OEout;
      o_FE <= int_FEout;
  
end architecture;
