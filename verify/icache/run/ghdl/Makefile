include ../../src/make/sources.make

GHDL_FLAGS=--std=93
GHDL_GENERICS=-gCACHE_BURST_SIZE=$(CACHE_BURST_SIZE) -gCACHE_PREFETCH_SIZE=$(CACHE_PREFETCH_SIZE) -gCPU_BLOCKS=$(CPU_BLOCKS) -gVERBOSE=$(VERBOSE)

WAVE_OUT=wave.fst

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

.PRECIOUS: $(WAVE_OUT)

compile: compile.stamp

batch: compile.stamp
	ghdl -r $(GHDL_FLAGS) $(TB_MOD) $(GHDL_GENERICS)

gui: $(WAVE_OUT)
	gtkwave $(WAVE_OUT)

clean:
	rm -f *.cf
	rm -f $(WAVE_OUT)
	rm -f *.hier
	rm -f *.o
	rm -f $(TB_MOD)
	rm -f compile.stamp

########################
# Normal targets
########################

$(WAVE_OUT): compile.stamp
	-ghdl -r $(GHDL_FLAGS) $(TB_MOD) --fst=$(WAVE_OUT) $(GHDL_GENERICS)

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC)
	ghdl -a $(GHDL_FLAGS) $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC)
	ghdl -e $(GHDL_FLAGS) $(TB_MOD)
	echo > compile.stamp
