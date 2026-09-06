include ../../src/make/sources.make

NVC_FLAGS=--std=93 --messages=compact
NVC_GENERICS=-g CACHE_BURST_SIZE=$(CACHE_BURST_SIZE) -g CACHE_PREFETCH_SIZE=$(CACHE_PREFETCH_SIZE) -g CPU_BLOCKS=$(CPU_BLOCKS) -g VERBOSE=$(VERBOSE)

WAVE_OUT=wave.fst

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

.PRECIOUS: $(WAVE_OUT)

compile: compile.stamp

batch: compile.stamp
	nvc $(NVC_FLAGS) -r $(TB_MOD)

gui: $(WAVE_OUT)
	gtkwave $(WAVE_OUT)

clean:
	rm -rf work
	rm -f $(WAVE_OUT)
	rm -f *.hier
	rm -f $(FIRMWARE)
	rm -f compile.stamp

########################
# Normal targets
########################

$(WAVE_OUT): compile.stamp
	-nvc $(NVC_FLAGS) -r $(TB_MOD) --format=fst --wave=$(WAVE_OUT)

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC)
	nvc $(NVC_FLAGS) -a $(LXP32_RTL) $(COMMON_SRC) $(TB_SRC)
	nvc $(NVC_FLAGS) -e $(TB_MOD) $(NVC_GENERICS)
	echo > compile.stamp
