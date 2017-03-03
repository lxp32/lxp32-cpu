--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:20:35 09/18/2016
-- Design Name:   
-- Module Name:   C:/daten/development/fpga/lxp32proj/lxp32-cpu/ut/tb_riscv_decode.vhd
-- Project Name:  lxp32_01
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: riscv_decode
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
 
use work.riscv_decodeutil.all; 
 
ENTITY tb_riscv_decode IS
END tb_riscv_decode;
 
ARCHITECTURE behavior OF tb_riscv_decode IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT riscv_decode
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         word_i : IN  std_logic_vector(31 downto 0);
         next_ip_i : IN  std_logic_vector(29 downto 0);
         valid_i : IN  std_logic;
         jump_valid_i : IN  std_logic;
         ready_o : OUT  std_logic;
         interrupt_valid_i : IN  std_logic;
         interrupt_vector_i : IN  std_logic_vector(2 downto 0);
         interrupt_ready_o : OUT  std_logic;
         sp_raddr1_o : OUT  std_logic_vector(7 downto 0);
         sp_rdata1_i : IN  std_logic_vector(31 downto 0);
         sp_raddr2_o : OUT  std_logic_vector(7 downto 0);
         sp_rdata2_i : IN  std_logic_vector(31 downto 0);
         ready_i : IN  std_logic;
         valid_o : OUT  std_logic;
         cmd_loadop3_o : OUT  std_logic;
         cmd_signed_o : OUT  std_logic;
         cmd_dbus_o : OUT  std_logic;
         cmd_dbus_store_o : OUT  std_logic;
         cmd_dbus_byte_o : OUT  std_logic;
         cmd_addsub_o : OUT  std_logic;
         cmd_mul_o : OUT  std_logic;
         cmd_div_o : OUT  std_logic;
         cmd_div_mod_o : OUT  std_logic;
         cmd_cmp_o : OUT  std_logic;
         cmd_jump_o : OUT  std_logic;
         cmd_negate_op2_o : OUT  std_logic;
         cmd_and_o : OUT  std_logic;
         cmd_xor_o : OUT  std_logic;
         cmd_shift_o : OUT  std_logic;
         cmd_shift_right_o : OUT  std_logic;
         jump_type_o : OUT  std_logic_vector(3 downto 0);
         op1_o : OUT  std_logic_vector(31 downto 0);
         op2_o : OUT  std_logic_vector(31 downto 0);
         op3_o : OUT  std_logic_vector(31 downto 0);
         dst_o : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal word_i : std_logic_vector(31 downto 0) := (others => '0');
   signal next_ip_i : std_logic_vector(29 downto 0) := (others => '0');
   signal valid_i : std_logic := '0';
   signal jump_valid_i : std_logic := '0';
   signal interrupt_valid_i : std_logic := '0';
   signal interrupt_vector_i : std_logic_vector(2 downto 0) := (others => '0');
   signal sp_rdata1_i : std_logic_vector(31 downto 0) := (others => '0');
   signal sp_rdata2_i : std_logic_vector(31 downto 0) := (others => '0');
   signal ready_i : std_logic := '0';

 	--Outputs
   signal ready_o : std_logic;
   signal interrupt_ready_o : std_logic;
   signal sp_raddr1_o : std_logic_vector(7 downto 0);
   signal sp_raddr2_o : std_logic_vector(7 downto 0);
   signal valid_o : std_logic;
   signal cmd_loadop3_o : std_logic;
   signal cmd_signed_o : std_logic;
   signal cmd_dbus_o : std_logic;
   signal cmd_dbus_store_o : std_logic;
   signal cmd_dbus_byte_o : std_logic;
   signal cmd_addsub_o : std_logic;
   signal cmd_mul_o : std_logic;
   signal cmd_div_o : std_logic;
   signal cmd_div_mod_o : std_logic;
   signal cmd_cmp_o : std_logic;
   signal cmd_jump_o : std_logic;
   signal cmd_negate_op2_o : std_logic;
   signal cmd_and_o : std_logic;
   signal cmd_xor_o : std_logic;
   signal cmd_shift_o : std_logic;
   signal cmd_shift_right_o : std_logic;
   signal jump_type_o : std_logic_vector(3 downto 0);
   signal op1_o : std_logic_vector(31 downto 0);
   signal op2_o : std_logic_vector(31 downto 0);
   signal op3_o : std_logic_vector(31 downto 0);
   signal dst_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: riscv_decode PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          word_i => word_i,
          next_ip_i => next_ip_i,
          valid_i => valid_i,
          jump_valid_i => jump_valid_i,
          ready_o => ready_o,
          interrupt_valid_i => interrupt_valid_i,
          interrupt_vector_i => interrupt_vector_i,
          interrupt_ready_o => interrupt_ready_o,
          sp_raddr1_o => sp_raddr1_o,
          sp_rdata1_i => sp_rdata1_i,
          sp_raddr2_o => sp_raddr2_o,
          sp_rdata2_i => sp_rdata2_i,
          ready_i => ready_i,
          valid_o => valid_o,
          cmd_loadop3_o => cmd_loadop3_o,
          cmd_signed_o => cmd_signed_o,
          cmd_dbus_o => cmd_dbus_o,
          cmd_dbus_store_o => cmd_dbus_store_o,
          cmd_dbus_byte_o => cmd_dbus_byte_o,
          cmd_addsub_o => cmd_addsub_o,
          cmd_mul_o => cmd_mul_o,
          cmd_div_o => cmd_div_o,
          cmd_div_mod_o => cmd_div_mod_o,
          cmd_cmp_o => cmd_cmp_o,
          cmd_jump_o => cmd_jump_o,
          cmd_negate_op2_o => cmd_negate_op2_o,
          cmd_and_o => cmd_and_o,
          cmd_xor_o => cmd_xor_o,
          cmd_shift_o => cmd_shift_o,
          cmd_shift_right_o => cmd_shift_right_o,
          jump_type_o => jump_type_o,
          op1_o => op1_o,
          op2_o => op2_o,
          op3_o => op3_o,
          dst_o => dst_o
        );
		  
		  
   Inst_lxp32_scratchpad: entity work.lxp32_scratchpad PORT MAP(
		clk_i => clk_i,
		raddr1_i => sp_raddr1_o,
		rdata1_o => sp_rdata1_i,
		raddr2_i => sp_raddr2_o,
		rdata2_o => sp_rdata2_i,
		waddr_i =>"00000000" ,
		we_i => '0',
		wdata_i => X"00000000"
	);		  

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_i_period;
		
		word_i <= X"001" & "00000" & ADDI &"00001" & OP_IMM; -- ADDI r1,r0,1 
		
		wait for clk_i_period;
		
		word_i <= X"008" & "00001" & ORI &"00001" & OP_IMM; -- ORI r1,r1,8 
		
		wait for clk_i_period;

      -- insert stimulus here 

      wait;
   end process;

END;
