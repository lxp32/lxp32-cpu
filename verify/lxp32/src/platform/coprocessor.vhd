---------------------------------------------------------------------
-- Coprocessor
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Performs a simple arithmetic operation, uses interrupt to wake
-- up the CPU.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coprocessor is
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
		
		irq_o: out std_logic
	);
end entity;

architecture rtl of coprocessor is

signal value: unsigned(31 downto 0):=(others=>'0');
signal result: unsigned(31 downto 0):=(others=>'0');
signal cnt: integer range 0 to 5:=0;
signal irq: std_logic:='0';

begin

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			value<=(others=>'0');
			cnt<=0;
			irq<='0';
		else
			if cnt>0 then
				cnt<=cnt-1;
			end if;
			
			if cnt=1 then
				irq<='1';
			else
				irq<='0';
			end if;
			
			if wbs_cyc_i='1' and wbs_stb_i='1' and wbs_we_i='1' then
				for i in wbs_sel_i'range loop
					if wbs_sel_i(i)='1' then
						if wbs_adr_i="00"&X"000000" then
							value(i*8+7 downto i*8)<=
								unsigned(wbs_dat_i(i*8+7 downto i*8));
							cnt<=5;
						end if;
					end if;
				end loop;
			end if;
		end if;
	end if;
end process;

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			result<=(others=>'0');
		else
			result<=shift_left(value,1)+value;
		end if;
	end if;
end process;

wbs_ack_o<=wbs_cyc_i and wbs_stb_i;
wbs_dat_o<=std_logic_vector(value) when wbs_adr_i="00"&X"000000" else
	std_logic_vector(result) when wbs_adr_i="00"&X"000001" else
	(others=>'-');

irq_o<=irq;

end architecture;
