

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_ADDRESSDECODER is
end entity TB_ADDRESSDECODER;

architecture test_addressdecoder of TB_ADDRESSDECODER is

  CONSTANT CLK_PERIOD : time := 100 PS;
  
  signal loadTDR, loadSCCR : std_logic;
  signal rw : std_logic := '0';
  signal addr : std_logic_vector(1 downto 0) := "00";
  signal rdr, scsr, sccr, z, busValue : std_logic_vector(7 downto 0);
  
  begin
    
    ad: entity work.AddressDecoder(rtl)
    port map(
		  i_addr => addr,
		  i_rw => rw,
		  i_RDR => rdr,
		  i_SCSR => scsr,
		  i_SCCR => sccr,
		  i_outside => "01000000",
		  o_busValue => busValue   ,
		  o_loadTDR => loadTDR,
		  o_loadSCCR => loadSCCR
    );
      
     
    addr1 : process
        begin
          wait for CLK_PERIOD*4;
          addr(1) <= not addr(1);
      end process;
      
    addr0 : process
        begin
          wait for CLK_PERIOD*2;
          addr(0) <= not addr(0);
      end process;
    
    rwp : process
      begin
          wait for CLK_PERIOD;
          rw <= not rw;
        end process;
            
      rdr <= "00000001";
      sccr <= "00000100";
      scsr <= "00010000";
end architecture;

