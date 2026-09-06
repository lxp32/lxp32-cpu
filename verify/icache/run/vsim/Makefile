include ../../src/make/sources.make

VSIM_GENERICS=-gCACHE_BURST_SIZE=$(CACHE_BURST_SIZE) -gCACHE_PREFETCH_SIZE=$(CACHE_PREFETCH_SIZE) -gCPU_BLOCKS=$(CPU_BLOCKS) -gVERBOSE=$(VERBOSE)

VCOMFLAGS=-93
VSIMFLAGS=-t 1ps

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

compile: compile.stamp

batch: compile.stamp
	vsim $(VSIMFLAGS) $(VSIM_GENERICS) -do "run -all; quit -f" -c work.$(TB_MOD)

gui: compile.stamp
	vsim $(VSIMFLAGS) $(VSIM_GENERICS) work.$(TB_MOD)

clean:
	rm -rf work
	rm -f modelsim.ini
	rm -f transcript
	rm -f vsim.wlf
	rm -f compile.stamp

########################
# Normal targets
########################

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC) | work
	vcom $(VCOMFLAGS) $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC)
	echo > compile.stamp

work:
	vlib work
	vmap work work
