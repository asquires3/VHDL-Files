library ieee;
use ieee.std_logic_1164.all;

-- pretty much finsihed, look into when the bus is writing somewhere

entity AddressDecoder is
    port(
        i_addr : in std_logic_vector(1 downto 0);
        i_rw : in std_logic;
        i_RDR, i_SCSR, i_SCCR, i_outside : in std_logic_vector(7 downto 0);
        o_busValue : out std_logic_vector(7 downto 0);
        o_loadSCCR, o_loadTDR : out std_logic
    );
end entity;

architecture rtl of AddressDecoder is
    
	signal int_SCCRcode, int_outsideCode, int_SCSRcode, int_RDRcode : std_logic;
	signal int_allowSCCRout, int_allowOusitdeOut, int_allowSCSROut, int_allowRDROut : std_logic_vector(7 downto 0);
	
begin
  
  int_SCCRcode <= i_addr(1) and i_rw;
  int_SCSRcode <= not i_addr(1) and i_addr(0) and i_rw;
  int_outsideCode <= not i_rw;
  int_RDRcode <= not i_addr(1) and not i_addr(0) and i_rw;
  
  --this is used to expand a logic bit to a vector
  expansion: process(int_SCCRcode, int_SCSRcode, int_outsideCode, int_RDRcode)
	begin
		int_allowSCCRout <= (others => int_SCCRcode);
		int_allowSCSROut <= (others => int_SCSRcode);
		int_allowOusitdeOut <= (others => int_outsideCode);
		int_allowRDROut <= (others => int_RDRcode);
	end process;
  
  o_loadSCCR <= i_addr(1) and not i_rw;
  o_loadTDR <= not i_addr(1) and not i_addr(0) and not i_rw;
  o_busValue <= (int_allowSCCRout and i_SCCR) or (int_allowSCsRout and i_SCSR) or (int_allowRDROut and i_RDR) or (int_allowOusitdeOut and i_outside);
     
end architecture;





