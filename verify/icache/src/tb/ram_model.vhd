---------------------------------------------------------------------
-- RAM model
--
-- Part of the LXP32 instruction cache testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Simulates RAM controller which provides WISHBONE registered
-- feedback interface.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;
use work.tb_pkg.all;

entity ram_model is
	port(
		clk_i: in std_logic;
		
		wbm_cyc_i: in std_logic;
		wbm_stb_i: in std_logic;
		wbm_cti_i: in std_logic_vector(2 downto 0);
		wbm_bte_i: in std_logic_vector(1 downto 0);
		wbm_ack_o: out std_logic;
		wbm_adr_i: in std_logic_vector(29 downto 0);
		wbm_dat_o: out std_logic_vector(31 downto 0)
	);
end entity;

architecture sim of ram_model is

signal ack: std_logic:='0';
signal cycle: std_logic:='0';

begin

wbm_ack_o<=ack;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if wbm_cyc_i='1' and wbm_stb_i='1' and wbm_cti_i="010" and wbm_bte_i="00" then
			cycle<='1';
		elsif wbm_cyc_i='0' or (wbm_cyc_i='1' and wbm_stb_i='1' and (wbm_cti_i/="010" or wbm_bte_i/="00")) then
			cycle<='0';
		end if;
	end if;
end process;

process is
	variable rng_state: rng_state_type;
	variable delay: integer;
begin
	wait until rising_edge(clk_i) and wbm_cyc_i='1' and wbm_stb_i='1';
	ack<='0';
	
-- Random delay before the first beat
	if cycle='0' then
		rand(rng_state,0,3,delay);
		if delay>0 then
			for i in 1 to delay loop
				wait until rising_edge(clk_i) and wbm_cyc_i='1' and wbm_stb_i='1';
			end loop;
		end if;
	end if;
	
	if ack='0' then
		wbm_dat_o<=("00"&wbm_adr_i) xor xor_constant;
		ack<='1';
	elsif wbm_cti_i="010" and wbm_bte_i="00" then
		wbm_dat_o<=("00"&std_logic_vector(unsigned(wbm_adr_i)+1)) xor xor_constant;
		ack<='1';
	end if;
end process;

end architecture;
