---------------------------------------------------------------------
-- LXP32 instruction cache verification environment (self-checking
-- testbench)
--
-- Part of the LXP32 instruction cache testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Parameters:
--     CACHE_BURST_SIZE:     burst size for cache unit
--     CACHE_PREFETCH_SIZE:  prefetch distance for cache unit
--     CPU_BLOCKS:           number of data blocks to fetch
--     VERBOSE:              print more messages
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb is
	generic(
		CACHE_BURST_SIZE: integer:=16;
		CACHE_PREFETCH_SIZE: integer:=32;
		CPU_BLOCKS: integer:=100000;
		VERBOSE: boolean:=false
	);
end entity;

architecture testbench of tb is

signal clk: std_logic:='0';
signal rst: std_logic:='0';

signal lli_re: std_logic;
signal lli_adr: std_logic_vector(29 downto 0);
signal lli_dat: std_logic_vector(31 downto 0);
signal lli_busy: std_logic;

signal wbm_cyc: std_logic;
signal wbm_stb: std_logic;
signal wbm_cti: std_logic_vector(2 downto 0);
signal wbm_bte: std_logic_vector(1 downto 0);
signal wbm_ack: std_logic;
signal wbm_adr: std_logic_vector(29 downto 0);
signal wbm_dat: std_logic_vector(31 downto 0);

signal finish: std_logic:='0';

begin

clk<=not clk and not finish after 5 ns;

dut: entity work.lxp32_icache(rtl)
	generic map(
		BURST_SIZE=>CACHE_BURST_SIZE,
		PREFETCH_SIZE=>CACHE_PREFETCH_SIZE
	)
	port map(
		clk_i=>clk,
		rst_i=>rst,
		
		lli_re_i=>lli_re,
		lli_adr_i=>lli_adr,
		lli_dat_o=>lli_dat,
		lli_busy_o=>lli_busy,
		
		wbm_cyc_o=>wbm_cyc,
		wbm_stb_o=>wbm_stb,
		wbm_cti_o=>wbm_cti,
		wbm_bte_o=>wbm_bte,
		wbm_ack_i=>wbm_ack,
		wbm_adr_o=>wbm_adr,
		wbm_dat_i=>wbm_dat
	);

ram_model_inst: entity work.ram_model(sim)
	port map(
		clk_i=>clk,
		
		wbm_cyc_i=>wbm_cyc,
		wbm_stb_i=>wbm_stb,
		wbm_cti_i=>wbm_cti,
		wbm_bte_i=>wbm_bte,
		wbm_ack_o=>wbm_ack,
		wbm_adr_i=>wbm_adr,
		wbm_dat_o=>wbm_dat
	);

cpu_model_inst: entity work.cpu_model(sim)
	generic map(
		BLOCKS=>CPU_BLOCKS,
		VERBOSE=>VERBOSE
	)
	port map(
		clk_i=>clk,
		
		lli_re_o=>lli_re,
		lli_adr_o=>lli_adr,
		lli_dat_i=>lli_dat,
		lli_busy_i=>lli_busy,
		
		finish_o=>finish
	);

end architecture;
