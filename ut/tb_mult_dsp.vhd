--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:51:42 10/01/2016
-- Design Name:   
-- Module Name:   /home/thomas/riscv/lxp32-cpu/ut/tb_mult_dsp.vhd
-- Project Name:  lxp32riscv
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lxp32_mul_dsp
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
USE ieee.numeric_std.ALL;
 
ENTITY tb_mult_dsp IS
END tb_mult_dsp;
 
ARCHITECTURE behavior OF tb_mult_dsp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lxp32_mul_dsp
    PORT(
         clk_i : IN  std_logic;
         rst_i : IN  std_logic;
         ce_i : IN  std_logic;
         op1_i : IN  std_logic_vector(31 downto 0);
         op2_i : IN  std_logic_vector(31 downto 0);
         ce_o : OUT  std_logic;
         result_o : OUT  std_logic_vector(31 downto 0);
         result_high_o : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
	 
	 
   --Inputs
   signal clk_i : std_logic := '0';
   signal rst_i : std_logic := '0';
   signal ce_i : std_logic := '0';
   signal op1_i : std_logic_vector(31 downto 0) := (others => '0');
   signal op2_i : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal ce_o : std_logic;
   signal result_o : std_logic_vector(31 downto 0);
   signal result_high_o : std_logic_vector(31 downto 0);
	
	signal result_u : unsigned(63 downto 0);
	signal result_s : signed(63 downto 0);
	

   -- Clock period definitions
   constant clk_i_period : time := 10 ns;
	
	subtype dword is std_logic_vector(31 downto 0);
	
	function l32(v: integer) return dword is
	begin
	  return std_logic_vector(to_signed(v,32));
	end;
	
 
BEGIN
 
   result_u <= unsigned(result_high_o & result_o);
	result_s <= signed(result_high_o & result_o);
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lxp32_mul_dsp PORT MAP (
          clk_i => clk_i,
          rst_i => rst_i,
          ce_i => ce_i,
          op1_i => op1_i,
          op2_i => op2_i,
          ce_o => ce_o,
          result_o => result_o,
          result_high_o => result_high_o
        );
		  

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 
--   process(clk_i)
--	begin
--	  if rising_edge(clk_i) then
--	    if ce_o='1' then
--		   ce_i<='0';
--		 end if;	
--	  
--	  end if;
--	end process;
	

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
    

      wait for clk_i_period*3;
		
		op1_i<= l32(5); 
		op2_i<= l32(-1);
		ce_i<='1';
		wait for clk_i_period;
		ce_i<='0';
		wait for clk_i_period*2;

      op1_i<= X"00000005";
		op2_i<= X"00000005";
		ce_i<='1';
		wait for clk_i_period;
		ce_i<='0';
		wait for clk_i_period*2;
		
		op1_i<= X"00001388"; -- dec. 5000
		op2_i<= X"00001388";
		ce_i<='1';
		wait for clk_i_period;
		ce_i<='0';
		wait for clk_i_period*2;
		
		op1_i<= l32(5000000);
		op2_i<= l32(5000000);
		ce_i<='1';
		wait for clk_i_period;
		ce_i<='0';
		wait for clk_i_period*2;
		
		
		op1_i<= l32(5000000);
		op2_i<= l32(-3);
		ce_i<='1';
		wait for clk_i_period;
		ce_i<='0';
		wait for clk_i_period*2;
		
		 

      wait;
   end process;

END;
