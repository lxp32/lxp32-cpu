---------------------------------------------------------------------
-- DBUS monitor
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Monitors LXP32 data bus transactions, optionally throttles them.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dbus_monitor is
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
		wbs_adr_i: in std_logic_vector(31 downto 2);
		wbs_dat_i: in std_logic_vector(31 downto 0);
		wbs_dat_o: out std_logic_vector(31 downto 0);
		
		wbm_cyc_o: out std_logic;
		wbm_stb_o: out std_logic;
		wbm_we_o: out std_logic;
		wbm_sel_o: out std_logic_vector(3 downto 0);
		wbm_ack_i: in std_logic;
		wbm_adr_o: out std_logic_vector(31 downto 2);
		wbm_dat_o: out std_logic_vector(31 downto 0);
		wbm_dat_i: in std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of dbus_monitor is

signal prbs: std_logic;
signal cycle: std_logic:='0';

signal cyc_ff: std_logic:='0';
signal ack_ff: std_logic:='0';

begin

-- Manage throttling

gen_throttling: if THROTTLE generate
	throttle_inst: entity work.scrambler(rtl)
		generic map(TAP1=>6,TAP2=>7)
		port map(clk_i=>clk_i,rst_i=>rst_i,ce_i=>'1',d_o=>prbs);
end generate;

gen_no_throttling: if not THROTTLE generate
	prbs<='0';
end generate;

-- CPU interface

wbs_ack_o<=wbm_ack_i;
wbs_dat_o<=wbm_dat_i when wbm_ack_i='1' else (others=>'-');

-- Interconnect interface

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			cycle<='0';
		elsif prbs='0' and wbs_cyc_i='1' then
			cycle<='1';
		elsif wbs_cyc_i='0' then
			cycle<='0';
		end if;
	end if;
end process;

wbm_cyc_o<=wbs_cyc_i and (not prbs or cycle);
wbm_stb_o<=wbs_stb_i and (not prbs or cycle);
wbm_we_o<=wbs_we_i;
wbm_sel_o<=wbs_sel_i;
wbm_adr_o<=wbs_adr_i;
wbm_dat_o<=wbs_dat_i;

-- Check handshake correctness

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			cyc_ff<='0';
			ack_ff<='0';
		else
			cyc_ff<=wbs_cyc_i;
			ack_ff<=wbm_ack_i;
			
			assert wbm_ack_i='0' or (wbs_cyc_i and (not prbs or cycle))='1'
				report "DBUS error: ACK asserted without CYC"
				severity failure;
			
			assert not (wbs_cyc_i='0' and cyc_ff='1' and ack_ff/='1')
				report "DBUS error: cycle terminated prematurely"
				severity failure;
		end if;
	end if;
end process;

end architecture;
