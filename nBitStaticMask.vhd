library ieee;
use ieee.std_logic_1164.all;

entity nBitStaticMask is 

  generic(
    mask: std_logic_vector := X"0000"
);

port(
	i_in: in std_logic_vector(mask'length-1 downto 0);
	o_out: out std_logic_vector(mask'length-1 downto 0)
);

end entity

architecture basic of nBitStaticMask is

	signal int_out: std_logic_vector(mask'length-1 downto 0);
	
	COMPONENT nBitAnder
	  generic(n: integer);
	PORT(
		i_a,i_b: in std_logic_vector;
		o_out: out std_logic_vector
		);
	END COMPONENT;
	
	begin
	
		ander: nBitAnder
	     generic map(n => mask'length);
		 port map(
			i_a => i_in;
			i_b => mask;
			o_out => int_out
		 );
	o_out <= int_out;
	
	end architecture;