
library ieee;
use ieee.std_logic_1164.ALL;

entity fullMul is
  port(
    i_a, i_b : in std_logic_vector(3 downto 0);
    i_clock, i_resetBar, i_enable : in std_logic;
    o_a,o_b,o_c : out std_logic_vector(7 downto 0);
    o_cont, o_count : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of fullMul is

  signal la,lb,lc,ls,sa,sb,rc,inc,b0 : std_logic;
  signal contState, count : std_logic_vector (3 downto 0);
  signal a,b,dOut : std_logic_vector (7 downto 0);

  component mulData
    port(
      i_a, i_b: in std_logic_vector (3 downto 0);
		  i_loadA, i_loadB, i_loadSign, i_loadC, i_shiftA, i_shiftB,
		  i_resetCount, i_inc, i_clock, i_resetBar : in std_logic;
		  o_b0 : out std_logic;
		  o_curCount : out std_logic_vector (3 downto 0);
		  o_a,o_b,o_out : out std_logic_vector(7 downto 0)
    );
  end component;

  component mulControl
    port(
      i_clock, i_resetBar, i_enable, i_b0 : in std_logic;
	 	  i_curCount : in std_logic_vector(3 downto 0);
		  o_loadA, o_loadB, o_loadC, o_shiftA, o_shiftB,
		  o_loadSign, o_resetCount, o_inc : out std_logic;
		  o_curState : out std_logic_vector(3 downto 0)
		);
  end component;
  
  begin
    
    mulD: mulData
      port map(
        i_a => i_a,
        i_b => i_b,
        i_loadA => la,
        i_loadB => lb,
        i_loadC => lc,
        i_loadSign => ls,
        i_shiftA => sa,
        i_shiftB => sb,
        i_resetCount => rc,
        i_inc => inc,
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        o_b0 => b0,
        o_curCount => count,
        o_out => dOut,
        o_a => a,
        o_b => b
      );
      
    mulC: mulControl
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_enable => i_enable,
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
      
      o_a <= a;
      o_b <= b;
      o_c <= dOut;
      o_cont <= contState;
      o_count <= count;

end architecture;      

