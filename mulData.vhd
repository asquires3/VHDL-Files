library ieee;
use ieee.std_logic_1164.ALL;

entity mulData is
	port(
		i_a, i_b: in std_logic_vector (3 downto 0);
		i_loadA, i_loadB, i_loadSign, i_loadC, i_shiftA, i_shiftB,
		i_resetCount, i_inc, i_clock, i_resetBar : in std_logic;
		o_b0 : out std_logic;
		o_curCount : out std_logic_vector(3 downto 0);
		o_a,o_b,o_out : out std_logic_vector(7 downto 0)
	);
end entity;

architecture rtl of mulData is
  
    signal int_AIn, int_BIn, int_CIn, int_AOut, int_BOut, int_COut, 
           int_aMaskIn, int_bMaskIn, int_cOpOne, int_cOpTwo, int_expandedSign : std_logic_vector (7 downto 0);
    signal int_count : std_logic_vector (3 downto 0);
  
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

	component nBitAnder
		generic (n: integer);
		port(
			i_a,i_b : in std_logic_vector;
			o_out: out std_logic_vector
		);
	end component;

  begin
    
    expandValues: process(i_a,i_b)
	     begin
		     int_expandedSign <= (others => (i_a(3) xor i_b(3)));
		     int_aMaskIn <= "00000"&i_a(2 downto 0);
		     int_bMaskIn <= "00000"&i_b(2 downto 0);
	     end process;
	     
	     
	  aMask: nBitAnder
			generic map(n => 8)
			port map(
				i_a => int_aMaskIn,
				i_b => "00000111",
				o_out => int_AIn
			);
			
    a: shiftNbit
      generic map(n => 8, shift => -1)
      port map(
        i_clock => i_clock,
        i_load => i_loadA,
        i_shift => i_shiftA,
        i_resetBar => i_resetBar,
        i_value => int_AIn,
        o_value => int_AOut
      );
      
    bMask: nBitAnder
			generic map(n => 8)
			port map(
				i_a => int_bMaskIn,
				i_b => "00000111",
				o_out => int_BIn
			);
			  
    b: shiftNbit
      generic map(n => 8, shift => 1)
      port map(
        i_clock => i_clock,
        i_load => i_loadB,
        i_shift => i_shiftB,
        i_resetBar => i_resetBar,
        i_value => int_BIn,
        o_value => int_BOut
      );
    
    cOpTwo : nBitAnder
      generic map(n => 8)
      port map(
        i_a => int_expandedSign,
        i_b => "10000000",
        o_out => int_cOpTwo
      );
    
    cChoice : selNbit
      generic map(n => 8)
      port map(
        i_a => int_cOpTwo,
        i_b => int_cOpOne,
        i_sel => i_loadSign,
        o_c => int_cIn
      );
             
    c: shiftNbit
      generic map(n => 8, shift => 1)
      port map(
        i_clock => i_clock,
        i_load => i_loadC,
        i_shift => '0',
        i_resetBar => i_resetBar,
        i_value => int_CIn,
        o_value => int_COut
      );
      
    count: shiftNbit
      generic map(n => 4, shift => 1)
      port map(
        i_clock => i_clock,
        i_load => i_resetCount,
        i_shift => i_inc,
        i_resetBar => i_resetBar,
        i_value => "1000",
        o_value => int_count
      );
      
  		adder: nFullAdderSubtractor
			generic map(n => 8)
			port map(
				i_subControl => '0', --always zero for addition only
				i_a => int_aOut,
				i_b => int_cOut,
				o_sumOut => int_cOpOne
			);
			
			o_a <= int_aOut;
			o_b <= int_bOut;
			o_curCount <= int_count;
			o_b0 <= (int_bOut(1)) or (i_loadSign and i_b(0));
			o_out <= int_cOut;
			
	end architecture;