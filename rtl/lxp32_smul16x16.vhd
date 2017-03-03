---------------------------------------------------------------------
-- Signed multiplier block - derived from unsigned multiplier
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Thomas Hornschuh
--
-- A straightforward behavioral description. Can be replaced
-- with a library component wrapper if needed.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_smul16x16 is
	port(
		clk_i: in std_logic;
		a_i: in std_logic_vector(15 downto 0);
		b_i: in std_logic_vector(15 downto 0);
		p_o: out std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of lxp32_smul16x16 is

begin

process (clk_i) is
variable p : signed(35 downto 0);
begin
	if rising_edge(clk_i) then
	   p:=resize(signed(a_i),18)*resize(signed(b_i),18);
		p_o<=std_logic_vector(p(31 downto 0));
	end if;
end process;

end architecture;


