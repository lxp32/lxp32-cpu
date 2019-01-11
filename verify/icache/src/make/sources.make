# CPU RTL

LXP32_DIR=../../../../rtl
LXP32_RTL=$(LXP32_DIR)/lxp32_ram256x32.vhd\
	$(LXP32_DIR)/lxp32_icache.vhd

# Common package

COMMON_PKG_DIR=../../../common_pkg
COMMON_SRC=$(COMMON_PKG_DIR)/common_pkg.vhd $(COMMON_PKG_DIR)/common_pkg_body.vhd

# Testbench sources

TB_DIR=../../src/tb
TB_SRC=$(TB_DIR)/tb_pkg.vhd\
	$(TB_DIR)/cpu_model.vhd\
	$(TB_DIR)/ram_model.vhd\
	$(TB_DIR)/tb.vhd

TB_MOD=tb
