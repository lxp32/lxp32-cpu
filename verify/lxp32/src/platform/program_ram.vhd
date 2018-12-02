---------------------------------------------------------------------
-- Program RAM
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Program RAM for the LXP32 test platform. Has two interfaces:
-- WISHBONE (for data access) and LLI (for LXP32 instruction bus).
-- Optionally performs throttling.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity program_ram is
	generic(
		THROTTLE: boolean
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
		
		lli_re_i: in std_logic;
		lli_adr_i: in std_logic_vector(29 downto 0);
		lli_dat_o: out std_logic_vector(31 downto 0);
		lli_busy_o: out std_logic
	);
end entity;

architecture rtl of program_ram is

signal ram_a_we: std_logic_vector(3 downto 0);
signal ram_a_rdata: std_logic_vector(31 downto 0);

signal ram_b_re: std_logic;
signal ram_b_rdata: std_logic_vector(31 downto 0);

signal ack_write: std_logic;
signal ack_read: std_logic;

signal prbs: std_logic;
signal lli_busy: std_logic:='0';

begin

-- The total memory size is 16384 words, i.e. 64K bytes

gen_dprams: for i in 3 downto 0 generate
	generic_dpram_inst: entity work.generic_dpram(rtl)
		generic map(
			DATA_WIDTH=>8,
			ADDR_WIDTH=>14,
			SIZE=>16384,
			MODE=>"DONTCARE"
		)
		port map(
			clka_i=>clk_i,
			cea_i=>'1',
			wea_i=>ram_a_we(i),
			addra_i=>wbs_adr_i(15 downto 2),
			da_i=>wbs_dat_i(i*8+7 downto i*8),
			da_o=>ram_a_rdata(i*8+7 downto i*8),
			
			clkb_i=>clk_i,
			ceb_i=>ram_b_re,
			addrb_i=>lli_adr_i(13 downto 0),
			db_o=>ram_b_rdata(i*8+7 downto i*8)
		);
end generate;

-- WISHBONE interface

gen_ram_a_we: for i in 3 downto 0 generate
	ram_a_we(i)<='1' when wbs_cyc_i='1' and wbs_stb_i='1' and wbs_we_i='1'
		and wbs_sel_i(i)='1' and wbs_adr_i(27 downto 16)="000000000000" else '0';
end generate;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		ack_read<=wbs_cyc_i and wbs_stb_i and not wbs_we_i and not ack_read;
	end if;
end process;

ack_write<=wbs_cyc_i and wbs_stb_i and wbs_we_i;

wbs_ack_o<=ack_read or ack_write;
wbs_dat_o<=ram_a_rdata;

-- Low Latency Interface (with optional pseudo-random throttling)

process (clk_i) is
begin
	if rising_edge(clk_i) then
		assert lli_re_i='0' or lli_adr_i(lli_adr_i'high downto 14)=X"0000"
			report "Attempted to fetch instruction from a non-existent address 0x"&
				hex_string(lli_adr_i&"00")
			severity failure;
	end if;
end process;

gen_throttling: if THROTTLE generate
	throttle_inst: entity work.scrambler(rtl)
		generic map(TAP1=>9,TAP2=>11)
		port map(clk_i=>clk_i,rst_i=>rst_i,ce_i=>'1',d_o=>prbs);
end generate;

gen_no_throttling: if not THROTTLE generate
	prbs<='0';
end generate;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			lli_busy<='0';
		elsif prbs='1' and lli_re_i='1' then
			lli_busy<='1';
		elsif prbs='0' then
			lli_busy<='0';
		end if;
	end if;
end process;

ram_b_re<=lli_re_i and not lli_busy;

lli_busy_o<=lli_busy;
lli_dat_o<=ram_b_rdata when lli_busy='0' else (others=>'-');

end architecture;
