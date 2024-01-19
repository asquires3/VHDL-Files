library ieee;
use ieee.std_logic_1164.ALL;

entity dividerData is
  -- lots of these were used for debugging and removing them would be a pain,
  -- the only ones that matter is o_count, o_out, and o_remainderGreaterEQ
	port(
		i_dividend, i_divisor : in std_logic_vector(3 downto 0);
		i_clock, i_inc, i_shiftRemainder, i_shiftDividend, i_loadDividend : in std_logic;
		i_loadDivisor, i_loadRemainder, i_loadQuotient, i_resetBar, i_resetCount : in std_logic;
		i_loadFinal, i_loadFinalSign, i_clearRemainder, i_clearQuotient, i_subtractionOK : in std_logic;
		o_count : out std_logic_vector(3 downto 0);
		o_out : out std_logic_vector(7 downto 0);
		o_remainderGreaterEQ : out std_logic;
		o_dividend, o_divisor, o_quotient, o_remainder, o_opOne, o_opTwo : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of dividerData is

	signal int_dividendOut, int_divisorOut, int_remainderOut, int_remainderIn, 
	       int_quotientIn, int_quotientOut, int_divisorIn, int_dividendIn,
		     int_dividendMaskOut, int_remainderOpOne, int_remainderOpTwo, 
		     int_counterValue, int_counterMaskOut, int_comparatorExpanded,
		     int_quotientNONZero, int_remainderNONZero, int_dividendMSBExpanded : std_logic_vector(3 downto 0);
	signal int_expandedSign, int_finalWithSign, int_finalIn, int_finalOut, int_finalSignMasked, int_concatOut : std_logic_vector(7 downto 0);
	signal int_remainderSelector, int_remainderGREQ : std_logic;

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
	
	component comparator4bit
		port(
			i_a,i_b: in std_logic_vector;
			o_aGreaterEQ: out std_logic
		);
	end component;
	
	component oneHotDownCount4bit
		port(
			i_resetBar, i_inc, i_restart	: IN	STD_LOGIC;
			i_clock			: IN	STD_LOGIC;
			o_Value			: OUT	STD_LOGIC_VECTOR
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
	
	component nBitOrrer
		generic (n: integer);
		port(
			i_a,i_b : in std_logic_vector;
			o_out: out std_logic_vector
		);
	end component;
	
	component nBitAnder
		generic (n: integer);
		port(
			i_a,i_b : in std_logic_vector;
			o_out: out std_logic_vector
		);
	end component;
	
	component oneBitAnd
	  port(
	    i_a,i_b : in std_logic;
	    o_out : out std_logic
	  );
	 end component;
	
	component concater4to8
		port(
			i_a,i_b : in std_logic_vector;
			o_out : out std_logic_vector
		);
	end component;
		
	
	begin
	
	   expandValues: process(int_remainderSelector,i_dividend,i_divisor,int_dividendOut)
	     begin
	       int_comparatorExpanded <= (others => int_remainderSelector);
		     int_expandedSign <= (others => (i_dividend(3) xor i_divisor(3)));
		     int_dividendMSBExpanded <= (others => int_dividendOut(3));
	     end process;
		
		divisorMask: nBitAnder
			generic map(n => 4)
			port map(
				i_a => i_divisor,
				i_b => "0111",
				o_out => int_divisorIn
			);
			
		divisor: shiftNBit
			generic map(n => 4, shift => -1)
			port map(
				i_clock => i_clock,
				i_load => i_loadDivisor,
				i_shift => '0',
				i_resetBar => i_resetBar,
				i_value => int_divisorIn,
				o_value => int_divisorOut
			);
		
		dividendMask: nBitAnder
			generic map(n => 4)
			port map(
				i_a => i_dividend,
				i_b => "0111",
				o_out => int_dividendIn
			);
			
		dividend: shiftNBit
			generic map(n => 4, shift => -1)
			port map(
				i_clock => i_clock,
				i_load => i_loadDividend,
				i_shift => i_shiftDividend,
				i_resetBar => i_resetBar,
				i_value => int_dividendIn,
				o_value => int_dividendOut
			);
				
		remainder: shiftNBit
			generic map(n => 4, shift => -1)
			port map(
				i_clock => i_clock,
				i_load => i_loadRemainder,
				i_shift => i_shiftRemainder,
				i_resetBar => i_resetBar,
				i_value => int_remainderIn,
				o_value => int_remainderOut
			);
		
		quotient: shiftNBit
			generic map(n => 4, shift => -1)
			port map(
				i_clock => i_clock,
				i_load => i_loadQuotient,
				i_shift => '0',
				i_resetBar => i_resetBar,
				i_value => int_quotientIn,
				o_value => int_quotientOut
			);
			
		dividendMSBMask: nBitAnder
			generic map(n => 4)
			port map(
				i_a => int_dividendMSBExpanded,
				i_b => "0001",
				o_out => int_dividendMaskOut
			);
			
		remainderOptionOne: nBitOrrer
			generic map(n => 4)
			port map(
				i_a => int_dividendMaskOut,
				i_b => int_remainderOut,
				o_out => int_remainderOpOne
			);
		
		remainderChoice: oneBitAnd --only is subtraction is ok and remainder >= divisor should it be 1
		  port map(
		    i_a => int_remainderGREQ,
		    i_b => i_subtractionOK,
		    o_out => int_remainderSelector
		  );
		  
		remainderSelector: selNBit --select OpTwo if remainder >= divisor and subtraction is ok
			generic map(n => 4)
			port map(
				i_a => int_remainderOpTwo,
				i_b => int_remainderOpOne,
				i_sel => int_remainderSelector,
				o_c => int_remainderNONZero
			);
			
		remainderClearer: selNBit
		  generic map(n=>4)
		  port map(
		    i_a => "0000",
		    i_b => int_remainderNONZero,
		    i_sel => i_clearRemainder,
		    o_c => int_remainderIn
		  );
			
		compareRemainderVSDivisor: comparator4bit --if remainder >= divisor, then reminderSelector = 1
			port map(
				i_a => int_remainderOut,
				i_b => int_divisorOut,
				o_aGreaterEQ => int_remainderGREQ
			);
			
		subtractor: nFullAdderSubtractor --OpTwo, reminder - divisor
			generic map(n => 4)
			port map(
				i_subControl => '1',
				i_a => int_remainderOut,
				i_b => int_divisorOut,
				o_sumOut => int_remainderOpTwo
			);
						
		counter: shiftNBit
			generic map(n => 4, shift => 1)
			port map(
				i_clock => i_clock,
				i_load => i_resetCount,
				i_shift => i_inc,
				i_resetBar => i_resetBar,
				i_value => "1000",
				o_value => int_counterValue
			);
			
		counterMask: nBitAnder
		  generic map(n => 4)
			port map(
				i_a => int_comparatorExpanded,
				i_b => int_counterValue,
				o_out => int_counterMaskOut
			);
			
		quotientInput: nBitOrrer
			generic map(n => 4)
			port map(
				i_a => int_counterMaskOut,
				i_b => int_quotientOut,
				o_out => int_quotientNONZero			
			);
			
		quotientChooser: selNBit
		  generic map(n=>4)
		  port map(
		    i_a => "0000",
		    i_b => int_quotientNONZero,
		    i_sel => i_clearQuotient,
		    o_c => int_quotientIn
		  );
			
		finalOut: shiftNBit
			generic map(n=> 8, shift => -1)
			port map(
				i_clock => i_clock,
				i_load => i_loadFinal,
				i_shift => '0',
				i_resetBar => i_resetBar,
				i_value => int_finalIn,
				o_value => int_finalOut			
			);
		
		finalSelector: selNBit
			generic map(n => 8)
			port map(
				i_a => int_finalSignMasked,
				i_b => int_finalWithSign,
				i_sel => i_loadFinalSign,
				o_c => int_finalIn
			);
		
		finalConcater: concater4to8
			port map(
				i_a => int_remainderOut,
				i_b => int_quotientOut,
				o_out => int_concatOut
			);
		
		finalSignMask: nBitAnder
			generic map(n => 8)
			port map(
				i_a => int_expandedSign,
				i_b => "00001000",
				o_out => int_finalSignMasked
			);
		
		finalOrrer: nBitOrrer
			generic map(n => 8)
			port map(
				i_a => int_finalOut,
				i_b => int_concatOut,
				o_out => int_FinalWithSign			
			);
			
		o_out <= int_finalOut;
		o_count <= int_counterValue;
		o_dividend <= int_dividendOut;
		o_divisor <= int_divisorOut;
		o_remainder <= int_remainderOut;
		o_quotient <= int_quotientOut;
		o_remainderGreaterEQ <= int_remainderSelector;
		o_opOne <= int_remainderOpOne;
		o_opTwo <= int_remainderOpTwo;
		
end architecture;