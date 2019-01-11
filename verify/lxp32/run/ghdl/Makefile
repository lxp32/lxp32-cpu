include ../../src/make/sources.make

GHDL_FLAGS=--std=93

WAVE_VCD=wave.vcd
WAVE_OUT=wave.fst

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

.PRECIOUS: $(WAVE_OUT) $(WAVE_VCD)

compile: compile.stamp $(FIRMWARE)

batch: compile.stamp $(FIRMWARE)
	ghdl -r $(GHDL_FLAGS) $(TB_MOD)

gui: $(WAVE_OUT)
	gtkwave $(WAVE_OUT)

clean:
	rm -f *.cf
	rm -f $(WAVE_VCD)
	rm -f $(WAVE_OUT)
	rm -f $(FIRMWARE)
	rm -f *.o
	rm -f $(TB_MOD)
	rm -f compile.stamp

########################
# Normal targets
########################

$(WAVE_OUT): $(WAVE_VCD)
	vcd2fst $^ $@

$(WAVE_VCD): compile.stamp $(FIRMWARE)
	ghdl -r $(GHDL_FLAGS) $(TB_MOD) --vcd=$(WAVE_VCD)

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	ghdl -a $(GHDL_FLAGS) $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	ghdl -e $(GHDL_FLAGS) $(TB_MOD)
	echo > compile.stamp

%.ram: $(FW_SRC_DIR)/%.asm
	$(ASM) -f textio $^ -o $@
