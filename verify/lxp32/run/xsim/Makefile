include ../../src/make/sources.make

ifeq ($(findstring Windows,$(OS)),)
	BAT=
else
	BAT=.bat
endif

VIVADO_GENERICS=-generic_top "CPU_DBUS_RMW=$(CPU_DBUS_RMW)" \
	-generic_top "CPU_MUL_ARCH=$(CPU_MUL_ARCH)" \
	-generic_top "MODEL_LXP32C=$(MODEL_LXP32C)" \
	-generic_top "TEST_CASE=$(TEST_CASE)" \
	-generic_top "THROTTLE_DBUS=$(THROTTLE_DBUS)" \
	-generic_top "THROTTLE_IBUS=$(THROTTLE_IBUS)" \
	-generic_top "VERBOSE=$(VERBOSE)"

########################
# Phony targets
########################

all: batch

.PHONY: all compile batch gui clean

compile: compile.stamp

batch: compile.stamp
	xsim$(BAT) -R tb_sim

gui: compile.stamp
	xsim$(BAT) -g -onfinish stop -onerror stop tb_sim

clean:
	rm -rf .Xil
	rm -rf xsim.dir
	rm -f webtalk*
	rm -f xelab*
	rm -f xsim*
	rm -f xvhdl*
	rm -f hs_err*
	rm -f vivado*
	rm -f *.wdb
	rm -f $(FIRMWARE)
	rm -f compile.stamp

########################
# Normal targets
########################

compile.stamp: $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC) $(FIRMWARE)
	xvhdl$(BAT) $(LXP32_RTL) $(COMMON_SRC) $(PLATFORM_RTL) $(TB_SRC)
	xelab$(BAT) $(VIVADO_GENERICS) work.tb -s tb_sim -debug typical
	echo > compile.stamp

%.ram: $(FW_SRC_DIR)/%.asm
	$(ASM) -f textio $^ -o $@
