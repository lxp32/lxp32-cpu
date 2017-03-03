---------------------------------------------------------------------
-- Instruction fetch
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- The first stage of the LXP32 pipeline.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_fetch is
	generic(
		START_ADDR: std_logic_vector(29 downto 0);
      USE_RISCV : boolean := false
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		
		lli_re_o: out std_logic;
		lli_adr_o: out std_logic_vector(29 downto 0);
		lli_dat_i: in std_logic_vector(31 downto 0);
		lli_busy_i: in std_logic;
		
		word_o: out std_logic_vector(31 downto 0);
		next_ip_o: out std_logic_vector(29 downto 0);
		valid_o: out std_logic;
		ready_i: in std_logic;
		
		jump_valid_i: in std_logic;
		jump_dst_i: in std_logic_vector(29 downto 0);
		jump_ready_o: out std_logic
	);
end entity;

architecture rtl of lxp32_fetch is

signal init: std_logic:='1';
signal init_cnt: unsigned(7 downto 0):=(others=>'0');

signal fetch_addr: std_logic_vector(29 downto 0):=START_ADDR;

signal next_word: std_logic;
signal suppress_re: std_logic:='0';
signal re: std_logic;
signal requested: std_logic:='0';

signal fifo_rst: std_logic;
signal fifo_we: std_logic;
signal fifo_din: std_logic_vector(61 downto 0);
signal fifo_re: std_logic;
signal fifo_dout: std_logic_vector(61 downto 0);
signal fifo_empty: std_logic;
signal fifo_full: std_logic;

signal jr: std_logic:='0';

begin

-- INIT state machine (to initialize all registers)

-- All CPU registers are expected to be zero-initialized after reset.
-- Since these registers are implemented as a RAM block, we perform
-- the initialization sequentially by generating "mov rN, 0" instructions
-- for each N from 0 to 255.
--
-- With SRAM-based FPGAs, flip-flops and RAM blocks have deterministic
-- state after configuration. On these technologies the CPU can operate
-- without reset and the initialization procedure described above is not
-- needed. However, the initialization is still performed as usual when
-- external reset signal is asserted.

lpc_init: if not USE_RISCV generate

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			init<='0';
			init_cnt<=(others=>'0');
		else
			if init='0' and ready_i='1' then
				init_cnt<=init_cnt+1;
				if init_cnt=X"FF" then
					init<='1';
				end if;
			end if;
		end if;
	end if;
end process;

end generate;

-- FETCH state machine

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			fetch_addr<=START_ADDR;
			requested<='0';
			jr<='0';
			suppress_re<='0';
		else
			jr<='0';
-- Suppress LLI request if jump signal is active but will not be processed
-- in this cycle. Helps to reduce jump latency with high-latency LLI slaves.
-- Note: gating "re" with "jump_valid_i and not jr" asynchronously would
-- reduce jump latency even more, but we really want to avoid too large
-- clock-to-out on LLI outputs.
			suppress_re<=jump_valid_i and not jr and not next_word;
			if lli_busy_i='0' then
				requested<=re and not (jump_valid_i and not jr);
			end if;
			if next_word='1' then
				if jump_valid_i='1' and jr='0' then
					fetch_addr<=jump_dst_i;
					jr<='1';
				else
					fetch_addr<=std_logic_vector(unsigned(fetch_addr)+1);
				end if;
			end if;
		end if;
	end if;
end process;

next_word<=(fifo_empty or ready_i) and not lli_busy_i and init;
re<=(fifo_empty or ready_i) and init and not suppress_re;
lli_re_o<=re;
lli_adr_o<=fetch_addr;

jump_ready_o<=jr;

-- Small instruction buffer

fifo_rst<=rst_i or (jump_valid_i and not jr);
fifo_we<=requested and not lli_busy_i;
fifo_din<=fetch_addr&lli_dat_i;
fifo_re<=ready_i and not fifo_empty;

ubuf_inst: entity work.lxp32_ubuf(rtl)
	generic map(
		DATA_WIDTH=>62
	)
	port map(
		clk_i=>clk_i,
		rst_i=>fifo_rst,
		
		we_i=>fifo_we,
		d_i=>fifo_din,
		re_i=>fifo_re,
		d_o=>fifo_dout,
		
		empty_o=>fifo_empty,
		full_o=>fifo_full
	);

next_ip_o<=fifo_dout(61 downto 32);

word_o<=fifo_dout(31 downto 0) when init='1' else X"40"&std_logic_vector(init_cnt)&X"0000";
valid_o<=not fifo_empty or not init;

end architecture;
