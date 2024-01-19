
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_JOHNSONCOUNTER is
end entity TB_JOHNSONCOUNTER;

architecture test_johnsoncouter of TB_JOHNSONCOUNTER is


  CONSTANT CLK_PERIOD : time := 100 PS;
  
  signal resetBar, resetCount, enable, clock : std_logic;
  signal value : std_logic_vector(3 downto 0);
  
  begin
    jc: entity work.njohnsonringcounter(rtl)
    port map(
      i_resetBar => resetBar,
      i_resetCount => resetCount, 
      i_enable => enable,
      i_clock => clock,
      o_value => value
    );
      
      clk_process : process
        begin
          clock <= '0';
          wait for CLK_PERIOD/2;
          clock <= '1';
          wait for CLK_PERIOD/2;
      end process;
      
      
      resetBar <= '0', '1' after 10 PS;
      enable <= '1', '0' after 500 PS;
      resetCount <= '0', '1' after 800 PS;
      
    end architecture;

