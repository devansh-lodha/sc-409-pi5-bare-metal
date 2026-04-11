CROSS_COMPILE ?= aarch64-elf-
GDB = $(CROSS_COMPILE)gdb

TARGET_ELF = target/aarch64-unknown-none/debug/sc-409-os
TARGET_IMG = kernel8.img

# Centralized debug paths
GDB_SCRIPT = ../../debug/gdb-init.txt
OOCD_CFG_PROBE = ../../debug/cmsis-dap.cfg
OOCD_CFG_CHIP = ../../debug/raspberrypi5.cfg

all:
	cargo build
	rust-objcopy --strip-all -O binary $(TARGET_ELF) $(TARGET_IMG)

gdb: all
	$(GDB) -q -x $(GDB_SCRIPT) $(TARGET_ELF)

openocd:
	openocd -f $(OOCD_CFG_PROBE) -f $(OOCD_CFG_CHIP)

clean:
	cargo clean
	rm -f $(TARGET_IMG)