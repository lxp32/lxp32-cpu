---------------------------------------------------------------------
-- Common package for LXP32 testbenches
--
-- Part of the LXP32 verification environment
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common_pkg is
	type rng_state_type is record
		seed1: positive;
		seed2: positive;
	end record;

	-- Generate a pseudo-random value of integer type from [a;b] range
	-- Output is stored in x
	procedure rand(variable st: inout rng_state_type; a,b: integer; variable x: out integer);
	
	-- Convert std_logic_vector to a hexadecimal string (similar to
	-- the "to_hstring" function from VHDL-2008
	function hex_string(x: std_logic_vector) return string;
end package;
