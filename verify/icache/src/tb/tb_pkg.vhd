---------------------------------------------------------------------
-- LXP32 instruction cache testbench package
--
-- Part of the LXP32 instruction cache testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Auxiliary package declaration for the LXP32 instruction cache
-- testbench.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package tb_pkg is
	constant xor_constant: std_logic_vector(31 downto 0):=X"12345678";
end package;
