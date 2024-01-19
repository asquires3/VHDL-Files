library ieee;
use ieee.std_logic_1164.ALL;

entity mulControl is
	port(
		i_clock, i_resetBar, i_enable, i_b0 : in std_logic;
		i_curCount : in std_logic_vector(3 downto 0);
		o_loadA, o_loadB, o_loadC, o_shiftA, o_shiftB,
		o_loadSign, o_resetCount, o_inc : out std_logic;
		o_curState : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of mulControl is

	signal int_curState, int_nextState: std_logic_vector(3 downto 0);
	signal int_reset : std_logic;

	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT enARdFF_2_high
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	begin
	
	int_nextState(0) <= '0';
	int_nextState(1) <= i_b0 and (int_curState(0) or int_curState(2));
	int_nextState(2) <= int_curState(1) or (((int_curState(2) or int_curState(1)) and not i_b0) and not i_curCount(0));
	int_nextState(3) <= int_curState(2) and i_curCount(0);
	
	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => i_enable,
				i_clock => i_clock,
				o_q => int_curState(0)
			);
			
	states: for i in 1 to 3 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => i_enable,
				i_clock => i_clock,
				o_q => int_curState(i)
			);
		end generate states;
	
	o_loadA <= int_curState(0);
	o_loadB <= int_curState(0);
	o_loadC <= int_curState(0) or int_curState(1);
	o_loadSign <= int_curState(0);
	o_shiftA <= int_curState(2);
	o_shiftB <= int_curState(2);
	o_resetCount <= int_curState(0);
	o_inc <= int_curState(2);
	
	o_curState <= int_curState;
	
end architecture;
