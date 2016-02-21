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
use ieee.math_real.all;

package body common_pkg is
	procedure rand(variable st: inout rng_state_type; a,b: integer; variable x: out integer) is
		variable r: real;
	begin
		assert a<=b report "Invalid range" severity failure;
		uniform(st.seed1,st.seed2,r);
		r:=r*real(b-a+1);
		x:=a+integer(floor(r));
	end procedure;
	
	function hex_string(x: std_logic_vector) return string is
		variable xx: std_logic_vector(x'length-1 downto 0);
		variable i: integer:=0;
		variable ii: integer;
		variable c: integer;
		variable s: string(x'length downto 1);
	begin
		xx:=x;
		loop
			ii:=i*4;
			exit when ii>xx'high;
			if ii+3<=xx'high then
				c:=to_integer(unsigned(xx(ii+3 downto ii)));
			else
				c:=to_integer(unsigned(xx(xx'high downto ii)));
			end if;
			
			case c is
			when 0 => s(i+1):='0';
			when 1 => s(i+1):='1';
			when 2 => s(i+1):='2';
			when 3 => s(i+1):='3';
			when 4 => s(i+1):='4';
			when 5 => s(i+1):='5';
			when 6 => s(i+1):='6';
			when 7 => s(i+1):='7';
			when 8 => s(i+1):='8';
			when 9 => s(i+1):='9';
			when 10 => s(i+1):='A';
			when 11 => s(i+1):='B';
			when 12 => s(i+1):='C';
			when 13 => s(i+1):='D';
			when 14 => s(i+1):='E';
			when 15 => s(i+1):='F';
			when others => s(i+1):='X';
			end case;
			
			i:=i+1;
		end loop;
		return s(i downto 1);
	end function;
end package body;
