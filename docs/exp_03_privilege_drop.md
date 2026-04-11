# Experiment 3: The TrustZone Firewall & The Privilege Drop

## Objective
First, prove that ARM TrustZone (EL3) physically locks out unauthenticated hardware debuggers. Second, forge a fake hardware history in the EL2 system registers to safely drop the CPU's execution privilege to Kernel Mode (EL1).

## Prerequisites
1. Pi 5 powered on with the SD card.
2. Debug Probe connected (SWD).
3. OpenOCD daemon running in Terminal 1.

---

## Experiment 3A: The TrustZone Firewall
We will attempt to trigger a Secure Monitor Call (`SMC`) to transition to EL3. Because we do not possess Broadcom's cryptographic keys to sign the payload, the hardware will violently reject the transaction and sever the debugger connection.

**Terminal 2 (GDB):**
Launch GDB on any existing ELF file (or run `make gdb` from the `01_halt_stub` directory).
```gdb
# 1. We are paused in EL2.
# 2. We inject the raw machine code for "SMC #0" (0xd4000003) into the PC.
set {int}$pc = 0xd4000003

# 3. Step the instruction. The CPU jumps into EL3.
stepi
```

**Observation:** 
Look at Terminal 1 (OpenOCD). You will see:
`Error: d-cache invalidate failed`
`Error: abort occurred - dscr = 0x03007f5b`
The hardware firewall detected an unauthenticated Non-Secure probe attempting to read Secure Memory. It severed the system bus connection. OpenOCD went blind, and GDB lost control of the CPU.

*(Note: Power cycle the Pi 5 and restart OpenOCD to recover).*

---

## Experiment 3B: The Time-Travel Drop
We will use our customized codebase to forge the `SPSR_EL2` register, injecting a fake EL1 state along with forged `N` and `Z` math flags.

**Terminal 2 (GDB):**
Navigate to `src/03_privilege_drop/` and run:
```bash
make gdb
```

Execute this exact sequence inside the `(gdb)` prompt:

```gdb
# 1. We are paused at _start in Hypervisor Mode. Check the exact state of the CPSR (PSTATE).
info registers cpsr
# Expected Output: 0x3c9 (Binary ends in 1001 = EL2h)

# 2. View the dual-pane register and assembly view to watch the CPU state change.
layout regs

# 3. Step over the HCR_EL2 configuration.
stepi
stepi

# 4. Step over the SPSR_EL2 configuration (We inject our forged 0xC00003C5).
stepi
stepi

# 5. Step over the ELR_EL2 configuration (We inject the 'el1_entry' address).
stepi
stepi

# 6. We are now hovering exactly ON the 'eret' instruction.
# Check the CPSR one last time before we drop.
info registers cpsr

# 7. Pull the trigger. Drop to EL1.
stepi

# 8. We have landed at el1_entry. 
# Mathematically prove the hardware privilege has changed.
info registers cpsr
# Expected Output: 0x3c5 (Binary ends in 0101 = EL1h)
# Verify the flags: You should physically see [ N Z ] appear in the text output!
```
