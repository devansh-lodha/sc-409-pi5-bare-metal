/*
 * The C-ABI Bootloader
 * Routes multicore execution, drops privilege, initializes the Stack, 
 * scrubs RAM, and jumps to Rust.
 */

.section .text.boot
.global _start

_start:
    /* 
     * 1. MULTICORE ROUTING
     * Read the Multiprocessor Affinity Register (MPIDR_EL1).
     * Extract the Core ID (the bottom 8 bits).
     * If Core ID is 0, continue. If not 0, branch to the parking loop.
     */
    mrs x0, mpidr_el1
    and x0, x0, #0xFF
    cbnz x0, .park_core

.core0_master:
    /* 
     * 2. PRIVILEGE DROP (EL2 -> EL1)
     * Forge the hardware state to drop to Kernel Mode.
     */
    mov x0, #(1 << 31)      /* Assert 64-bit execution for EL1 */
    msr hcr_el2, x0

    ldr x0, =0x3c5          /* Target EL1h, Mask all Hardware Interrupts */
    msr spsr_el2, x0

    adr x0, .el1_entry      /* Load the landing pad address */
    msr elr_el2, x0
    eret                    /* Pull the trigger */

.el1_entry:
    /* 
     * 3. INITIALIZE THE STACK
     * Load the physical 16-byte aligned address dynamically calculated 
     * by the Linker Script, and wire it into the hardware Stack Pointer.
     */
    ldr x0, =__stack_top
    mov sp, x0

    /* 
     * 4. ZERO OUT BSS
     */
    ldr x1, =__bss_start
    ldr x2, =__bss_end

.clear_bss:
    cmp x1, x2
    b.eq .boot_rust
    stp xzr, xzr, [x1], #16
    b .clear_bss

.boot_rust:
    /* 
     * 5. HANDOFF TO HIGH-LEVEL ABSTRACTION
     * Branch with Link (BL) saves our return address in X30 and 
     * jumps to the C-ABI compliant Rust entry point.
     */
    bl _start_rust

.park_core:
    wfe
    b .park_core