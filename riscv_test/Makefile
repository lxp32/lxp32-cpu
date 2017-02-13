

TARGET_PREFIX ?= riscv32-unknown-elf
TARGET_CC := $(TARGET_PREFIX)-gcc
TARGET_LD := $(TARGET_PREFIX)-gcc
TARGET_SIZE := $(TARGET_PREFIX)-size
TARGET_OBJCOPY := $(TARGET_PREFIX)-objcopy
ARCH= rv32im
HEXDUMP ?= hexdump

%.elf : %.S
	$(TARGET_CC) -march=$(ARCH)  -nostartfiles -Tlxp.ld -o $@ $<


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
slt.hex : slt.S
loadsave.hex : loadsave.S
csr.hex : csr.S
trap01.hex : trap01.S
fence.hex : fence.S

all: test02.hex test01.hex test03.hex branch.hex mult.hex slt.hex loadsave.hex csr.hex trap01.hex fence.hex

