---------------------------------------------------------------------
-- Microbuffer
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- A small buffer with a FIFO-like interface, implemented
-- using registers.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lxp32_ubuf is
	generic(
		DATA_WIDTH: integer
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		we_i: in std_logic;
		d_i: in std_logic_vector(DATA_WIDTH-1 downto 0);
		re_i: in std_logic;
		d_o: out std_logic_vector(DATA_WIDTH-1 downto 0);
		
		empty_o: out std_logic;
		full_o: out std_logic
	);
end entity;

architecture rtl of lxp32_ubuf is

signal we: std_logic;
signal re: std_logic;

signal empty: std_logic:='1';
signal full: std_logic:='0';

type regs_type is array (1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal regs: regs_type;
signal regs_mux: regs_type;

signal wpointer: std_logic_vector(2 downto 0):="001";

begin

we<=we_i and not full;
re<=re_i and not empty;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			wpointer<="001";
			empty<='1';
			full<='0';
		else
			if re='0' then
				regs<=regs_mux;
			else
				regs(0)<=regs_mux(1);
			end if;
			
			if we='1' and re='0' then
				wpointer<=wpointer(1 downto 0)&"0";
				empty<='0';
				full<=wpointer(1);
			elsif we='0' and re='1' then
				wpointer<="0"&wpointer(2 downto 1);
				empty<=wpointer(1);
				full<='0';
			end if;
		end if;
	end if;
end process;

mux: for i in regs_mux'range generate
	regs_mux(i)<=regs(i) when we='0' or wpointer(i)='0' else d_i;
end generate;

d_o<=regs(0);
empty_o<=empty;
full_o<=full;

end architecture;
