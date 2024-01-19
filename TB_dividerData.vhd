
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_DD is
end entity TB_DD;

-- this isnt useful to you, look at the TB_fullDiv, this is what i needed
-- to play with the different control signals

architecture test_dd of TB_DD is

  CONSTANT CLK_PERIOD : time := 100 PS;
	
	signal int_clock, int_resetBar, int_inc, int_shiR, int_shiD, int_ldDVD, int_ldDVSR, int_ldR, int_ldQ, int_ldF, int_ldFS, int_clR,
	       int_clQ, int_rC, int_subOK : std_logic;
	signal int_dividend, int_divisor, int_curCount : std_logic_vector(3 downto 0);
	signal int_result : std_logic_vector(7 downto 0);
	
	begin
	  
	  dividerC: entity work.dividerdata(rtl)
      port map(
        i_dividend => int_dividend,
        i_divisor => int_divisor,
        i_clock => int_clock,
        i_resetBar => int_resetBar,
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
        i_resetCount => int_rC,
        i_subtractionOK => int_subOK,
        o_count => int_curCount,
        o_out => int_result
      );
	   
	   
	   clk_process : process
        begin
          int_clock<='0';
          wait for CLK_PERIOD/2;
          int_clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      int_resetBar <= '0', '1' AFTER 100 PS;
      int_dividend <= "1110";
      int_divisor <= "0010";
  
end architecture;


