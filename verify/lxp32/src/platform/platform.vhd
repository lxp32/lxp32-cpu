---------------------------------------------------------------------
-- LXP32 platform top-level design unit
--
-- Part of the LXP32 test platform
--
-- Copyright (c) 2016 by Alex I. Kuznetsov
--
-- A SoC-like simulation platform for the LXP32 CPU, containing
-- a few peripherals such as program RAM, timer and coprocessor.
--
-- Note: regardless of whether this description is synthesizable,
-- it was designed exclusively for simulation purposes.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity platform is
	generic(
		CPU_DBUS_RMW: boolean;
		CPU_MUL_ARCH: string;
		MODEL_LXP32C: boolean;
		THROTTLE_DBUS: boolean;
		THROTTLE_IBUS: boolean
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		cpu_rst_i: in std_logic;
		
		wbm_cyc_o: out std_logic;
		wbm_stb_o: out std_logic;
		wbm_we_o: out std_logic;
		wbm_sel_o: out std_logic_vector(3 downto 0);
		wbm_ack_i: in std_logic;
		wbm_adr_o: out std_logic_vector(27 downto 2);
		wbm_dat_o: out std_logic_vector(31 downto 0);
		wbm_dat_i: in std_logic_vector(31 downto 0);
		
		wbs_cyc_i: in std_logic;
		wbs_stb_i: in std_logic;
		wbs_we_i: in std_logic;
		wbs_sel_i: in std_logic_vector(3 downto 0);
		wbs_ack_o: out std_logic;
		wbs_adr_i: in std_logic_vector(31 downto 2);
		wbs_dat_i: in std_logic_vector(31 downto 0);
		wbs_dat_o: out std_logic_vector(31 downto 0);
		
		gp_io: inout std_logic_vector(31 downto 0)
	);
end entity;

architecture rtl of platform is

type wbm_type is record
	cyc: std_logic;
	stb: std_logic;
	we: std_logic;
	sel: std_logic_vector(3 downto 0);
	ack: std_logic;
	adr: std_logic_vector(31 downto 2);
	wdata: std_logic_vector(31 downto 0);
	rdata: std_logic_vector(31 downto 0);
end record;

type wbs_type is record
	cyc: std_logic;
	stb: std_logic;
	we: std_logic;
	sel: std_logic_vector(3 downto 0);
	ack: std_logic;
	adr: std_logic_vector(27 downto 2);
	wdata: std_logic_vector(31 downto 0);
	rdata: std_logic_vector(31 downto 0);
end record;

type ibus_type is record
	cyc: std_logic;
	stb: std_logic;
	cti: std_logic_vector(2 downto 0);
	bte: std_logic_vector(1 downto 0);
	ack: std_logic;
	adr: std_logic_vector(29 downto 0);
	dat: std_logic_vector(31 downto 0);
end record;

signal cpu_rst: std_logic;
signal cpu_irq: std_logic_vector(7 downto 0);
signal cpu_dbus: wbm_type;
signal cpu_ibus: ibus_type;

signal lli_re: std_logic;
signal lli_adr: std_logic_vector(29 downto 0);
signal lli_dat: std_logic_vector(31 downto 0);
signal lli_busy: std_logic;

signal monitor_dbus: wbm_type;

signal ram_wb: wbs_type;

signal timer_wb: wbs_type;
signal timer_elapsed: std_logic;

signal coprocessor_wb: wbs_type;
signal coprocessor_irq: std_logic;

begin

-- Interconnect

intercon_inst: entity work.intercon(rtl)
	port map(
		clk_i=>clk_i,
		rst_i=>rst_i,

		s0_cyc_i=>wbs_cyc_i,
		s0_stb_i=>wbs_stb_i,
		s0_we_i=>wbs_we_i,
		s0_sel_i=>wbs_sel_i,
		s0_ack_o=>wbs_ack_o,
		s0_adr_i=>wbs_adr_i,
		s0_dat_i=>wbs_dat_i,
		s0_dat_o=>wbs_dat_o,

		s1_cyc_i=>monitor_dbus.cyc,
		s1_stb_i=>monitor_dbus.stb,
		s1_we_i=>monitor_dbus.we,
		s1_sel_i=>monitor_dbus.sel,
		s1_ack_o=>monitor_dbus.ack,
		s1_adr_i=>monitor_dbus.adr,
		s1_dat_i=>monitor_dbus.wdata,
		s1_dat_o=>monitor_dbus.rdata,

		m0_cyc_o=>ram_wb.cyc,
		m0_stb_o=>ram_wb.stb,
		m0_we_o=>ram_wb.we,
		m0_sel_o=>ram_wb.sel,
		m0_ack_i=>ram_wb.ack,
		m0_adr_o=>ram_wb.adr,
		m0_dat_o=>ram_wb.wdata,
		m0_dat_i=>ram_wb.rdata,

		m1_cyc_o=>wbm_cyc_o,
		m1_stb_o=>wbm_stb_o,
		m1_we_o=>wbm_we_o,
		m1_sel_o=>wbm_sel_o,
		m1_ack_i=>wbm_ack_i,
		m1_adr_o=>wbm_adr_o,
		m1_dat_o=>wbm_dat_o,
		m1_dat_i=>wbm_dat_i,
		
		m2_cyc_o=>timer_wb.cyc,
		m2_stb_o=>timer_wb.stb,
		m2_we_o=>timer_wb.we,
		m2_sel_o=>timer_wb.sel,
		m2_ack_i=>timer_wb.ack,
		m2_adr_o=>timer_wb.adr,
		m2_dat_o=>timer_wb.wdata,
		m2_dat_i=>timer_wb.rdata,
		
		m3_cyc_o=>coprocessor_wb.cyc,
		m3_stb_o=>coprocessor_wb.stb,
		m3_we_o=>coprocessor_wb.we,
		m3_sel_o=>coprocessor_wb.sel,
		m3_ack_i=>coprocessor_wb.ack,
		m3_adr_o=>coprocessor_wb.adr,
		m3_dat_o=>coprocessor_wb.wdata,
		m3_dat_i=>coprocessor_wb.rdata
	);

-- CPU

cpu_rst<=cpu_rst_i or rst_i;

-- Note: we connect the timer IRQ to 2 CPU channels to test
-- handling of simultaneously arriving interrupt requests.

cpu_irq<="00000"&coprocessor_irq&timer_elapsed&timer_elapsed;

gen_lxp32u: if not MODEL_LXP32C generate
	lxp32u_top_inst: entity work.lxp32u_top(rtl)
		generic map(
			DBUS_RMW=>CPU_DBUS_RMW,
			DIVIDER_EN=>true,
			MUL_ARCH=>CPU_MUL_ARCH,
			START_ADDR=>(others=>'0')
		)
		port map(
			clk_i=>clk_i,
			rst_i=>cpu_rst,
			
			lli_re_o=>lli_re,
			lli_adr_o=>lli_adr,
			lli_dat_i=>lli_dat,
			lli_busy_i=>lli_busy,
			
			dbus_cyc_o=>cpu_dbus.cyc,
			dbus_stb_o=>cpu_dbus.stb,
			dbus_we_o=>cpu_dbus.we,
			dbus_sel_o=>cpu_dbus.sel,
			dbus_ack_i=>cpu_dbus.ack,
			dbus_adr_o=>cpu_dbus.adr,
			dbus_dat_o=>cpu_dbus.wdata,
			dbus_dat_i=>cpu_dbus.rdata,
			
			irq_i=>cpu_irq
		);
end generate;

gen_lxp32c: if MODEL_LXP32C generate
	lxp32c_top_inst: entity work.lxp32c_top(rtl)
		generic map(
			DBUS_RMW=>CPU_DBUS_RMW,
			DIVIDER_EN=>true,
			IBUS_BURST_SIZE=>16,
			IBUS_PREFETCH_SIZE=>32,
			MUL_ARCH=>CPU_MUL_ARCH,
			START_ADDR=>(others=>'0')
		)
		port map(
			clk_i=>clk_i,
			rst_i=>cpu_rst,
			
			ibus_cyc_o=>cpu_ibus.cyc,
			ibus_stb_o=>cpu_ibus.stb,
			ibus_cti_o=>cpu_ibus.cti,
			ibus_bte_o=>cpu_ibus.bte,
			ibus_ack_i=>cpu_ibus.ack,
			ibus_adr_o=>cpu_ibus.adr,
			ibus_dat_i=>cpu_ibus.dat,
			
			dbus_cyc_o=>cpu_dbus.cyc,
			dbus_stb_o=>cpu_dbus.stb,
			dbus_we_o=>cpu_dbus.we,
			dbus_sel_o=>cpu_dbus.sel,
			dbus_ack_i=>cpu_dbus.ack,
			dbus_adr_o=>cpu_dbus.adr,
			dbus_dat_o=>cpu_dbus.wdata,
			dbus_dat_i=>cpu_dbus.rdata,
			
			irq_i=>cpu_irq
		);
	
	ibus_adapter_inst: entity work.ibus_adapter(rtl)
		port map(
			clk_i=>clk_i,
			rst_i=>rst_i,
			
			ibus_cyc_i=>cpu_ibus.cyc,
			ibus_stb_i=>cpu_ibus.stb,
			ibus_cti_i=>cpu_ibus.cti,
			ibus_bte_i=>cpu_ibus.bte,
			ibus_ack_o=>cpu_ibus.ack,
			ibus_adr_i=>cpu_ibus.adr,
			ibus_dat_o=>cpu_ibus.dat,
			
			lli_re_o=>lli_re,
			lli_adr_o=>lli_adr,
			lli_dat_i=>lli_dat,
			lli_busy_i=>lli_busy
		);
end generate;

-- DBUS monitor

dbus_monitor_inst: entity work.dbus_monitor(rtl)
	generic map(
		THROTTLE=>THROTTLE_DBUS
	)
	port map(
		clk_i=>clk_i,
		rst_i=>rst_i,
		
		wbs_cyc_i=>cpu_dbus.cyc,
		wbs_stb_i=>cpu_dbus.stb,
		wbs_we_i=>cpu_dbus.we,
		wbs_sel_i=>cpu_dbus.sel,
		wbs_ack_o=>cpu_dbus.ack,
		wbs_adr_i=>cpu_dbus.adr,
		wbs_dat_i=>cpu_dbus.wdata,
		wbs_dat_o=>cpu_dbus.rdata,
		
		wbm_cyc_o=>monitor_dbus.cyc,
		wbm_stb_o=>monitor_dbus.stb,
		wbm_we_o=>monitor_dbus.we,
		wbm_sel_o=>monitor_dbus.sel,
		wbm_ack_i=>monitor_dbus.ack,
		wbm_adr_o=>monitor_dbus.adr,
		wbm_dat_o=>monitor_dbus.wdata,
		wbm_dat_i=>monitor_dbus.rdata
	);

-- Program RAM

program_ram_inst: entity work.program_ram(rtl)
	generic map(
		THROTTLE=>THROTTLE_IBUS
	)
	port map(
		clk_i=>clk_i,
		rst_i=>rst_i,
		
		wbs_cyc_i=>ram_wb.cyc,
		wbs_stb_i=>ram_wb.stb,
		wbs_we_i=>ram_wb.we,
		wbs_sel_i=>ram_wb.sel,
		wbs_ack_o=>ram_wb.ack,
		wbs_adr_i=>ram_wb.adr,
		wbs_dat_i=>ram_wb.wdata,
		wbs_dat_o=>ram_wb.rdata,
		
		lli_re_i=>lli_re,
		lli_adr_i=>lli_adr,
		lli_dat_o=>lli_dat,
		lli_busy_o=>lli_busy
	);

-- Timer

timer_inst: entity work.timer(rtl)
	port map(
		clk_i=>clk_i,
		rst_i=>rst_i,
		
		wbs_cyc_i=>timer_wb.cyc,
		wbs_stb_i=>timer_wb.stb,
		wbs_we_i=>timer_wb.we,
		wbs_sel_i=>timer_wb.sel,
		wbs_ack_o=>timer_wb.ack,
		wbs_adr_i=>timer_wb.adr,
		wbs_dat_i=>timer_wb.wdata,
		wbs_dat_o=>timer_wb.rdata,
		
		elapsed_o=>timer_elapsed
	);

-- Coprocessor

coprocessor_inst: entity work.coprocessor(rtl)
	port map(
		clk_i=>clk_i,
		rst_i=>rst_i,
		
		wbs_cyc_i=>coprocessor_wb.cyc,
		wbs_stb_i=>coprocessor_wb.stb,
		wbs_we_i=>coprocessor_wb.we,
		wbs_sel_i=>coprocessor_wb.sel,
		wbs_ack_o=>coprocessor_wb.ack,
		wbs_adr_i=>coprocessor_wb.adr,
		wbs_dat_i=>coprocessor_wb.wdata,
		wbs_dat_o=>coprocessor_wb.rdata,
		
		irq_o=>coprocessor_irq
	);

end architecture;
