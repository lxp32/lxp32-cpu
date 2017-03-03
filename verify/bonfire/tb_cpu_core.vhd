--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:17:47 02/04/2017
-- Design Name:   
-- Module Name:   /home/thomas/riscv/lxp32-cpu/verify/bonfire/tb_cpu_core.vhd
-- Project Name:  bonfire
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lxp32u_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

use work.log2;
use work.common_pkg.all;
 
ENTITY tb_cpu_core IS
END tb_cpu_core;
 
ARCHITECTURE behavior OF tb_cpu_core IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lxp32u_top
    generic(
		DBUS_RMW: boolean:=false;
		DIVIDER_EN: boolean:=true;
		MUL_ARCH: string:="dsp";
		START_ADDR: std_logic_vector(29 downto 0):=(others=>'0');
		USE_RISCV : boolean := false;
      REG_RAM_STYLE : string := "block"
	 );
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         lli_re_o : OUT  std_logic;
         lli_adr_o : OUT  std_logic_vector(29 downto 0);
         lli_dat_i : IN  std_logic_vector(31 downto 0);
         lli_busy_i : IN  std_logic;
         dbus_cyc_o : OUT  std_logic;
         dbus_stb_o : OUT  std_logic;
         dbus_we_o : OUT  std_logic;
         dbus_sel_o : OUT  std_logic_vector(3 downto 0);
         dbus_ack_i : IN  std_logic;
         dbus_adr_o : OUT  std_logic_vector(31 downto 2);
         dbus_dat_o : OUT  std_logic_vector(31 downto 0);
         dbus_dat_i : IN  std_logic_vector(31 downto 0);
         irq_i : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
    constant TestFile : string :=  "../../lxp32-cpu/riscv_test/csr.hex";
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal lli_dat_i : std_logic_vector(31 downto 0) := (others => '0');
   signal lli_busy_i : std_logic := '0';
 
   signal irq_i : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal lli_re_o : std_logic;
   signal lli_adr_o : std_logic_vector(29 downto 0);
   
   signal finished :  std_logic :='0';
   signal result   :  std_logic_vector(31 downto 0);
   
   
   -- Wishbone Master
   signal dbus_ack_i : std_logic := '0';
   signal dbus_dat_i : std_logic_vector(31 downto 0) := (others => '0');
   
   signal dbus_cyc_o : std_logic;
   signal dbus_stb_o : std_logic;
   signal dbus_we_o : std_logic;
   signal dbus_sel_o : std_logic_vector(3 downto 0);
   signal dbus_adr_o : std_logic_vector(31 downto 2);
   signal dbus_dat_o : std_logic_vector(31 downto 0);
   
   constant slave_adr_high : natural := 27;
   
   -- Memory bus
   signal mem_cyc,mem_stb,mem_we,mem_ack : std_logic;
   signal mem_sel :  std_logic_vector(3 downto 0);
   signal mem_dat_rd,mem_dat_wr : std_logic_vector(31 downto 0);
   signal mem_adr : std_logic_vector(slave_adr_high downto 2);

 -- monitor bus
   signal mon_cyc,mon_stb,mon_we,mon_ack : std_logic;
   signal mon_sel :  std_logic_vector(3 downto 0);
   signal mon_dat_rd,mon_dat_wr : std_logic_vector(31 downto 0);
   signal mon_adr : std_logic_vector(slave_adr_high downto 2);   
   

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
   
  
   constant ram_size : natural := 4096;
   constant ram_adr_width : natural := log2.log2(ram_size);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lxp32u_top 
   generic map (
     USE_RISCV=>true,
     MUL_ARCH=>"dsp"
   )
   PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          lli_re_o => lli_re_o,
          lli_adr_o => lli_adr_o,
          lli_dat_i => lli_dat_i,
          lli_busy_i => lli_busy_i,
          dbus_cyc_o => dbus_cyc_o,
          dbus_stb_o => dbus_stb_o,
          dbus_we_o => dbus_we_o,
          dbus_sel_o => dbus_sel_o,
          dbus_ack_i => dbus_ack_i,
          dbus_adr_o => dbus_adr_o,
          dbus_dat_o => dbus_dat_o,
          dbus_dat_i => dbus_dat_i,
          irq_i => irq_i
        );
        
        
    Inst_sim_bus:  entity work.sim_bus 
      PORT MAP(
		clk_i =>clk_i ,
		rst_i => rst_i,
		s0_cyc_i => dbus_cyc_o,
		s0_stb_i =>dbus_stb_o ,
		s0_we_i => dbus_we_o,
		s0_sel_i => dbus_sel_o,
		s0_ack_o => dbus_ack_i,
		s0_adr_i => dbus_adr_o,
		s0_dat_i => dbus_dat_o,
		s0_dat_o => dbus_dat_i,
		m0_cyc_o => mem_cyc,
		m0_stb_o => mem_stb,
		m0_we_o =>  mem_we,
		m0_sel_o => mem_sel,
		m0_ack_i => mem_ack,
		m0_adr_o => mem_adr,
		m0_dat_o => mem_dat_wr,
		m0_dat_i => mem_dat_rd,
		m1_cyc_o => mon_cyc,
		m1_stb_o => mon_stb,
		m1_we_o =>  mon_we,
		m1_sel_o => mon_sel,
		m1_ack_i => mon_ack,
		m1_adr_o => mon_adr,
		m1_dat_o => mon_dat_wr,
		m1_dat_i => mon_dat_rd 
	);    
        
        
        
    Inst_sim_memory_interface: entity work.sim_memory_interface 
    generic map (
        ram_size => ram_size,
        ram_adr_width =>ram_adr_width,
        RamFileName =>TestFile,
        mode=>"H",
        wbs_adr_high => mem_adr'high
    )
    PORT MAP(
		clk_i => clk_i,
		rst_i => rst_i,
		wbs_cyc_i =>mem_cyc ,
		wbs_stb_i => mem_stb,
		wbs_we_i => mem_we,
		wbs_sel_i =>mem_sel ,
		wbs_ack_o => mem_ack,
		wbs_adr_i => mem_adr,
		wbs_dat_i => mem_dat_wr,
		wbs_dat_o => mem_dat_rd,
		lli_re_i =>lli_re_o ,
		lli_adr_i =>lli_adr_o ,
		lli_dat_o =>lli_dat_i ,
		lli_busy_o => lli_busy_i
	);    

    Inst_monitor:  entity work.monitor 
    generic map(
      VERBOSE=>true
    )
    PORT MAP(
		clk_i => clk_i,
		rst_i => rst_i,
		wbs_cyc_i => mon_cyc,
		wbs_stb_i => mon_stb,
		wbs_we_i => mon_we,
		wbs_sel_i => mon_sel,
		wbs_ack_o => mon_ack,
		wbs_adr_i => mon_adr,
		wbs_dat_i => mon_dat_wr,
		wbs_dat_o => mon_dat_rd,
		finished_o => finished,
		result_o => result
	);

   
   -- Clock process definitions
   clk_i_process :process
   begin
  
      clk_i <= '0';
      wait for clk_i_period/2;
      clk_i <= '1';
      wait for clk_i_period/2;
      if finished='1' then 
        wait; 
      end if;
   
     
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
   

      wait until finished='1';
      report "Test finished with result "& hex_string(result);
		
      wait;
      
   end process;

END;
