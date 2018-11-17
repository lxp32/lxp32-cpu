# CPU RTL

LXP32_DIR=../../../../rtl
LXP32_RTL=$(LXP32_DIR)/lxp32_mul16x16.vhd\
	$(LXP32_DIR)/lxp32_mul_dsp.vhd\
	$(LXP32_DIR)/lxp32_mul_opt.vhd\
	$(LXP32_DIR)/lxp32_mul_seq.vhd\
	$(LXP32_DIR)/lxp32_compl.vhd\
	$(LXP32_DIR)/lxp32_divider.vhd\
	$(LXP32_DIR)/lxp32_shifter.vhd\
	$(LXP32_DIR)/lxp32_alu.vhd\
	$(LXP32_DIR)/lxp32_dbus.vhd\
	$(LXP32_DIR)/lxp32_execute.vhd\
	$(LXP32_DIR)/lxp32_decode.vhd\
	$(LXP32_DIR)/lxp32_ubuf.vhd\
	$(LXP32_DIR)/lxp32_fetch.vhd\
	$(LXP32_DIR)/lxp32_ram256x32.vhd\
	$(LXP32_DIR)/lxp32_interrupt_mux.vhd\
	$(LXP32_DIR)/lxp32_scratchpad.vhd\
	$(LXP32_DIR)/lxp32_cpu.vhd\
	$(LXP32_DIR)/lxp32u_top.vhd\
	$(LXP32_DIR)/lxp32_icache.vhd\
	$(LXP32_DIR)/lxp32c_top.vhd

# Common package

COMMON_PKG_DIR=../../../common_pkg
COMMON_SRC=$(COMMON_PKG_DIR)/common_pkg.vhd $(COMMON_PKG_DIR)/common_pkg_body.vhd

# Platform RTL

PLATFORM_DIR=../../src/platform
PLATFORM_RTL=$(PLATFORM_DIR)/generic_dpram.vhd\
	$(PLATFORM_DIR)/scrambler.vhd\
	$(PLATFORM_DIR)/dbus_monitor.vhd\
	$(PLATFORM_DIR)/program_ram.vhd\
	$(PLATFORM_DIR)/timer.vhd\
	$(PLATFORM_DIR)/coprocessor.vhd\
	$(PLATFORM_DIR)/intercon.vhd\
	$(PLATFORM_DIR)/ibus_adapter.vhd\
	$(PLATFORM_DIR)/platform.vhd

# Testbench sources

COMMON_PKG_DIR=../../../common_pkg
TB_DIR=../../src/tb
TB_SRC=$(TB_DIR)/tb_pkg.vhd\
	$(TB_DIR)/tb_pkg_body.vhd\
	$(TB_DIR)/monitor.vhd\
	$(TB_DIR)/tb.vhd

TB_MOD=tb

# Firmware

FW_SRC_DIR=../../src/firmware
FIRMWARE=test001.ram\
	test002.ram\
	test003.ram\
	test004.ram\
	test005.ram\
	test006.ram\
	test007.ram\
	test008.ram\
	test009.ram\
	test010.ram\
	test011.ram\
	test012.ram\
	test013.ram\
	test014.ram\
	test015.ram\
	test016.ram\
	test017.ram\
	test018.ram\
	test019.ram\
	test020.ram

# LXP32 assembler executable

ASM=../../../../tools/bin/lxp32asm
