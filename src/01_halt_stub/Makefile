# A Makefile is a script used by the 'make' build automation tool.
# Instead of typing out long compiler commands manually every time, we define 
# the pipeline here. 'make' reads this file and executes the commands.

# Define the cross-compiler prefix. 
# We use the standard GNU bare-metal toolchain for AArch64.
# Depending on your OS and package manager, this prefix may be 
# 'aarch64-none-elf-' or 'aarch64-elf-'.
CROSS_COMPILE ?= aarch64-elf-

# Map the specific tools in the toolchain to variables.
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy

# The 'all' target is the default action executed when you type 'make'.
all:
	# 1. ASSEMBLE: Translate the text file into raw machine code (start.o)
	$(AS) -o start.o start.s
	
	# 2. LINK: Combine object files into an ELF format using our memory blueprint (linker.ld)
	$(LD) -T linker.ld -o halt_stub.elf start.o
	
	# 3. EXTRACT: The Pi 5 firmware doesn't understand ELF metadata headers. 
	# We must extract the raw, contiguous binary bits into a flat image file.
	$(OBJCOPY) -O binary halt_stub.elf kernel8.img

# The 'clean' target deletes all generated files.
clean:
	rm -f *.o *.elf *.img
