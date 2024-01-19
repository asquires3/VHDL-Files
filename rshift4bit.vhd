library ieee;
use ieee.std_logic_1164.ALL;

entity rshift4bit is
        port(i_clock, i_load, i_shift, i_resetBar : in std_logic;
              i_value : in std_logic_vector(3 downto 0);
              o_value : out std_logic_vector(3 downto 0));
              
end rshift4bit;

architecture rtl of rshift4bit is
        signal int_valueIn, int_valueOut : std_logic_vector(3 downto 0);
        
        component enARdff_2
                port(
                        i_resetBar : in std_logic;
                        i_d : in std_logic;
                        i_enable : in std_logic;
                        i_clock : in std_logic;
                        o_q, o_qBat : out std_logic);
        end component;
        
begin



int_valueIn(0) <= (i_shift AND int_valueOut(1)) or (i_load and i_value(0)) or (not i_shift and int_valueOut(0));
int_valueIn(1) <= (i_shift AND int_valueOut(2)) or (i_load and i_value(1)) or (not i_shift and int_valueOut(1));
int_valueIn(2) <= (i_shift AND int_valueOut(3)) or (i_load and i_value(2)) or (not i_shift and int_valueOut(2));
int_valueIn(3) <= (i_shift AND int_valueOut(0)) or (i_load and i_value(3)) or (not i_shift and int_valueOut(3));

r0: enARdFF_2
        port map(
                i_resetBar => i_resetBar,
                i_d => int_valueIn(0),
                i_enable => '1',
                i_clock => i_clock,
                o_q => int_valueOut(0));

r1: enARdFF_2
        port map(
                i_resetBar => i_resetBar,
                i_d => int_valueIn(1),
                i_enable => '1',
                i_clock => i_clock,
                o_q => int_valueOut(1));
               

r2: enARdFF_2
        port map(
                i_resetBar => i_resetBar,
                i_d => int_valueIn(2),
                i_enable => '1',
                i_clock => i_clock,
                o_q => int_valueOut(2));
                
 
r3: enARdFF_2
        port map(
                i_resetBar => i_resetBar,
                i_d => int_valueIn(3),
                i_enable => '1',
                i_clock => i_clock,
                o_q => int_valueOut(3));
                
        o_value <= int_valueOut;
end architecture rtl;   
   
