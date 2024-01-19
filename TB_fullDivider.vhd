LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_FD is
end entity TB_FD;
	
	
architecture test_fd of TB_FD is
  CONSTANT CLK_PERIOD : time := 100 PS;
	
	signal clock, resetBar, enable, rGREQd, subOK: std_logic;
	signal dividend, divisor, curCount, dataDvd, dataDvs, dataQ, dataR, opOne, opTwo :std_logic_vector(3 downto 0);
	signal controlS : std_logic_vector(6 downto 0);
	signal result : std_logic_vector(7 downto 0);
	
	begin
	  
	  fd: entity work.fulldivider(rtl)
	   port map(
	     i_clock => clock,
	     i_resetBar => resetBar,
	     i_enable => enable,
	     i_dividend => dividend,
	     i_divisor => divisor,
	     o_result => result,
	     o_controlState => controlS,
	     o_count => curCount,
		   o_dividend => dataDvd,
		   o_divisor => dataDvs,
		   o_quotient => dataQ,
		   o_remainder => dataR,
		   o_remainderGreaterEQ=>rGREQd,
		   o_subOK => subOK,
		   o_opOne => opOne,
		   o_opTwo => opTwo
	   );
	   
	   
	   
	   clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      resetBar <= '0', '1' AFTER 100 PS;
      dividend <= "0110";
      divisor <= "1100";
      enable <= '1';
  
end architecture;
