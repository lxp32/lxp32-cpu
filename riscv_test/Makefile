

TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
ARCH= RV32IM
HEXDUMP ?= hexdump

%.elf : %.S
	$(TARGET_CC) -march=$(ARCH) -m32  -nostartfiles -Tlxp.ld -o $@ $<


%.hex : %.elf
	$(TARGET_OBJCOPY) -j .text -O binary $< $(basename $@).bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $(basename $@).bin >$@	
	$(TARGET_PREFIX)-objdump -d $< >$(basename $@).lst
	$(TARGET_PREFIX)-size  $<

test02.hex : test02.S
test01.hex : test01.S
test03.hex : test03.S
branch.hex : branch.S
mult.hex : mult.S

all: test02.hex test01.hex test03.hex branch.hex mult.hex

