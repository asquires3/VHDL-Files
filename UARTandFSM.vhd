library ieee;
use ieee.std_logic_1164.all;

entity UARTandFSM is
    port(
      i_clock, i_resetBar : in std_logic;
      i_msLight, i_ssLight : in std_logic_vector(2 downto 0);
      o_TxD : out std_logic;
      
      o_SCCR, o_SCSR : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of UARTandFSM is 
  
  signal int_rw, int_select, int_IRQ, int_TxD, int_clock1KHz : std_logic;
  signal int_data, int_SCCR, int_SCSR : std_logic_vector(7 downto 0);
  signal int_addr : std_logic_vector(1 downto 0);
  
  component fullUART
    port(
      i_clock, i_resetBar, i_rw, i_select, i_RxD : in std_logic;
      i_data : in std_logic_vector(7 downto 0);
      i_addr : in std_logic_vector(1 downto 0);
      o_IRQ, o_TxD : out std_logic;
      
      o_SCCR, o_SCSR : out std_logic_vector(7 downto 0)
    );
  end component;
  
  component UART_FSM
    port(
        i_clock, i_resetBar : in std_logic;
        i_IRQ : in std_logic;
        i_msLight, i_ssLight : in std_logic_vector(2 downto 0);
        i_busIn : in std_logic_vector(7 downto 0);
        o_r_wBar : out std_logic;
        o_address : out std_logic_vector(1 downto 0);
        o_select : out std_logic;
        o_busOut : out std_logic_vector(7 downto 0)
    );
  end component;
	 
	component clk_div
	PORT
	(
		clock_50Mhz				: IN	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC
		);
	end component;
    

  begin
    
    uart: fullUART
      port map(
        i_clock => i_clock,
        i_resetBar => i_resetBar,
        i_rw => int_rw,
        i_select => int_select,
        i_RxD => '1', -- this is only being used to send data, hence keep this at 1 since it is not used
        i_data => int_data,
        i_addr => int_addr,
        o_IRQ => int_IRQ,
        o_TxD => int_TxD,
        
        o_SCCR => int_SCCR,
        o_SCSR => int_SCSR
      );
      
		UART_FSM_CLOCK: clk_div
			port map(
				clock_50Mhz => i_clock,
				clock_1KHz => int_clock1KHz
			);
		
      fsm: UART_FSM
      port map(
        i_clock => int_clock1KHz,
        i_resetBar => i_resetBar,
        i_IRQ => int_IRQ,
        i_busIn => "00000000", -- this is not used since we are not recieving any data
        i_msLight => i_msLight,
        i_ssLight => i_ssLight,
        o_r_wBar => int_rw,
        o_address => int_addr,
        o_select => int_select,
     
        o_busOut => int_data
      );
      
      o_TxD <= int_TxD;
      
      o_SCCR <= int_SCCR;
      o_SCSR <= int_SCSR;
            
    end architecture;