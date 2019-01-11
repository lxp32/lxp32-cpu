---------------------------------------------------------------------
-- CPU model
--
-- Part of the LXP32 instruction cache testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Requests data from cache
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.common_pkg.all;
use work.tb_pkg.all;

entity cpu_model is
	generic(
		BLOCKS: integer;
		VERBOSE: boolean
	);
	port(
		clk_i: in std_logic;
		
		lli_re_o: out std_logic;
		lli_adr_o: out std_logic_vector(29 downto 0);
		lli_dat_i: in std_logic_vector(31 downto 0);
		lli_busy_i: in std_logic;
		
		finish_o: out std_logic
	);
end entity;

architecture sim of cpu_model is

constant bursts: integer:=10000;

signal re: std_logic:='0';
signal lli_adr: std_logic_vector(29 downto 0);

signal request: std_logic:='0';
signal request_addr: std_logic_vector(29 downto 0);

signal finish: std_logic:='0';

signal current_latency: integer:=1;
signal max_latency: integer:=-1;
signal total_latency: integer:=0;
signal spurious_misses: integer:=0;

begin

process is
	variable b: integer:=1;
	variable start: integer;
	variable size: integer;
	variable addr: integer:=0;
	variable delay: integer;
	variable rng_state: rng_state_type;
	variable r: integer;
	variable total_requests: integer:=0;
begin
	while b<=BLOCKS loop
		rand(rng_state,1,10,r);
		if r=1 then -- insert large block occasionally
			rand(rng_state,1,400,size);
		else -- small block
			rand(rng_state,1,32,size);
		end if;
		
		rand(rng_state,0,1,r);
		if r=0 then -- long jump
			rand(rng_state,0,1024,start);
			addr:=start;
			if VERBOSE then
				report "Fetching block #"&integer'image(b)&" at address "&integer'image(addr)&
					" of size "&integer'image(size);
			end if;
		else -- short jump
			rand(rng_state,-10,10,r);
			start:=addr+r;
			if start<0 then
				start:=0;
			end if;
			addr:=start;
			if VERBOSE then
				report "Fetching block #"&integer'image(b)&" at address "&integer'image(addr)&
					" of size "&integer'image(size)&" (short jump)";
			end if;
		end if;
		
		while addr<start+size loop
			re<='1';
			total_requests:=total_requests+1;
			lli_adr<=std_logic_vector(to_unsigned(addr,30));
			wait until rising_edge(clk_i) and lli_busy_i='0';
			re<='0';
			addr:=addr+1;
			rand(rng_state,0,4,delay);
			if delay>0 then
				for i in 1 to delay loop
					wait until rising_edge(clk_i);
				end loop;
			end if;
		end loop;
		
		if (b mod 10000)=0 then
			report integer'image(b)&" BLOCKS PROCESSED";
		end if;
		
		b:=b+1;
	end loop;
	
	report "Number of requests: "&integer'image(total_requests);
	report "Maximum latency: "&integer'image(max_latency);
	report "Average latency: "&real'image(real(total_latency)/real(total_requests));
	report "Number of spurious misses: "&integer'image(spurious_misses);
	
	finish<='1';
	wait;
end process;

lli_re_o<=re;
lli_adr_o<=lli_adr;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if lli_busy_i='0' then
			if request='1' then
				assert lli_dat_i=(("00"&request_addr) xor xor_constant)
					report "Data mismatch: expected 0x"&
						hex_string(("00"&request_addr) xor xor_constant)&
						", got 0x"&hex_string(lli_dat_i)
					severity failure;
			end if;
			
			request<=re;
			request_addr<=lli_adr;
		end if;
	end if;
end process;

finish_o<=finish;

-- Measure latency

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if lli_busy_i='0' then
			if request='1' then
				total_latency<=total_latency+current_latency;
				if current_latency>max_latency then
					max_latency<=current_latency;
				end if;
			end if;
			current_latency<=1;
		else
			if lli_dat_i=(("00"&request_addr) xor xor_constant) and current_latency=1 then
				spurious_misses<=spurious_misses+1;
			end if;
			current_latency<=current_latency+1;
		end if;
	end if;
end process;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		assert lli_busy_i='0' or request='1'
			report "LLI busy signal asserted without a request"
			severity failure;
	end if;
end process;

end architecture;
