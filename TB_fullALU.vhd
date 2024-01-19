LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_ALU is
end entity TB_ALU;
	
	
architecture test_alu of TB_ALU is
  CONSTANT CLK_PERIOD : time := 100 PS;
	
	signal clock, resetBar, carry, zero, overflow : std_logic;
	signal a,b : std_logic_vector(3 downto 0);
	signal opSel : std_logic_vector (1 downto 0);
	signal result : std_logic_vector (7 downto 0);
	
	begin
	  
	  fd: entity work.fullalu(rtl)
	   port map(
       i_clock => clock,
       i_resetBar => resetBar,
       i_opA => a, 
       i_opB => b,
       i_opSel => opSel,
       o_muxOut => result,
       o_carry => carry,
       o_zero => zero,
       o_overflow => overflow
	   ); 
	   
	   clk_process : process
        begin
          clock<='0';
          wait for CLK_PERIOD/2;
          clock<='1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      resetBar <= '0', '1' AFTER 100 PS;
      a <= "0111";
      b <= "1010";
      opSel <= "11"; --change this for change in what you do
  
end architecture;


