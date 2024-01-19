


library ieee;
use ieee.std_logic_1164.ALL;

entity nJohnsonRingCounter is
        --minimum of 2
        generic (n : integer := 4);
        port(i_clock, i_enable, i_resetBar, i_resetCount : in std_logic;
            o_value : out std_logic_vector(n-1 downto 0));
              
end entity;

architecture rtl of nJohnsonRingCounter is
    
    signal int_q, int_d: std_logic_vector(n-1 downto 0);
    signal int_enable, int_finalInverse : std_logic;
  
    component enARdff_2
       port(
          i_resetBar : in std_logic;
          i_d : in std_logic;
          i_enable : in std_logic;
          i_clock : in std_logic;
          o_q, o_qBar : out std_logic);
    end component;
    
    begin
    
    int_enable <= i_enable or i_resetCount;
    int_d_create: process(i_resetCount, int_q)
      begin
          for k in 1 to n-1 loop
            int_d(k) <= not i_resetCount and int_q(k-1);
          end loop;
          int_d(0) <= not i_resetCount and int_finalInverse;
        end process;
    
    enARdff2_0: enARdff_2
      port map(
        i_resetBar => i_resetBar,
        i_d => int_d(0),
        i_enable => int_enable,
        i_clock => i_clock,
        o_q => int_q(0)        
     );
    
    enARdff2_FINAL: enARdff_2
      port map(
        i_resetBar => i_resetBar,
        i_d => int_d(n-1),
        i_enable => int_enable,
        i_clock => i_clock,
        o_q => int_q(n-1),
        o_qBar => int_finalInverse        
     );

  nFF: for k in 1 to n-2 generate
    enARdff2_k: enARdff_2 
    PORT MAP(
      i_resetBar => i_resetBar,
      i_d => int_d(k),
      i_enable => int_enable,
      i_clock => i_clock,
      o_q => int_q(k)
      );
   end generate nFF;
  
   o_value <= int_q;
        
end architecture;

