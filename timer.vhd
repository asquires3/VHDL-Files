
library ieee;
use ieee.std_logic_1164.all;

entity timer is 
	port(
		i_resetBar, i_clock_50Mhz, i_clock_1Hz, i_enabled : in std_logic;
		i_countValue : in std_logic_vector(3 downto 0);
		o_timerFinished  : out std_logic;
		o_timerValue : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of timer is
	
	signal int_registerOut, int_registerIn, int_adderOut : std_logic_vector(3 downto 0);
	signal int_timerDone, int_enabledIn, int_choiceOneOut, int_timerNotDone,
		   int_enabled, int_enabledOrReset: std_logic;
		
	component selNBit
		generic(n: integer);
		port(
			i_sel: in std_logic;
			i_a, i_b: in std_logic_vector;
			o_c : out std_logic_vector
		);
	end component;
	
	component nFullAdderSubtractor
		generic(n: integer);
		port(
			i_subControl : in std_logic; --1 for subtraction
			i_a : in std_logic_vector;
			i_b : in std_logic_vector;
			o_carryOut : out std_logic;
			o_sumOut : out std_logic_vector;
			o_overflow : out std_logic
		);
	end component;
	
	component shiftNBit
		generic(
			n: integer;
			shift: integer
		);
		port(
			i_clock, i_load, i_shift, i_resetBar : in std_logic;
            i_value : in std_logic_vector;
            o_value : out std_logic_vector
		);
	end component;
	
	component nBitAnder
		generic (n: integer);
		port(
			i_a,i_b : in std_logic_vector;
			o_out: out std_logic_vector
		);
	end component;	
	
	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	component oneBitAnd
	  port(
	    i_a,i_b : in std_logic;
	    o_out : out std_logic
	  );
	 end component;
	 
	 component isZeroFour
		port(
			i_a : in std_logic_vector;
			o_isZero : out std_logic
		);
	end component;
	 
	begin

	register4bits : shiftNBit
		generic map(n => 4, shift => 1)
		port map(
			i_clock => i_clock_1Hz,
			i_resetBar => i_resetBar,
			i_load => i_enabled,
			i_shift => '0',
			i_value => int_registerIn,
			o_value => int_registerOut
		);
		
	subtractOne : nFullAdderSubtractor
		generic map(n => 4)
		port map(
			i_subControl => '1',
			i_a => int_registerOut,
			i_b => "0001",
			o_sumOut => int_adderOut
		);
		
	regSel : selNBit
		generic map(n => 4)
		port map(
			i_sel => int_timerDone,
			i_a => i_countValue,
			i_b => int_adderOut,
			o_c => int_registerIn
		);
		
	timerDone : isZeroFour
		port map(
			i_a => int_registerOut,
			o_isZero => int_timerDone
		);
		
		o_timerFinished <= int_timerDone;
		o_timerValue <= int_registerOut;
		
	end architecture;
