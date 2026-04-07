# Experiment 1: Addition

## Objective
Bypass the compilation pipeline and inject AArch64 machine code directly into the physical RAM of a frozen BCM2712 processor using Serial Wire Debug (SWD).

## Prerequisites
1. Pi 5 powered on with `kernel8.img` (Halt Stub) on the SD card.
2. Debug Probe connected (SWD to Pi 5 Debug Header).

## Step 1: Establish Hardware Bridge (Terminal 1)
Run the OpenOCD daemon to translate TCP/IP commands into SWD electrical pulses:
```bash
openocd -f debug/cmsis-dap.cfg -f debug/raspberrypi5.cfg
```
*(Note: Errors reading `EL3` registers are expected. The Pi 5 boots in EL2 and blocks Secure Monitor access).*

## Step 2: Seize Control (Terminal 2)
Launch the bare-metal GNU Debugger:
```bash
aarch64-elf-gdb
```

Execute the following sequence inside the `(gdb)` prompt:

```gdb
# Connect to the OpenOCD daemon
target extended-remote :3333

# View the physical state of the CPU registers
info registers

# Inject raw machine code into RAM starting at 0x80008 (immediately after our stub)
# 0xd28000a0 = mov x0, #5
# 0xd28000e1 = mov x1, #7
# 0x8b010002 = add x2, x0, x1
set {int}0x80008 = 0xd28000a0
set {int}0x8000c = 0xd28000e1
set {int}0x80010 = 0x8b010002

# Verify the silicon accepted the writes by disassembling the memory
x/3i 0x80008

# Overwrite the Program Counter to hijack execution flow
set $pc = 0x80008

# Step 1: Execute 'mov x0, #5'
stepi
info registers x0

# Step 2: Execute 'mov x1, #7'
stepi
info registers x1

# Step 3: Execute 'add x2, x0, x1'
stepi
info registers x2
```