CROSS_COMPILE ?= aarch64-elf-
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
GDB = $(CROSS_COMPILE)gdb

TARGET_ELF = program.elf
TARGET_IMG = kernel8.img
GDB_SCRIPT = ../../debug/gdb-init.txt

all:
	$(AS) -g -o main.o main.s
	$(LD) -T linker.ld -o $(TARGET_ELF) main.o
	$(OBJCOPY) -O binary $(TARGET_ELF) $(TARGET_IMG)

gdb: all
	$(GDB) -q -x $(GDB_SCRIPT) $(TARGET_ELF)

clean:
	rm -f *.o *.elf *.img