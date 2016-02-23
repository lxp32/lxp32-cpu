---------------------------------------------------------------------
-- Divider
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Based on the NRD (Non Restoring Division) algorithm. One division
-- takes 37 cycles.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_divider is
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		ce_i: in std_logic;
		op1_i: in std_logic_vector(31 downto 0);
		op2_i: in std_logic_vector(31 downto 0);
		signed_i: in std_logic;
		rem_i: in std_logic;
		ce_o: out std_logic;
		result_o: out std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of lxp32_divider is

-- Complementor signals

signal compl1_inv: std_logic;
signal compl2_inv: std_logic;
signal compl1_mux: std_logic_vector(31 downto 0);
signal compl2_mux: std_logic_vector(31 downto 0);
signal compl1_out: std_logic_vector(31 downto 0);
signal compl2_out: std_logic_vector(31 downto 0);

signal inv_res: std_logic;

-- Divider FSM signals

signal fsm_ce: std_logic:='0';

signal dividend: unsigned(31 downto 0);
signal divisor: unsigned(32 downto 0);
signal want_remainder: std_logic;

signal partial_remainder: unsigned(32 downto 0);
signal addend: unsigned(32 downto 0);
signal sum: unsigned(32 downto 0);
signal sum_positive: std_logic;
signal sum_subtract: std_logic;

signal cnt: integer range 0 to 34:=0;

signal ceo: std_logic:='0';

-- Output restoration signals

signal remainder_corrector: unsigned(31 downto 0);
signal quotient_pos: unsigned(31 downto 0);
signal remainder_pos: unsigned(31 downto 0);
signal result_pos: unsigned(31 downto 0);

begin

compl1_inv<=op1_i(31) and signed_i when ce_i='1' else inv_res;
compl2_inv<=op2_i(31) and signed_i;

compl1_mux<=op1_i when ce_i='1' else std_logic_vector(result_pos);
compl2_mux<=op2_i;

compl_op1_inst: entity work.lxp32_compl(rtl)
	port map(
		clk_i=>clk_i,
		compl_i=>compl1_inv,
		d_i=>compl1_mux,
		d_o=>compl1_out
	);

compl_op2_inst: entity work.lxp32_compl(rtl)
	port map(
		clk_i=>clk_i,
		compl_i=>compl2_inv,
		d_i=>compl2_mux,
		d_o=>compl2_out
	);

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			fsm_ce<='0';
		else
			fsm_ce<=ce_i;
			if ce_i='1' then
				want_remainder<=rem_i;
				if rem_i='1' then
					inv_res<=op1_i(31) and signed_i;
				else
					inv_res<=(op1_i(31) xor op2_i(31)) and signed_i;
				end if;
			end if;
		end if;
	end if;
end process;

-- Main adder/subtractor

addend_gen: for i in addend'range generate
	addend(i)<=divisor(i) xor sum_subtract;
end generate;

sum<=partial_remainder+addend+(to_unsigned(0,32)&sum_subtract);
sum_positive<=not sum(32);

-- Divider state machine

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			cnt<=0;
			ceo<='0';
		else
			ceo<='0';
			if fsm_ce='1' then
				dividend<=unsigned(compl1_out(30 downto 0)&"0");
				divisor<=unsigned("0"&compl2_out);
				partial_remainder<=to_unsigned(0,32)&compl1_out(31);
				sum_subtract<='1';
				cnt<=34;
			elsif cnt>0 then
				partial_remainder<=sum(31 downto 0)&dividend(31);
				sum_subtract<=sum_positive;
				dividend<=dividend(30 downto 0)&sum_positive;
				if cnt=1 then
					ceo<='1';
				end if;
				cnt<=cnt-1;
			else
				dividend<=(others=>'-');
				divisor<=(others=>'-');
				partial_remainder<=(others=>'-');
			end if;
		end if;
	end if;
end process;

-- Output restoration circuit

process (clk_i) is
begin
	if rising_edge(clk_i) then
		for i in remainder_corrector'range loop
			remainder_corrector(i)<=divisor(i) and not sum_positive;
		end loop;
		if want_remainder='1' then
			result_pos<=partial_remainder(32 downto 1)+remainder_corrector;
		else
			result_pos<=dividend;
		end if;
	end if;
end process;

result_o<=compl1_out;
ce_o<=ceo;

end architecture;
