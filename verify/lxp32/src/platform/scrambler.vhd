---------------------------------------------------------------------
-- Scrambler
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Generates a pseudo-random binary sequence using a Linear-Feedback
-- Shift Register (LFSR).
--
-- In order to generate a maximum-length sequence, 1+x^TAP1+x^TAP2
-- must be a primitive polynomial. Typical polynomials include:
-- (6,7), (9,11), (14,15).
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity scrambler is
	generic(
		TAP1: integer;
		TAP2: integer
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		ce_i: in std_logic;
		d_o: out std_logic
	);
end entity;

architecture rtl of scrambler is

signal reg: std_logic_vector(TAP2 downto 1):=(others=>'1');

begin

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			reg<=(others=>'1');
		elsif ce_i='1' then
			reg<=reg(TAP2-1 downto 1)&(reg(TAP2) xor reg(TAP1));
		end if;
	end if;
end process;

d_o<=reg(1);

end architecture;
