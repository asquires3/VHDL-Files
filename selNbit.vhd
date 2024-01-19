
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity selNbit is
  generic(
    n :integer := 4
);
	port(i_sel : in STD_LOGIC;
	     i_a, i_b : in STD_LOGIC_VECTOR(n-1 downto 0);
			o_c : out STD_LOGIC_VECTOR(n-1 downto 0));
end entity selNbit;

--if sel is active get a, otherwise b
architecture struct of selNbit is

  signal out_c : std_logic_vector(n-1 downto 0);
  
  COMPONENT sel1bit
    PORT(
     i_a : IN STD_LOGIC;
     i_b : IN STD_LOGIC;
     i_sel : IN STD_LOGIC;
     o_c : OUT STD_LOGIC
    );
  END COMPONENT;
  
	begin
	nSel: for i in 0 to n-1 generate
    sel1bit_K: sel1bit
      port map(
        i_a => i_a(i),
        i_b => i_b(i),
        i_sel => i_sel,
        o_c => out_c(i)
      );
  end generate nSel;

	o_c <= out_c;

end architecture struct;
