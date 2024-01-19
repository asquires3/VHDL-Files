
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity fullALU is 
  port(
    i_clock, i_resetBar : in std_logic;
    i_opA, i_opB : in std_logic_vector(3 downto 0);
    i_opSel : in std_logic_vector(1 downto 0);
    o_muxOut : out std_logic_vector(7 downto 0);
    o_carry, o_zero, o_overflow : out std_logic
  );
end entity;

architecture rtl of fullALU is
  
  signal int_dividerE, int_mulE, int_carry, int_overflow, int_subcontrol : std_logic;
  signal int_resultD, int_resultM, int_valueIn, int_valueOut, int_choiceMD, int_resultASas7 : std_logic_vector(7 downto 0);
  signal int_resultAS : std_logic_vector(3 downto 0);
  
  component fullDivider
  port(
    i_clock, i_resetBar, i_enable: in std_logic;
    i_dividend, i_divisor : in std_logic_vector (3 downto 0);
    o_result : out std_logic_vector(7 downto 0)
  );
  end component;
  
  component fullMul
    port(
      i_clock, i_resetBar, i_enable : in std_logic;
      i_a, i_b : in std_logic_vector(3 downto 0);
      o_c : out std_logic_vector(7 downto 0)  
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
	
	component selNBit
		generic(n: integer);
		port(
			i_sel: in std_logic;
			i_a, i_b: in std_logic_vector;
			o_c : out std_logic_vector
		);
	end component;
	
	component concater4to8
		port(
			i_a,i_b : in std_logic_vector;
			o_out : out std_logic_vector
		);
	end component;
	
	begin
	  
	  convOpSel: process(i_opSel)
	  begin
	   int_mulE <= i_opSel(1) and not i_opSel(0);
	   int_dividerE <= i_opSel(1) and i_opSel(0);
	   int_subControl <= i_opSel(0);
	  end process;
	  
	  divider: fullDivider
	  port map(
	   i_clock => i_clock,
	   i_resetBar => i_resetBar,
	   i_enable => int_dividerE,
	   i_dividend => i_opA,
	   i_divisor => i_opB,
	   o_result => int_resultD
	  );
	  
	  mul: fullMul
	  port map(
	   i_clock => i_clock,
	   i_resetBar => i_resetBar,
	   i_enable => int_mulE,
	   i_a => i_opA,
	   i_b => i_opB,
	   o_c => int_resultM
	  );
	  
	  adderSub: nFullAdderSubtractor
			generic map(n => 4)
			port map(
				i_subControl => int_subControl,
				i_a => i_opA,
				i_b => i_opB,
				o_carryOut => int_carry,
				o_overflow => int_overflow,
				o_sumOut => int_resultAS
			);
			
			muxOut: shiftNBit
			 generic map(n => 8, shift => 1)
			 port map(
			   i_clock => i_clock,
			   i_resetBar => i_resetBar,
			   i_shift => '0',
			   i_load => '1',
			   i_value => int_valueIn,
			   o_value => int_valueOut
			 );
			 
			 sel1: selNBit
			   generic map(n=>8)
			   port map(
			     i_a => int_choiceMD,
			     i_b => int_resultASas7,
			     i_sel => i_opSel(1),
			     o_c => int_valueIn
			   );
			   
			 sel2: selNBit
			   generic map(n=> 8)
			   port map(
			     i_a => int_resultD,
			     i_b => int_resultM,
			     i_sel => i_opSel(0),
			     o_c => int_choiceMD
			   );
			   
			ASRto7bit: concater4to8
			port map(
				i_a => "0000",
				i_b => int_resultAS,
				o_out => int_resultASas7
			);
			
			o_overflow <= int_overflow and not i_opSel(1);
			o_carry <= int_carry and not i_opSel(1);
			o_zero <= not(int_valueOut(7) or int_valueOut(6) or int_valueOut(5) or int_valueOut(4) or int_valueOut(3) or int_valueOut(2) or int_valueOut(1) or int_valueOut(0));
			o_muxOut <= int_valueOut;
			
		end architecture; 