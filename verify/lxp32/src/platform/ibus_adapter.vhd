---------------------------------------------------------------------
-- IBUS adapter
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Converts the Low Latency Interface to WISHBONE registered
-- feedback protocol.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ibus_adapter is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		ibus_cyc_i: in std_logic;
		ibus_stb_i: in std_logic;
		ibus_cti_i: in std_logic_vector(2 downto 0);
		ibus_bte_i: in std_logic_vector(1 downto 0);
		ibus_ack_o: out std_logic;
		ibus_adr_i: in std_logic_vector(29 downto 0);
		ibus_dat_o: out std_logic_vector(31 downto 0);
		
		lli_re_o: out std_logic;
		lli_adr_o: out std_logic_vector(29 downto 0);
		lli_dat_i: in std_logic_vector(31 downto 0);
		lli_busy_i: in std_logic
	);
end entity;

architecture rtl of ibus_adapter is

constant burst_delay: integer:=5;
signal burst_delay_cnt: integer:=0;
signal delay_burst: std_logic;

signal re: std_logic;
signal requested: std_logic:='0';
signal adr: unsigned(29 downto 0);
signal ack: std_logic;

begin

-- Insert burst delay

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			burst_delay_cnt<=0;
		elsif ibus_cyc_i='0' then
			burst_delay_cnt<=burst_delay;
		elsif burst_delay_cnt/=0 then
			burst_delay_cnt<=burst_delay_cnt-1;
		end if;
	end if;
end process;

delay_burst<='1' when burst_delay_cnt/=0 else '0';

-- Generate ACK signal

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			requested<='0';
		elsif lli_busy_i='0' then
			requested<=re;
		end if;
	end if;
end process;

ack<=requested and not lli_busy_i;

-- Generate LLI signals

re<=(ibus_cyc_i and ibus_stb_i and not delay_burst) when ack='0' or
	(ibus_cti_i="010" and ibus_bte_i="00") else '0';

adr<=unsigned(ibus_adr_i) when re='1' and ack='0' else
	unsigned(ibus_adr_i)+1 when re='1' and ack='1' else
	(others=>'-');

lli_re_o<=re;
lli_adr_o<=std_logic_vector(adr);

-- Generate IBUS signals

ibus_ack_o<=ack;
ibus_dat_o<=lli_dat_i when ack='1' else (others=>'-');

end architecture;
