--test bench for the nbit shift reg

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_as is
end entity TB_as;

architecture test_nas of TB_as is
component nFullAdderSubtractor is
  generic (n : integer);
  port(i_subControl: in std_logic;
          i_a: in std_logic_vector(n-1 downto 0);
          i_b: in std_logic_vector(n-1 downto 0);
          o_carryOut: out std_logic;
          o_sumOut: out std_logic_vector(n-1 downto 0);
          o_overflow: out std_logic);
              
end component nFullAdderSubtractor;

CONSTANT NUM_BITS : integer :=8; --size of add/sub unit

signal iSubControl, oCout : std_logic;
signal oOverflow : std_logic;
signal ia,ib : std_logic_vector(NUM_BITS-1 downto 0);
signal ovalue : std_logic_vector(NUM_BITS-1 downto 0);

begin
  r1 : nFullAdderSubtractor
    generic map(n => NUM_BITS)
    port map(
      i_subControl => iSubControl, 
      i_a => ia, 
      i_b => ib, 
      o_carryOut => oCout,
      o_sumOut => ovalue,
      o_overflow => oOverflow);
          
          
      ia <= "00001111";
      ib <= "11110000";
      iSubControl <='0','1' AFTER 200 PS;
      
end architecture;

configuration nbr of TB is
  for test_nas
    for r1 : nFullAdderSubtractor
              use entity work.nFullAdderSubtractor(rtl)
              generic map (n=> NUM_BITS)
              port map(iSubControl,ia,ib,oCout,ovalue);
            end for;
          end for;
      end configuration nbr;
      
