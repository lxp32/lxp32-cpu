include ../../src/make/sources.make

NVC_FLAGS=--std=93 --messages=compact
NVC_GENERICS=-g CPU_DBUS_RMW=$(CPU_DBUS_RMW) -g CPU_MUL_ARCH=$(CPU_MUL_ARCH) -g MODEL_LXP32C=$(MODEL_LXP32C) -g TEST_CASE=$(TEST_CASE) -g THROTTLE_DBUS=$(THROTTLE_DBUS) -g THROTTLE_IBUS=$(THROTTLE_IBUS) -g VERBOSE=$(VERBOSE)

WAVE_OUT=wave.fst

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

.PRECIOUS: $(WAVE_OUT)

compile: compile.stamp $(FIRMWARE)

batch: compile.stamp $(FIRMWARE)
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

$(WAVE_OUT): compile.stamp $(FIRMWARE)
	-nvc $(NVC_FLAGS) -r $(TB_MOD) --format=fst --wave=$(WAVE_OUT)

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	nvc $(NVC_FLAGS) -a $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	nvc $(NVC_FLAGS) -e $(TB_MOD) $(NVC_GENERICS)
	echo > compile.stamp

%.ram: $(FW_SRC_DIR)/%.asm
	$(ASM) -f textio $^ -o $@
