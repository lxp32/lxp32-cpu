---------------------------------------------------------------------
-- LXP32 testbench package body
--
-- Part of the LXP32 testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Auxiliary package body for the LXP32 testbench
---------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;

package body tb_pkg is
	procedure load_ram(
		filename: string;
		signal clk: in std_logic;
		signal soc_in: out soc_wbs_in_type;
		signal soc_out: in soc_wbs_out_type
	) is
		file f: text open read_mode is filename;
		variable i: integer:=0;
		variable l: line;
		variable v: bit_vector(31 downto 0);
	begin
		wait until rising_edge(clk);
		
		report "Loading program RAM from """&filename&"""";
		
		while not endfile(f) loop
			readline(f,l);
			read(l,v);
			
			assert i<c_max_program_size report "Error: program size is too large" severity failure;
			
			soc_in.cyc<='1';
			soc_in.stb<='1';
			soc_in.we<='1';
			soc_in.sel<=(others=>'1');
			soc_in.adr<=std_logic_vector(to_unsigned(i,30));
			soc_in.dat<=to_stdlogicvector(v);
			
			wait until rising_edge(clk) and soc_out.ack='1';
			
			i:=i+1;
		end loop;
		
		report integer'image(i)&" words loaded from """&filename&"""";
		
		soc_in.cyc<='0';
		soc_in.stb<='0';
		
		wait until rising_edge(clk);
	end procedure;

	procedure run_test(
		filename: string;
		signal clk: in std_logic;
		signal globals: out soc_globals_type;
		signal soc_in: out soc_wbs_in_type;
		signal soc_out: in soc_wbs_out_type;
		signal result: in monitor_out_type
	) is
	begin
		-- Assert SoC and CPU resets
		wait until rising_edge(clk);
		globals.rst_i<='1';
		globals.cpu_rst_i<='1';
		wait until rising_edge(clk);
		
		-- Deassert SoC reset, leave CPU in reset state for now
		globals.rst_i<='0';
		wait until rising_edge(clk);
		
		-- Load RAM
		load_ram(filename,clk,soc_in,soc_out);
		
		-- Deassert CPU reset
		globals.cpu_rst_i<='0';
		
		while result.valid/='1' loop
			wait until rising_edge(clk);
		end loop;
		
		-- Analyze result
		
		if result.data=X"00000001" then
			report "TEST """&filename&""" RESULT: SUCCESS (return code 0x"&
				hex_string(result.data)&")";
		else
			report "TEST """&filename&""" RESULT: FAILURE (return code 0x"&
				hex_string(result.data)&")" severity failure;
		end if;
	end procedure;
end package body;
