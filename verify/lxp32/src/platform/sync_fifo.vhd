---------------------------------------------------------------------
-- Synchronous FIFO
--
-- Copyright (c) 2015 by Alex I. Kuznetsov
--
-- Portable description of a synchronous FIFO block.
--
-- Parameters:
--     * DATA_WIDTH: data port width
--     * ADDR_WIDTH: internal address port width
--     * SIZE:       FIFO size, must be <= 2^ADDR_WIDTH
--     * FWFT:       true: first word fall-through mode
--                     (output is produced without waiting for re_i)
--                   false: normal mode
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_fifo is
	generic(
		DATA_WIDTH: integer;
		ADDR_WIDTH: integer;
		SIZE: integer;
		FWFT: boolean
	);
	port(
		clk_i: in std_logic;
		clr_i: in std_logic;
		rst_i: in std_logic;
		
		we_i: in std_logic;
		d_i: in std_logic_vector(DATA_WIDTH-1 downto 0);
		re_i: in std_logic;
		d_o: out std_logic_vector(DATA_WIDTH-1 downto 0);
		
		empty_o: out std_logic;
		full_o: out std_logic;
		count_o: out std_logic_vector(ADDR_WIDTH downto 0)
	);
end entity;

architecture rtl of sync_fifo is

signal raddr: unsigned(ADDR_WIDTH-1 downto 0):=(others=>'0');
signal count: unsigned(ADDR_WIDTH downto 0):=(others=>'0');
signal waddr: unsigned(ADDR_WIDTH-1 downto 0);
signal full: std_logic:='0';
signal empty: std_logic:='1';

signal we: std_logic;
signal re: std_logic;

signal raddr_next: unsigned(raddr'range);
signal count_next: unsigned(count'range);

signal ram_waddr: std_logic_vector(ADDR_WIDTH-1 downto 0);
signal ram_raddr: std_logic_vector(ADDR_WIDTH-1 downto 0);
signal ram_rdata: std_logic_vector(d_o'range);

begin

we<=we_i and not full;
re<=re_i and not empty;

raddr_next<=raddr+1 when re='1' else raddr;
count_next<=count+1 when (we='1' and re='0') else count-1 when (we='0' and re='1') else count;

process (clk_i,clr_i) is
begin
	if clr_i='1' then
		raddr<=(others=>'0');
		count<=(others=>'0');
		full<='0';
		empty<='1';
	elsif rising_edge(clk_i) then
		if rst_i='1' then
			raddr<=(others=>'0');
			count<=(others=>'0');
			count_o<=(others=>'0');
			full<='0';
			empty<='1';
		else
			raddr<=raddr_next;
			count<=count_next;
-- To improve performance, in certain cases "empty_o" is asserted
-- even though data are actually in RAM. "count_o" must also reflect that.
			count_o<=std_logic_vector(count_next);
			if count=to_unsigned(0,count'length) or (count=to_unsigned(1,count'length) and re='1') then
				empty<='1';
				count_o<=(others=>'0');
			else
				empty<='0';
			end if;
			if SIZE=2**ADDR_WIDTH then
				full<=count_next(count_next'high);
			else
				if count_next=to_unsigned(SIZE,count_next'length) then
					full<='1';
				else
					full<='0';
				end if;
			end if;
		end if;
	end if;
end process;

waddr<=raddr+count(waddr'range);

ram_waddr<=std_logic_vector(waddr);
ram_raddr<=std_logic_vector(raddr_next);

ram_inst: entity work.generic_dpram(rtl)
	generic map(
		DATA_WIDTH=>DATA_WIDTH,
		ADDR_WIDTH=>ADDR_WIDTH,
		SIZE=>2**ADDR_WIDTH,
		MODE=>"DONTCARE"
	)
	port map(
		clka_i=>clk_i,
		cea_i=>'1',
		wea_i=>we,
		addra_i=>ram_waddr,
		da_i=>d_i,
		da_o=>open,
		
		clkb_i=>clk_i,
		ceb_i=>'1',
		addrb_i=>ram_raddr,
		db_o=>ram_rdata
	);

fwft_gen: if FWFT generate
	d_o<=ram_rdata;
end generate;

not_fwft_gen: if not FWFT generate
	process (clk_i) is
	begin
		if rising_edge(clk_i) then
			if re='1' then
				d_o<=ram_rdata;
			end if;
		end if;
	end process;
end generate;

full_o<=full;
empty_o<=empty;

end architecture;
