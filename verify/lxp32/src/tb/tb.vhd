---------------------------------------------------------------------
-- LXP32 verification environment (self-checking testbench)
--
-- Part of the LXP32 testbench
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- Simulates LXP32 test platform, verifies results.
--
-- Parameters:
--     CPU_DBUS_RMW:    DBUS_RMW CPU generic
--     CPU_MUL_ARCH:    MUL_ARCH CPU generic
--     MODEL_LXP32C:    when true, simulates LXP32C variant (with
--                      instruction cache), otherwise LXP32U
--     TEST_CASE:       If non-empty, selects a test case to run.
--                      If empty, all tests are executed.
--     THROTTLE_IBUS:   perform pseudo-random instruction bus
--                      throttling
--     THROTTLE_DBUS:   perform pseudo-random data bus throttling
--     VERBOSE:         report everything that is written to the
--                      test monitor address space
---------------------------------------------------------------------

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;

entity tb is
	generic(
		CPU_DBUS_RMW: boolean:=false;
		CPU_MUL_ARCH: string:="dsp";
		MODEL_LXP32C: boolean:=true;
		TEST_CASE: string:="";
		THROTTLE_DBUS: boolean:=true;
		THROTTLE_IBUS: boolean:=true;
		VERBOSE: boolean:=false
	);
end entity;

architecture testbench of tb is

signal clk: std_logic:='0';

signal globals: soc_globals_type:=(others=>'1');
signal soc_wbs_in: soc_wbs_in_type;
signal soc_wbs_out: soc_wbs_out_type;
signal soc_wbm_in: soc_wbm_in_type;
signal soc_wbm_out: soc_wbm_out_type;

signal monitor_out: monitor_out_type;

signal finish: std_logic:='0';

begin

dut: entity work.platform(rtl)
	generic map(
		CPU_DBUS_RMW=>CPU_DBUS_RMW,
		CPU_MUL_ARCH=>CPU_MUL_ARCH,
		MODEL_LXP32C=>MODEL_LXP32C,
		THROTTLE_DBUS=>THROTTLE_DBUS,
		THROTTLE_IBUS=>THROTTLE_IBUS
	)
	port map(
		clk_i=>clk,
		rst_i=>globals.rst_i,
		cpu_rst_i=>globals.cpu_rst_i,
		
		wbm_cyc_o=>soc_wbm_out.cyc,
		wbm_stb_o=>soc_wbm_out.stb,
		wbm_we_o=>soc_wbm_out.we,
		wbm_sel_o=>soc_wbm_out.sel,
		wbm_ack_i=>soc_wbm_in.ack,
		wbm_adr_o=>soc_wbm_out.adr,
		wbm_dat_o=>soc_wbm_out.dat,
		wbm_dat_i=>soc_wbm_in.dat,
		
		wbs_cyc_i=>soc_wbs_in.cyc,
		wbs_stb_i=>soc_wbs_in.stb,
		wbs_we_i=>soc_wbs_in.we,
		wbs_sel_i=>soc_wbs_in.sel,
		wbs_ack_o=>soc_wbs_out.ack,
		wbs_adr_i=>soc_wbs_in.adr,
		wbs_dat_i=>soc_wbs_in.dat,
		wbs_dat_o=>soc_wbs_out.dat
	);

monitor_inst: entity work.monitor(sim)
	generic map(
		VERBOSE=>VERBOSE
	)
	port map(
		clk_i=>clk,
		rst_i=>globals.rst_i,
		
		wbs_cyc_i=>soc_wbm_out.cyc,
		wbs_stb_i=>soc_wbm_out.stb,
		wbs_we_i=>soc_wbm_out.we,
		wbs_sel_i=>soc_wbm_out.sel,
		wbs_ack_o=>soc_wbm_in.ack,
		wbs_adr_i=>soc_wbm_out.adr,
		wbs_dat_i=>soc_wbm_out.dat,
		wbs_dat_o=>soc_wbm_in.dat,
		
		finished_o=>monitor_out.valid,
		result_o=>monitor_out.data
	);

clk<=not clk and not finish after 5 ns;

process is
begin
	if TEST_CASE'length=0 then
		run_test("test001.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test002.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test003.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test004.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test005.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test006.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test007.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test008.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test009.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test010.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test011.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test012.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test013.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test014.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test015.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test016.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test017.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test018.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test019.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
		run_test("test020.ram",clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
	else
		run_test(TEST_CASE,clk,globals,soc_wbs_in,soc_wbs_out,monitor_out);
	end if;
	
	report "ALL TESTS WERE COMPLETED SUCCESSFULLY";
	finish<='1';
	wait;
end process;

end architecture;
