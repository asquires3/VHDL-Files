
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_DC is
end entity TB_DC;

-- this isnt useful to you, look at the TB_fullDiv, this is what i needed
-- to verify the different control signals

architecture test_dc of TB_DC is

  CONSTANT CLK_PERIOD : time := 100 PS;
	
	signal int_clock, int_resetBar, int_inc, int_shiD, int_shiR, int_ldDVD, int_ldDVSR, int_ldR, int_ldQ,
         int_ldF, int_ldFS, int_rC, int_clQ, int_clR, int_enable, int_rGREQdvs : std_logic;
  signal int_curCount : std_logic_vector(3 downto 0);
  signal int_curState : std_logic_vector(6 downto 0);
	
	begin
	  
	  dividerC: entity work.dividerControl(rtl)
      port map(
        i_enable => int_enable,
        i_clock => int_clock,
        i_resetBar => int_resetBar,
        i_curCount =>int_curCount,
        i_rGREQdvs => int_rGREQdvs,
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
        o_curState => int_curState
      );
	   
	   
	   clk_process : process
        begin
          int_clock<='0';
          wait for CLK_PERIOD/2;
          int_clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      int_resetBar <= '0', '1' AFTER 100 PS;
      int_enable <= '1';
      int_curCount <= "0100";
  
end architecture;

