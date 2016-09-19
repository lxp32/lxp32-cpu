----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:22:09 09/18/2016 
-- Design Name: 
-- Module Name:    ut_decode_util - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.riscv_decodeutil.all;


entity ut_decode_util is
    Port ( instr_i : in  STD_LOGIC_VECTOR (XLEN-1 downto 0);
           immediate_o : out  STD_LOGIC_VECTOR (XLEN-1 downto 0));
end ut_decode_util;

architecture Behavioral of ut_decode_util is


begin
  immediate_o <= std_logic_vector(get_I_immediate(instr_i));

end Behavioral;

