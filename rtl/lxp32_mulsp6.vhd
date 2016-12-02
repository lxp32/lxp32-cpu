----------------------------------------------------------------------------------

-- Engineer: Thomas Hornschuh
-- 
-- Create Date:    19:31:22 12/01/2016 
-- Design Name: 
-- Module Name:    lxp32_mulsp6 - Behavioral 
-- Project Name: 
-- Target Devices: Spartan 6

-- Description: 
-- Pipelined multiplier
-- Code dervied from Xilinx Documentation
-- The code pattern below will make XST to infer a pipelined multiplier with a latency of 4 cycles
-- out of 4 DSP48 blocks and some additional logic  
-- The multiplication operation placed outside the
-- process block and the pipeline stages represented
-- as single registers
-- Code for infering 

--
-- Dependencies: 
--
-- Revision: 
-- Revision 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lxp32_mulsp6 is

	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		ce_i: in std_logic;
		op1_i: in std_logic_vector(31 downto 0);
		op2_i: in std_logic_vector(31 downto 0);
--		op1_signed_i : in std_logic;
--		op2_signed_i : in std_logic;
		
		ce_o: out std_logic;
		result_o: out std_logic_vector(31 downto 0);
		result_high_o : out std_logic_vector(31 downto 0)
	);

end entity;

architecture rtl of lxp32_mulsp6 is

constant  A_port_size : natural  := 32;
constant  B_port_size : natural  := 32;

signal a_in, b_in : unsigned (A_port_size-1 downto 0);
signal mult_res : unsigned ( (A_port_size+B_port_size-1) downto 0);
signal pipe_1, pipe_2, pipe_3,MULT : unsigned ((A_port_size+B_port_size-1) downto 0);

signal ce_1 : std_logic :='0';
signal ce_2 : std_logic :='0';
signal ce_3 : std_logic :='0';
signal ce_4 : std_logic :='0';



begin
   mult_res <= a_in * b_in;

   result_o <= std_logic_vector(MULT(31 downto 0));
   result_high_o <= std_logic_vector(MULT(63 downto 32));

process (clk_i) begin

   if rising_edge(clk_i) then
        if rst_i='1' then
          ce_1 <= '0';
          ce_2 <= '0';
          ce_3 <= '0';
          ce_4 <= '0';
          ce_o <= '0';
        else
      
          -- input pipeline stage
          a_in <= unsigned(op1_i); 
          b_in <= unsigned(op2_i);
          ce_1 <= ce_i;
         
          -- internal pipeline stages
          pipe_1 <= mult_res; ce_2 <= ce_1;
          pipe_2 <= pipe_1;   ce_3 <= ce_2;
          pipe_3 <= pipe_2;   ce_4 <= ce_3;
          MULT <= pipe_3;     ce_o <= ce_4;
        end if;  
    end if;
end process;



end rtl;

