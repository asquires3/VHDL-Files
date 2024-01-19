library ieee;
use ieee.std_logic_1164.ALL;

entity dividerControl is
	port(
		i_clock, i_resetBar, i_enable, i_rGREQdvs : in std_logic;
		i_curCount: in std_logic_vector(3 downto 0);
		o_inc, o_shiftRemainder, o_shiftDividend, o_loadDividend, o_loadFinalSign : out std_logic;
		o_loadDivisor, o_loadRemainder, o_loadQuotient, o_loadFinal, o_subtractionOK : out std_logic;
		o_clearRemainder, o_clearQuotient, o_restartCount : out std_logic;
		o_curState : out std_logic_vector(6 downto 0)
	);
end entity;

architecture rtl of dividerControl is

	signal int_curState, int_nextState: std_logic_vector(6 downto 0);
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
	int_nextState(1) <= int_curState(0) or (int_curState(5) and not i_curCount(0));
	int_nextState(2) <= int_curState(1);
	int_nextState(3) <= int_curState(2);
	int_nextState(4) <= int_curState(3) and i_rGREQdvs;
	int_nextState(5) <= int_curState(4) or (int_curState(3) and not i_rGREQdvs);
	int_nextState(6) <= int_curState(5) and i_curCount(0);
	
	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => i_enable,
				i_clock => i_clock,
				o_q =>int_curState(0)
			);
			
	states: for i in 1 to 6 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => i_enable,
				i_clock => i_clock,
				o_q =>int_curState(i)
			);
		end generate states;
	
	o_loadFinalSign <= int_curState(0);
	o_clearQuotient <=  int_curState(0);
	o_clearRemainder <= int_curState(0);
	o_restartCount <= int_curState(0);
	o_loadDividend <= int_curState(0);
	o_loadDivisor <= int_curState(0);
	o_shiftRemainder <= int_curState(1);
	o_loadRemainder <= int_curState(2) or int_curState(4) or int_curState(0);
	o_shiftDividend <= int_curState(3);
	o_loadQuotient <= int_curState(4) or int_curState(0);
	o_inc <= int_curState(5);
	o_loadFinal <= int_curState(6) or int_curState(0);
	o_subtractionOK <= not(int_curState(1) or int_curState(2));
	
	o_curState <= int_curState;
	
end architecture;
