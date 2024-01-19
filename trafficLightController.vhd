library ieee;
use ieee.std_logic_1164.ALL;

entity trafficLightController is
	port(
		i_clock, i_resetBar, i_timerDone, i_ssSensor : in std_logic;
		i_msc, i_ssc : in std_logic_vector(3 downto 0);
		o_enableTimer : out std_logic;
		o_timerLoadValue : out std_logic_vector(3 downto 0);
		o_state : out std_logic_vector(5 downto 0);
		o_msLight, o_ssLight : out std_logic_vector(2 downto 0)
	);
end entity;

architecture rtl of trafficLightController is
	
	constant SST : std_logic_vector(3 downto 0) := "0011";
	constant MT : std_logic_vector(3 downto 0) := "0111";
	
	signal int_curState, int_nextState : std_logic_vector(5 downto 0);
	signal int_selOneOut, int_selTwoOut, int_selThreeOut, int_selFourOut : std_logic_vector(3 downto 0);
	signal int_ssLight, int_msLight : std_logic_vector(2 downto 0);
	signal int_x0,int_x1 : std_logic;
	
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
	
	component oneBitOr
	  port(
	    i_a,i_b : in std_logic;
	    o_out : out std_logic
	  );
	 end component;
	 
	 component selNBit
		generic(n: integer);
		port(
			i_sel: in std_logic;
			i_a, i_b: in std_logic_vector;
			o_c : out std_logic_vector
		);
	end component;
	
	component msLight
		port(
			i_a: in std_logic_vector;
			o_light: out std_logic_vector
		);
	end component;
	
	component ssLight
		port(
			i_a: in std_logic_vector;
			o_light: out std_logic_vector
		);
	end component;
	
	begin
	
	int_nextState(0) <= '0';
	
	int_nextState(1) <= (int_curState(5) and i_timerDone) or (int_curState(1) and not i_timerDone) or int_curState(0);
	int_nextState(2) <= (int_curState(1) and i_timerDone) or (int_curState(2) and i_ssSensor);
	int_nextState(3) <= (int_curState(2) and not i_ssSensor) or (int_curState(3) and not i_timerDone);
	int_nextState(4) <= (int_curState(3) and i_timerDone) or (int_curState(4) and not i_timerDone);
	int_nextState(5) <= (int_curState(4) and i_timerDone) or (int_curState(5) and not i_timerDone);
	
	s_0: enARdFF_2_high
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(0),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(0)
			);
			
	states: for i in 1 to 5 generate
		s_i: enARdFF_2
			port map(
				i_resetBar => i_resetBar,
				i_d => int_nextState(i),
				i_enable => '1',
				i_clock => i_clock,
				o_q => int_curState(i)
			);
		end generate states;
		
	ssLightMap : ssLight
		port map(
			i_a => int_curState, -- 5bit
			o_light => int_ssLight -- 3bit
		);
		
	msLightMap : msLight
		port map(
			i_a => int_curState,-- 5bit
			o_light => int_msLight -- 3bit
		);
		
	x0 : oneBitOr
		port map(
			i_a => int_curState(0),
			i_b => int_curState(5),
			o_out => int_x0
		);
		
	x1 : oneBitOr
		port map(
			i_a => int_curState(2),
			i_b => int_curState(4),
			o_out => int_x1
		);
		
	selOne : selNBit
		generic map(n => 4)
		port map(
			i_sel => int_x0,
			i_a => i_msc,
			i_b => "0000",
			o_c => int_selOneOut
		);	
		
	selTwo : selNBit
		generic map(n => 4)
		port map(
			i_sel => int_curState(3),
			i_a => i_ssc, 
			i_b => int_selOneOut,
			o_c => int_selTwoOut
		);	
		
	selThree : selNBit
		generic map(n => 4)
		port map(
			i_sel => int_curState(4),
			i_a => SST,
			i_b => MT,
			o_c => int_selThreeOut
		);
		
	selFour : selNBit
		generic map(n => 4)
		port map(
			i_sel => int_x1,
			i_a => int_selThreeOut,
			i_b => int_selTwoOut,
			o_c => int_selFourOut
		);
		
	o_enableTimer <= not int_curState(2) or (int_curState(2) and i_ssSensor);
	o_timerLoadValue <= int_selFourOut;
	o_state <= int_curState;
	o_msLight <= int_msLight;
	o_ssLight <= int_ssLight;
	
end architecture;