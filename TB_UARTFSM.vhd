
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_UARTFSM is
end entity TB_UARTFSM;

architecture test_uartfsm of TB_UARTFSM is

  CONSTANT CLK_PERIOD : time := 100 PS;

  signal i: integer := 1;

  signal clock, resetBar, irq, rwBar : std_logic;
  signal msLight, ssLight : std_logic_vector(2 downto 0);
  signal busIn, busOut, char :std_logic_vector(7 downto 0);
  signal address : std_logic_vector(1 downto 0);
  signal sel : std_logic;
  
  signal curState, nextState, counter : std_logic_vector(3 downto 0); 
  signal curMs, curSS : std_logic_vector(2 downto 0);
  
  --shamelessly stolen from https://stackoverflow.com/questions/15406887/vhdl-convert-vector-to-string
  function to_string ( a: std_logic_vector) return string is
  variable b : string (1 to a'length) := (others => NUL);
    variable stri : integer := 1; 
      begin
       for i in a'range loop
          b(stri) := std_logic'image(a((i)))(2);
          stri := stri+1;
        end loop;
      return b;
    end function;
  begin
    
    uartfsm: entity work.uart_fsm(rtl)
    port map(
        i_clock => clock,
        i_resetBar => resetBar,
        i_IRQ => irq,
        i_msLight => msLight,
        i_ssLight => ssLight,
        i_busIn => busIn,
        o_r_wBar => rwBar,
        o_address => address,
        o_select => sel,
        o_busOut => busOut,
        
        o_curState => curState,
        o_nextState => nextState,
        o_counter => counter,
        o_curMs => curMS,
        o_curSs => curSS
    );
    
    clk : process
        begin
          clock <= '0';
          wait for CLK_PERIOD/2;
          clock <= '1';
          wait for CLK_PERIOD/2;
      end process;
      
    irqGen : process
      begin
        irq <= '0';
        wait for (CLK_PERIOD*4) - 50 PS;
        irq <= '1';
        wait for CLK_PERIOD;
      end process;
      
     -- lightChange : process(curState(1))
     --   begin
     --     if(curState(1) = '1') then
    --        if(i mod 4 = 0) then
     --         ssLight <= "100";
    --          msLight <= "001";
      --      elsif(i mod 4 = 1) then
      --        ssLight <= "010";
     --         msLight <= "001";
     --       elsif(i mod 4 = 2) then
     --         ssLight <= "001";
    --          msLight <= "100";
     --       elsif(i mod 4 = 3) then
    --          ssLight <= "001";
     --         msLight <= "010";
     --       else
     --         ssLight <= "001";
    --          msLight <= "100";
    --      end if;
    --    else
    --      ssLight <= "001";
    --      msLight <= "100";
    --    end if;
    --      i <= i+1;
    --    end process;
        
      charChange : process(char)
        begin
          if(curState(2) = '1') then
            report "" & to_string(char);
          end if;
        end process;
      resetBar <= '0', '1' after 200 PS;
      
      msLight <= "100";
      ssLight <= "001";
      
      char <= "0" & busOut(7 downto 1);
            
end architecture;


