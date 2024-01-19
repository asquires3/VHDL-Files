library ieee;
use ieee.std_logic_1164.all;

-- TIE RIE 000 baudSel(3)

entity SCCR is
    port(
      i_clock, i_resetBar, i_load, i_select : in std_logic;
      i_busIn : in std_logic_vector(7 downto 0);
      o_busOut : out std_logic_vector(7 downto 0);
      o_TIE, o_RIE : out std_logic;
      o_baudRateSel : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of SCCR is
  
  signal int_loadReg : std_logic;
  signal int_regOut : std_logic_vector(7 downto 0);
  
 	component shiftNBit
		generic(
			n: integer;
			shift: integer
		);
		port(
			i_clock, i_load, i_shift, i_resetBar : in std_logic;
      i_value : in std_logic_vector;
      o_value : out std_logic_vector
		);
	end component;
  
begin
  
  --only load if the load is sent as well as UART enabled
  int_loadReg <= i_load and i_select;
  
  reg : shiftNBit
    generic map(
      n => 8,
      shift => 1
    )
    port map(
      i_clock => i_clock,
      i_load => int_loadReg,
      i_shift => '0',
      i_resetBar => i_resetBar,
      i_value => i_busIn,
      o_value => int_regOut
    );
    
    o_busOut <= int_regOut;
    o_TIE <= int_regOut(7);
    o_RIE <= int_regOut(6);
    o_baudRateSel <= int_regOut(2 downto 0);
  
end architecture;
