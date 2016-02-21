include ../../src/make/sources.make

VCOMFLAGS=-93
VSIMFLAGS=-t 1ps

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

compile: compile.stamp

batch: compile.stamp
	vsim $(VSIMFLAGS) -do "run -all; quit -f" -c work.$(TB_MOD)

gui: compile.stamp
	vsim $(VSIMFLAGS) work.$(TB_MOD)

clean:
	rm -rf work
	rm -f modelsim.ini
	rm -f transcript
	rm -f vsim.wlf
	rm -f $(FIRMWARE)
	rm -f compile.stamp

########################
# Normal targets
########################

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC) $(FIRMWARE) | work
	vcom $(VCOMFLAGS) $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	echo > compile.stamp

work:
	vlib work
	vmap work work

%.ram: $(FW_SRC_DIR)/%.asm
	$(ASM) -f textio $^ -o $@
