---------------------------------------------------------------------
-- DSP multiplier
--
-- Part of the LXP32 CPU
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- This multiplier is designed for technologies that provide fast
-- 16x16 multipliers, including most modern FPGA families. One
-- multiplication takes 2 cycles.
-- TH:
-- extended multiplier to provide also the high 32 Bits of the 64 Bit result
-- TODO: Add support for signed high word mult.  

---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lxp32_mul_dsp is
   generic (
     pipelined : boolean := true
   );  
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		ce_i: in std_logic;
		op1_i: in std_logic_vector(31 downto 0);
		op2_i: in std_logic_vector(31 downto 0);
--		op1_signed_i : in std_logic;
--		op2_signed_i : in std_logic;
		
		ce_o: out std_logic;
		result_o: out std_logic_vector(31 downto 0);
		result_high_o : out std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of lxp32_mul_dsp is

signal pp00: std_logic_vector(31 downto 0);
signal pp01: std_logic_vector(31 downto 0);
signal pp10: std_logic_vector(31 downto 0);
signal pp11: std_logic_vector(31 downto 0);

signal product,product_h: unsigned(31 downto 0);


signal ceo: std_logic:='0';
signal ce1 : std_logic :='0'; -- for Pipelined version

begin

mul00_inst: entity work.lxp32_mul16x16
   generic map ( pipelined => pipelined)
	port map(
		clk_i=>clk_i,
		a_i=>op1_i(15 downto 0),
		b_i=>op2_i(15 downto 0),
		p_o=>pp00
	);

mul01_inst: entity work.lxp32_mul16x16
   generic map ( pipelined => pipelined)
	port map(
		clk_i=>clk_i,
		a_i=>op1_i(15 downto 0),
		b_i=>op2_i(31 downto 16),
		p_o=>pp01
	);

mul10_inst: entity work.lxp32_mul16x16
   generic map ( pipelined => pipelined)
	port map(
		clk_i=>clk_i,
		a_i=>op1_i(31 downto 16),
		b_i=>op2_i(15 downto 0),
		p_o=>pp10
	);
	
mul11_inst: entity work.lxp32_mul16x16
   generic map ( pipelined => pipelined)
	port map(
		clk_i=>clk_i,
		a_i=>op1_i(31 downto 16),
		b_i=>op2_i(31 downto 16),
		p_o=>pp11
	);	

product(31 downto 16)<=unsigned(pp00(31 downto 16))+unsigned(pp01(15 downto 0))+unsigned(pp10(15 downto 0));
product(15 downto 0)<=unsigned(pp00(15 downto 0));
product_h(15 downto 0) <= unsigned(pp01(31 downto 16))+
                          unsigned(pp10(31 downto 16))+unsigned(pp11(15 downto 0));
								  
product_h(31 downto 16) <= unsigned(pp11(31 downto 16));

--process(pp01,pp10,pp11) 
--variable p: signed(63 downto 0);
----variable t : std_logic_vector(15 downto 0);
--begin
--  
--  p :=   resize(signed(pp00),64)
--       + resize(signed(pp01& X"0000"),64)
--       + resize(signed(pp10& X"0000"),64)
--		 + resize(signed(pp11& X"00000000"),64);
--		 
--  result_high_o<=std_logic_vector(p(63 downto 32));		 
--
--
--end process;


result_o<=std_logic_vector(product);
result_high_o<=std_logic_vector(product_h);

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			ceo<='0';
         if pipelined then
           ce1 <= '0';
         end if;  
		else
         if pipelined then
           -- add two cycles of latency when pipelined is true         
           ce1 <= ce_i;
           ceo <= ce1; 
         else 
			  ceo<=ce_i;
         end if;  
		end if;
	end if;
end process;

ce_o<=ceo;

end architecture;
