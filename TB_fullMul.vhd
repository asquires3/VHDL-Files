
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_FM is
end entity TB_FM;
	
	
architecture test_fM of TB_FM is
  CONSTANT CLK_PERIOD : time := 100 PS;
	
	signal clock, resetBar, enable : std_logic;
	signal a,b,cont,count : std_logic_vector(3 downto 0);
	signal a7,b7,c : std_logic_vector(7 downto 0);
	
	begin
	  
	  fd: entity work.fullmul(rtl)
	   port map(
	     i_a => a,
	     i_b => b,
	     i_clock => clock,
	     i_resetBar => resetBar,
	     i_enable => enable,
	     o_c => c,
	     o_a => a7,
	     o_b => b7,
	     o_cont => cont,
	     o_count => count
	   );
	   
	   
	   
	   clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      resetBar <= '0', '1' AFTER 100 PS;
      a <= "1011";
      b <= "1111";
      enable <= '1';
  
end architecture;

