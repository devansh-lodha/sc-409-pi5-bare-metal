# Experiment 4: The C-ABI Bridge & Booting Rust

## Objective
Prove the multi-core routing isolates Core 0. Prove the Time-Travel Drop lands the CPU in Kernel Mode (EL1h). Prove the dynamic Linker Script correctly allocated a safe, downward-growing Stack. Finally, prove that Rust can safely allocate and mutate local variables on that Stack.

## Prerequisites
1. Pi 5 powered on with the SD card.
2. Debug Probe connected (SWD).
3. OpenOCD daemon running in Terminal 1.

---

## The Execution

**Terminal 2 (GDB):**
Navigate to `src/04_booting_rust/` and run:
```bash
make gdb
```

*(GDB will flash the CPU, set a breakpoint at `_start`, and pause).*

Execute this exact sequence inside the `(gdb)` prompt:

```gdb
# 1. We are paused at _start in EL2. 
# Set a breakpoint precisely at the EL1 landing pad.
break .el1_entry
continue

# 2. We hit .el1_entry. 
# Mathematically verify the Privilege Drop succeeded!
info registers cpsr
# Expected: The mode bits should change to EL1h, proving Kernel Mode.

# 3. Set a breakpoint at our Rust entry point and run.
# This allows the hardware to execute the Stack setup and BSS scrubber.
break _start_rust
continue

# 4. BOOM. We are inside Rust.
# Look at your GDB screen: the source code view has switched from Assembly to main.rs!

# 5. Let's verify the Stack Physics.
# Ask the Linker where it mathematically placed the top of our Stack.
print &__stack_top

# Ask the CPU where the physical Stack Pointer (SP) is currently pointing.
# These two numbers MUST be identical.
info registers sp

# 6. Step into the Rust loop. 
# Because we compiled with debug symbols, 'step' executes one line of Rust source code, 
# not just one assembly instruction.
step

# 7. Check the value of our local Rust variable on the stack.
print iteration

# 8. Step through the loop again to prove mutation works without alignment faults.
step
step
print iteration
```
