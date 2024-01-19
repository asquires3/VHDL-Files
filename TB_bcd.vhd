
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_BCD is
end entity TB_BCD;

architecture test_bcd of TB_BCD is

  CONSTANT CLK_PERIOD : time := 100 PS;

  signal clock : std_logic;
  signal bcd1, bcd2 : std_logic_vector(3 downto 0);
  signal vin : std_logic_vector(0 to 3) := "0000";
  
  begin
    
    tim: entity work.bcd4bit(basic)
    port map(
		  i_bcd => vin,
		  o_bcd1 => bcd1,
		  o_bcd2 => bcd2    
    );
    
    vin3 : process
        begin
          wait for CLK_PERIOD/8;
          vin(3) <= not vin(3);
      end process;
      
    vin2 : process
        begin
          wait for CLK_PERIOD/4;
          vin(2) <= not vin(2);
      end process;
      
    vin1 : process
        begin
          wait for CLK_PERIOD/2;
          vin(1) <= not vin(1);
      end process;
      
    vin0 : process
        begin
          wait for CLK_PERIOD;
          vin(0) <= not vin(0);
      end process;
            
end architecture;
