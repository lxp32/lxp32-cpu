--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:45:15 09/18/2016
-- Design Name:   
-- Module Name:   C:/daten/development/fpga/lxp32proj/lxp32-cpu/ut/tb_ut_decode_util.vhd
-- Project Name:  lxp32_01
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ut_decode_util
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
 
ENTITY tb_ut_decode_util IS
END tb_ut_decode_util;
 
ARCHITECTURE behavior OF tb_ut_decode_util IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ut_decode_util
    PORT(
         instr_i : IN  std_logic_vector(31 downto 0);
         immediate_o : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal instr_i : std_logic_vector(31 downto 0) := "100000000011" & "00000000000000000000";

 	--Outputs
   signal immediate_o : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ut_decode_util PORT MAP (
          instr_i => instr_i,
          immediate_o => immediate_o
        );

   
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

   

      wait;
   end process;

END;
