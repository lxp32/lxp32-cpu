---------------------------------------------------------------------
-- Test monitor
--
-- Part of the LXP32 testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Provide means for a test platform to interact with the testbench.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;
use work.tb_pkg.all;

entity monitor is
	generic(
		VERBOSE: boolean
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		wbs_cyc_i: in std_logic;
		wbs_stb_i: in std_logic;
		wbs_we_i: in std_logic;
		wbs_sel_i: in std_logic_vector(3 downto 0);
		wbs_ack_o: out std_logic;
		wbs_adr_i: in std_logic_vector(27 downto 2);
		wbs_dat_i: in std_logic_vector(31 downto 0);
		wbs_dat_o: out std_logic_vector(31 downto 0);
		
		finished_o: out std_logic;
		result_o: out std_logic_vector(31 downto 0)
	);
end entity;

architecture sim of monitor is

signal result: std_logic_vector(31 downto 0):=(others=>'0');
signal finished: std_logic:='0';

begin

wbs_ack_o<=wbs_cyc_i and wbs_stb_i;
wbs_dat_o<=(others=>'0');

finished_o<=finished;
result_o<=result;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			finished<='0';
			result<=(others=>'0');
		elsif wbs_cyc_i='1' and wbs_stb_i='1' and wbs_we_i='1' then
			assert wbs_sel_i="1111"
				report "Monitor doesn't support byte-granular access "&
					"(SEL_I() is 0x"&hex_string(wbs_sel_i)&")"
				severity failure;
			
			if VERBOSE then
				report "Monitor: value "&
					"0x"&hex_string(wbs_dat_i)&
					" written to address "&
					"0x"&hex_string(wbs_adr_i);
			end if;
			
			if unsigned(wbs_adr_i)=to_unsigned(0,wbs_adr_i'length) then
				result<=wbs_dat_i;
				finished<='1';
			end if;
		end if;
	end if;
end process;

end architecture;
