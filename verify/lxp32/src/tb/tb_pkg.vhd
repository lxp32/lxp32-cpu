---------------------------------------------------------------------
-- LXP32 testbench package
--
-- Part of the LXP32 testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Auxiliary package declaration for the LXP32 testbench
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package tb_pkg is
	constant c_max_program_size: integer:=8192;
	
	type soc_globals_type is record
		rst_i: std_logic;
		cpu_rst_i: std_logic;
	end record;
	
	type soc_wbs_in_type is record
		cyc: std_logic;
		stb: std_logic;
		we: std_logic;
		sel: std_logic_vector(3 downto 0);
		adr: std_logic_vector(31 downto 2);
		dat: std_logic_vector(31 downto 0);
	end record;

	type soc_wbs_out_type is record
		ack: std_logic;
		dat: std_logic_vector(31 downto 0);
	end record;
	
	type soc_wbm_in_type is record
		ack: std_logic;
		dat: std_logic_vector(31 downto 0);
	end record;
	
	type soc_wbm_out_type is record
		cyc: std_logic;
		stb: std_logic;
		we: std_logic;
		sel: std_logic_vector(3 downto 0);
		adr: std_logic_vector(27 downto 2);
		dat: std_logic_vector(31 downto 0);
	end record;
	
	type monitor_out_type is record
		data: std_logic_vector(31 downto 0);
		valid: std_logic;
	end record;

	procedure load_ram(
		filename: string;
		signal clk: in std_logic;
		signal soc_in: out soc_wbs_in_type;
		signal soc_out: in soc_wbs_out_type
	);

	procedure run_test(
		filename: string;
		signal clk: in std_logic;
		signal globals: out soc_globals_type;
		signal soc_in: out soc_wbs_in_type;
		signal soc_out: in soc_wbs_out_type;
		signal result: in monitor_out_type
	);
end package;
