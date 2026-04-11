# Experiment 5: First Contact (UART Echo)

## Objective
Defeat the LLVM optimizer using volatile pointers to establish an interactive serial connection with the RP1 Southbridge. Prove the OS can synchronously read and write hardware registers.

## Prerequisites
1. Pi 5 powered on with the SD card.
2. Debug Probe connected (SWD to Pi 5 Debug Header).
3. **Debug Probe connected (UART TX/RX to Pi 5 UART Header).**

## The Execution

**Terminal 1 (Serial Monitor):**
Listen to the physical USB wire. (Adjust `/dev/ttyUSB0` or `/dev/cu.usbmodem...` as needed).
```bash
tio -b 115200 /dev/ttyUSB0
```

**Terminal 2 (OpenOCD):**
```bash
cd src/05_uart_mmio/
make openocd
```

**Terminal 3 (GDB):**
Launch the OS.
```bash
cd src/05_uart_mmio/
make gdb
```

Inside the `(gdb)` prompt:
```gdb
# Release the CPU from the _start breakpoint.
continue
```

**Observation:**
1. Look at Terminal 1 (`tio`). The `HELLO WORLD!` text will instantly appear.
2. Type on your physical keyboard. The keystrokes travel over the USB wire into the Pi 5, the CPU reads the RP1 Hardware FIFO, and the Rust code echoes the signal back to your screen.
