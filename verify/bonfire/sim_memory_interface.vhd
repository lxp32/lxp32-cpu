----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:29:10 09/04/2016 
-- Design Name: 
-- Module Name:    memory_interface - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sim_memory_interface is
generic (
     ram_adr_width : natural;
     ram_size : natural;
     wbs_adr_high : natural;
	  RamFileName : string := "meminit.ram";
	  mode : string := "B"
	 );
port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		wbs_cyc_i: in std_logic;
		wbs_stb_i: in std_logic;
		wbs_we_i: in std_logic;
		wbs_sel_i: in std_logic_vector(3 downto 0);
		wbs_ack_o: out std_logic;
		wbs_adr_i: in std_logic_vector(wbs_adr_high downto 2);
		wbs_dat_i: in std_logic_vector(31 downto 0);
		wbs_dat_o: out std_logic_vector(31 downto 0);
  
		
		lli_re_i: in std_logic;
		lli_adr_i: in std_logic_vector(29 downto 0);
		lli_dat_o: out std_logic_vector(31 downto 0);
		lli_busy_o: out std_logic
	);
end sim_memory_interface;

architecture Behavioral of sim_memory_interface is



signal  instr_ram_adr,data_ram_adr : std_logic_vector(ram_adr_width-1 downto 0);
signal ram_a_we: std_logic_vector(3 downto 0);
signal ack_read, ack_write : std_logic;

begin

    instr_ram_adr <= lli_adr_i(ram_adr_width-1  downto 0);
    data_ram_adr <=    wbs_adr_i(ram_adr_width+1  downto 2);
	
    lli_busy_o <= '0';
  
  -- Wishbone ACK 
  process (clk_i) is
  begin
	if rising_edge(clk_i) then     
		ack_read<=wbs_cyc_i and wbs_stb_i and not wbs_we_i;
	end if;
  end process;

   ack_write<=wbs_cyc_i and wbs_stb_i and wbs_we_i;
   wbs_ack_o<=ack_read or ack_write;

   
     -- RAM WREN Signals   
   gen_ram_a_we: for i in 3 downto 0 generate
	    ram_a_we(i)<='1' when wbs_cyc_i='1' and wbs_stb_i='1' and wbs_we_i='1' and wbs_sel_i(i)='1' 
	                           else '0';
  end generate;	
   
   

   
      ram: entity work.sim_MainMemory 
        generic map (
           ADDR_WIDTH =>ram_adr_width,
           SIZE => ram_size,
           RamFileName => RamFileName,
           mode => mode
                      
        )
           
      PORT MAP(
         DBOut =>wbs_dat_o,
         DBIn => wbs_dat_i,
         AdrBus => data_ram_adr,
         ENA => wbs_cyc_i,
         WREN => ram_a_we,
         CLK => clk_i,
         CLKB =>clk_i ,
         ENB =>lli_re_i ,
         AdrBusB =>instr_ram_adr,
         DBOutB => lli_dat_o
      );


  
  
end Behavioral;

