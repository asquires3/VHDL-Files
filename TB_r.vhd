
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_RECIEVER is
end entity TB_RECIEVER;

architecture test_reciever of TB_RECIEVER is

  --run for about 6000PS

  CONSTANT RECIEVER_CLK_PERIOD : time := 50 PS;
  CONSTANT TRANSMIT_CLK_PERIOD : time := 800 PS;
  CONSTANT RXD_PERIOD : time := 400 PS;
  
  signal reciever_clock, transmit_clock : std_logic;
  
  signal resetBar, RxD : std_logic;
  
  signal rdr, rsr : std_logic_vector(7 downto 0);
  signal rc : std_logic_vector(7 downto 0);
  signal cb, c8 : std_logic_vector(3 downto 0);
  
  signal set_rdrf, reset_rdrf, set_oe, reset_oe, set_fe, reset_fe, rdrf : std_logic;
  
  begin
    r: entity work.reciever(rtl)
    port map(
      i_BClkx8 => reciever_clock,
      i_resetBar => resetBar,
      i_RxD => RxD,
      
      i_select => '1',
      
      i_RDRF => rdrf,
      i_OE => '0',
      i_FE => '0',
      
      o_setRDRF => set_rdrf, 
      o_resetRDRF => reset_rdrf, 
      o_setOE => set_oe, 
      o_resetOE => reset_oe, 
      o_setFE => set_fe, 
      o_resetFE => reset_fe,
  
      o_RCout => rc,
      o_RSRout => rsr,
      o_RDRout => rdr,
      o_countBits => cb,
      o_count8 => c8
  );
  
      reciever_clk_process : process
        begin
          reciever_clock<='0';
          wait for RECIEVER_CLK_PERIOD/2;
          reciever_clock<='1';
          wait for RECIEVER_CLK_PERIOD/2;
      end process;
      
      transmit_clk_process : process
        begin
          transmit_clock<='0';
          wait for TRANSMIT_CLK_PERIOD/2;
          transmit_clock<='1';
          wait for TRANSMIT_CLK_PERIOD/2;
      end process;
      
      rxd_process : process
        begin
          Rxd <='1';
          wait for RXD_PERIOD;
          RxD <= '0';
          wait for RXD_PERIOD;
          --Start of the byte I want, should be 11010111 at the end
          RxD <= '1';
          wait for RXD_PERIOD;
          RxD <= '1';
          wait for RXD_PERIOD;
          RxD <= '1';
          wait for RXD_PERIOD;
          RxD <= '0';
          wait for RXD_PERIOD;
          RxD <= '1';
          wait for RXD_PERIOD;
          RxD <= '0';
          wait for RXD_PERIOD;
          RxD <= '1';
          wait for RXD_PERIOD;
          RxD <= '1';
          wait for RXD_PERIOD;
          --End of the byte, 1 for the stop bit
          RxD <= '1';
          wait for RXD_PERIOD;
        end process;
      
      
      resetBar <= '0', '1' after 10 PS;
      rdrf <= '0', '1' after 2000 PS;
      
    end architecture;

