---------------------------------------------------------------------
-- Timer
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- A simple programmable interval timer.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
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
		
		elapsed_o: out std_logic
	);
end entity;

architecture rtl of timer is

signal pulses: unsigned(31 downto 0):=(others=>'0');
signal interval: unsigned(31 downto 0):=(others=>'0');
signal cnt: unsigned(31 downto 0):=(others=>'0');
signal elapsed: std_logic:='0';

begin

process (clk_i) is
begin
	if rising_edge(clk_i) then
		if rst_i='1' then
			pulses<=(others=>'0');
			interval<=(others=>'0');
			cnt<=(others=>'0');
			elapsed<='0';
		else
			elapsed<='0';
			if pulses/=X"00000000" or cnt/=X"00000000" then
				if cnt=X"00000000" then
					if pulses/=X"FFFFFFFF" then
						pulses<=pulses-1;
					end if;
					if pulses/=X"00000000" then
						cnt<=interval;
					end if;
				else
					cnt<=cnt-1;
				end if;
				if cnt=X"00000001" then
					elapsed<='1';
				end if;
			end if;
			
			if wbs_cyc_i='1' and wbs_stb_i='1' and wbs_we_i='1' then
				for i in wbs_sel_i'range loop
					if wbs_sel_i(i)='1' then
						if wbs_adr_i="00"&X"000000" then
							pulses(i*8+7 downto i*8)<=
								unsigned(wbs_dat_i(i*8+7 downto i*8));
							cnt<=(others=>'0');
						end if;
						if wbs_adr_i="00"&X"000001" then
							interval(i*8+7 downto i*8)<=
								unsigned(wbs_dat_i(i*8+7 downto i*8));
							cnt<=(others=>'0');
						end if;
					end if;
				end loop;
			end if;
		end if;
	end if;
end process;

wbs_ack_o<=wbs_cyc_i and wbs_stb_i;
wbs_dat_o<=std_logic_vector(pulses) when wbs_adr_i="00"&X"000000" else
	std_logic_vector(interval) when wbs_adr_i="00"&X"000001" else
	(others=>'-');

elapsed_o<=elapsed;

end architecture;
