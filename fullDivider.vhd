library ieee;
use ieee.std_logic_1164.ALL;

entity fullDivider is
  port(
    i_clock, i_resetBar, i_enable : in std_logic;
    i_dividend, i_divisor : in std_logic_vector(3 downto 0);
    o_count : out std_logic_vector(3 downto 0);
    o_result : out std_logic_vector(7 downto 0);
		o_remainderGreaterEQ, o_subOK : out std_logic;
    o_controlState: out std_logic_vector(6 downto 0);
		o_dividend, o_divisor, o_quotient, o_remainder, o_opOne, o_opTwo : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of fullDivider is
  
  signal int_inc, int_shiD, int_shiR, int_ldDVD, int_ldDVSR, int_ldR, int_ldQ,
         int_ldF, int_ldFS, int_rC, int_clQ, int_clR, rGREQd, int_subOK : std_logic;
  signal int_curCount : std_logic_vector(3 downto 0);
  signal int_controlState : std_logic_vector(6 downto 0);
  signal int_result : std_logic_vector(7 downto 0);
  signal curDvs, curDvd, curR, curQ, opOne, opTwo : std_logic_vector (3 downto 0);
  
  component dividerData
    port(
      i_dividend, i_divisor : in std_logic_vector(3 downto 0);
		  i_clock, i_inc, i_shiftRemainder, i_shiftDividend, i_loadDividend : in std_logic;
		  i_loadDivisor, i_loadRemainder, i_loadQuotient, i_resetBar, i_resetCount : in std_logic;
		  i_loadFinal, i_loadFinalSign, i_clearRemainder, i_clearQuotient, i_subtractionOK : in std_logic;
		  o_count : out std_logic_vector(3 downto 0);
		  o_remainderGreaterEQ : out std_logic;
		  o_out : out std_logic_vector(7 downto 0);
		  o_dividend, o_divisor, o_quotient, o_remainder, o_opOne, o_opTwo : out std_logic_vector(3 downto 0)
    );
  end component;
  
  component dividerControl
    port(
      i_clock, i_resetBar,i_enable, i_rGREQdvs : in std_logic;
		  i_curCount: in std_logic_vector(3 downto 0);
		  o_inc, o_shiftRemainder, o_shiftDividend, o_loadDividend, o_loadFinalSign : out std_logic;
		  o_loadDivisor, o_loadRemainder, o_loadQuotient, o_loadFinal : out std_logic;
		  o_clearRemainder, o_clearQuotient, o_restartCount, o_subtractionOK : out std_logic;
		  o_curState : out std_logic_vector(6 downto 0)
    );
  end component;
  
  begin
    
    dividerD: dividerData
      port map(
        i_dividend => i_dividend,
        i_divisor => i_divisor,
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_inc => int_inc,
        i_shiftRemainder => int_shiR,
        i_shiftDividend => int_shiD,
        i_loadDividend => int_ldDVD,
        i_loadDivisor => int_ldDVSR,
        i_loadRemainder => int_ldR,
        i_loadQuotient => int_ldQ,
        i_loadFinal => int_ldF,
        i_loadFinalSign => int_ldFS,
        i_clearRemainder => int_clR,
        i_clearQuotient => int_clQ,
        i_subtractionOK => int_subOK,
        i_resetCount => int_rC,
        o_count => int_curCount,
        o_out => int_result,
        o_dividend => curDvd,
        o_divisor => curDvs,
        o_opOne => opOne,
        o_opTwo => opTwo,
        o_quotient => curQ,
        o_remainder => curR,
        o_remainderGreaterEQ => rGREQd
      );
      
    dividerC: dividerControl
      port map(
        i_clock => i_clock,
        i_enable => i_enable,
        i_resetBar => i_resetBar,
        i_rGREQdvs => rGREQd,
        i_curCount =>int_curCount,
        o_inc => int_inc,
        o_shiftRemainder => int_shiR,
        o_shiftDividend => int_shiD,
        o_loadDividend => int_ldDVD,
        o_loadFinalSign => int_ldFS,
        o_loadDivisor =>  int_ldDVSR,
        o_loadRemainder => int_ldR,
        o_loadQuotient => int_ldQ,
        o_loadFinal => int_ldF,
        o_clearRemainder => int_clR,
        o_clearQuotient => int_clQ,
        o_restartCount => int_rC,
        o_subtractionOK => int_subOK,
        o_curState => int_controlState
      );
  
	o_dividend <= curDvd;
	o_divisor <= curDvs;
	o_quotient <= curQ;
	o_remainder <= curR;
  o_count <= int_curCount;
  o_controlState <= int_controlState;
  o_result <= int_result;
  o_remainderGreaterEQ <= rGREQd;
  o_subOK <= int_subOK;
  o_opOne <= opOne;
  o_opTwo <= opTwo;
end architecture;      
