---------------------------------------------------------------------
-- Common package for LXP32 testbenches
--
-- Part of the LXP32 verification environment
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Note: the "rand" function declared in this package implements
-- a linear congruent pseudo-random number generator as defined in
-- the ISO/IEC 9899:1999 standard.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common_pkg is
	shared variable rand_state: unsigned(31 downto 0):=to_unsigned(1,32);
	
	impure function rand return integer;
	impure function rand(a: integer; b: integer) return integer;
	
	function hex_string(x: std_logic_vector) return string;
end package;
