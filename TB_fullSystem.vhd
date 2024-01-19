

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

entity TB_FULLSYSTEM is
end entity TB_FULLSYSTEM;

architecture test_fullsystem of TB_FULLSYSTEM is

  CONSTANT CLK_PERIOD : time := 100 PS;
    
    signal clock, resetBar, sscs, sw1_msb, sw1_d2, sw1_d1, sw1_lsb, sw2_msb, sw2_d2, sw2_d1, sw2_lsb, txd, aReset, timerDone : std_logic;
    signal msLight, ssLight : std_logic_vector(2 downto 0);
    signal bcd1, bcd2, timerVal, timerLoadVal : std_logic_vector(3 downto 0);
    signal stateTLC : std_logic_vector(5 downto 0);
    signal SCCR, SCSR : std_logic_vector(7 downto 0);
  begin
    
    fullSys: entity work.fullSystem(rtl)
    port map(
     i_clock => clock,
     i_resetBar => resetBar,
     i_sscs => sscs,
     i_sw1_msb => sw1_msb, 
     i_sw1_d2 => sw1_d2, 
     i_sw1_d1 => sw1_d1, 
     i_sw1_lsb => sw1_lsb,
     i_sw2_msb => sw2_msb, 
     i_sw2_d2 => sw2_d2, 
     i_sw2_d1 => sw2_d1, 
     i_sw2_lsb => sw2_lsb,
     o_mstl => msLight,
     o_sstl => ssLight,
     o_bcd1 => bcd1,
     o_bcd2 => bcd2,
     o_TxD => txd,
     o_timerVal => timerVal,
     o_timerLoadVal => timerLoadVal,
     o_timerDone => timerDone,
     o_stateTLC => stateTLC,
     o_actualReset => aReset,
     o_SCCR => SCCR,
     o_SCSR => SCSR
    );
    
    clk : process
        begin
          clock <= '0';
          wait for CLK_PERIOD/2;
          clock <= '1';
          wait for CLK_PERIOD/2;
      end process;
            
    resetBar <= '0', '1' after 600 PS;
    sw1_msb <= '0';
    sw1_d2 <= '1';
    sw1_d1 <= '1';
    sw1_lsb <= '1';
    sw2_msb <= '0';
    sw2_d2 <= '1';
    sw2_d1 <= '0';
    sw2_lsb <= '1';
    sscs <= '0';
    
end architecture;


