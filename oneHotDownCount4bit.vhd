LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


--TODO make sure to properly init with 1000, should work
ENTITY oneHotDownCount4bit IS
	PORT(
		i_resetBar, i_inc	: IN	STD_LOGIC;
		i_restart		: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_Value			: OUT	STD_LOGIC_VECTOR(3 downto 0));
END oneHotDownCount4bit;

ARCHITECTURE rtl OF oneHotDownCount4bit IS
	SIGNAL int_ValueToLoad : std_logic_vector (3 downto 0);
	SIGNAL int_Value, int_notValue : STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL int_vcc: std_logic := '1';

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
	
BEGIN

	int_ValueToLoad(3) <= ((not i_inc and int_Value(3)) or (i_inc and int_Value(0) and int_notValue(3))) or i_restart;
	int_ValueToLoad(2) <= ((not i_inc and int_Value(2)) or (i_inc and int_Value(3) and int_notValue(2))) and not i_restart;
	int_ValueToLoad(1) <= ((not i_inc and int_Value(1)) or (i_inc and int_Value(2) and int_notValue(1))) and not i_restart; 
	int_ValueToLoad(0) <= ((not i_inc and int_Value(0)) or (i_inc and int_Value(1) and int_notValue(0))) and not i_restart;
	
b3: enARdFF_2_high
	PORT MAP (i_resetBar => i_resetBar,
			  i_d => int_ValueToLoad(3), 
			  i_enable => int_vcc,
			  i_clock => i_clock,
			  o_q => int_Value(3),
	      o_qBar => int_notValue(3));
			  
b2: enARdFF_2
	PORT MAP (i_resetBar => i_resetBar,
			  i_d => int_ValueToLoad(2), 
			  i_enable => int_vcc,
			  i_clock => i_clock,
			  o_q => int_Value(2),
	      o_qBar => int_notValue(2));

b1: enARdFF_2
	PORT MAP (i_resetBar => i_resetBar,
			  i_d => int_ValueToLoad(1),
			  i_enable => int_vcc, 
			  i_clock => i_clock,
			  o_q => int_Value(1),
	      o_qBar => int_notValue(1));

b0: enARdFF_2
	PORT MAP (i_resetBar => i_resetBar,
			  i_d => int_ValueToLoad(0), 
			  i_enable => int_vcc,
			  i_clock => i_clock,
			  o_q => int_Value(0),
	      o_qBar => int_notValue(0));
			  
	-- Output Driver
	o_Value	<= int_Value;

END rtl;
