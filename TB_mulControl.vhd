

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_MC is
end entity TB_MC;

architecture test_mc of TB_MC is

  CONSTANT CLK_PERIOD : time := 100 PS;
	
  signal b0, la, lb, lc, ls, sa, sb, rc, inc, clock, resetBar, enable : std_logic;
  signal contState, count : std_logic_vector(3 downto 0);
  	
	begin
	  
	  mulC: entity work.mulControl(rtl)
      port map(
        i_clock => clock,
        i_resetBar => resetBar,
        i_enable => enable,
        i_curCount => count,
        i_b0 => b0,
        o_loadA => la,
        o_loadB => lb,
        o_loadC => lc,
        o_loadSign => ls,
        o_shiftA => sa,
        o_shiftB => sb,
        o_resetCount => rc,
        o_inc => inc,
        o_curState => contState
      );
	   
	   
	   clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      resetBar <= '0', '1' AFTER 100 PS;
      enable <= '1';
      b0 <= '1', '0' AFTER 600 PS;
      count <= "0100";
  
end architecture;


