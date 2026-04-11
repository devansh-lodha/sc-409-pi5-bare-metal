# Experiment 2: Array Summation & The BSS Scrubber

## Objective
Prove that the GNU Assembler and Linker are physically mapping our code to 4KB boundaries in RAM. Prove that the `.bss` section contains garbage data on power-up, and physically observe our assembly loop scrub it to absolute zero before calculating the sum of a 64-bit array.

## Prerequisites
1. Pi 5 powered on with the SD card (containing `config.txt`, `bcm2712-rpi-5-b.dtb`, and `kernel8.img`).
2. Debug Probe connected (SWD).
3. OpenOCD daemon running in Terminal 1.

## Step 1: Binary Autopsy (Terminal 2)
Before we run the code, we verify the toolchain obeyed our Linker Script.

```bash
cd src/02_assembly_basics
make clean
make inspect_sections
make inspect_symbols
```

## Step 2: The Execution (Terminal 2)
Launch the automated debugging pipeline:
```bash
make gdb
```

*(GDB will flash the CPU, overwrite the PC, set a breakpoint at `_start`, and pause).*

Execute this exact sequence inside the `(gdb)` prompt:

```gdb
# 1. Verify the array exists in physical RAM at exactly 0x81000.
# We eXamine 4 Decimal Giant-words (64-bit) at the address of my_array.
x/4dg &my_array

# 2. Check the raw RAM at sum_result (0x82000) BEFORE our scrubber runs.
# This will contain random power-on electrical garbage (e.g., -25840388...).
x/1dg &sum_result

# 3. Command the CPU to run. It will hit the '_start' breakpoint from our init script.
continue

# 3. We are currently paused AT _start. 
# We will set a new breakpoint at 'main', which is immediately AFTER the scrubber loop.
break main

# 5. Command it to run again. It will execute the scrubber loop and hit 'main'.
continue

# 6. We are now at 'main'. The scrubber has finished. Check the RAM at sum_result again.
# It MUST now be exactly 0. We successfully wiped the BSS section.
x/1dg &sum_result

# 7. Set a breakpoint at '.done', which is immediately AFTER the summation loop.
break .done

# 8. Let it run the summation loop at 2.4 GHz.
continue

# 9. We hit '.done'. Check X0. It should hold the final sum (10 + 20 + 30 = 60).
info registers x0

# 10. Execute the STR instruction to write 60 to physical RAM.
stepi

# 11. Verify the physical RAM now holds 60!
x/1dg &sum_result
```