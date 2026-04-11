.section .text.boot
.global _start

_start:
    /* 1. Isolate Core 0 */
    mrs x0, mpidr_el1
    and x0, x0, #0xFF
    cbnz x0, .park_core

.core0_master:
    /* 2. Set AArch64 for EL1 */
    mov x0, #(1 << 31)
    msr hcr_el2, x0

    /* 3. Master CPU Control: Disable MMU, Disable Caches, Force Little-Endian */
    ldr x0, =0x30C50830
    msr sctlr_el1, x0

    /* 4. Enable SIMD/Floating-Point (Prevents LLVM optimization crashes) */
    mov x0, #(3 << 20)
    msr cpacr_el1, x0

    /* 5. Forge Hardware State & Drop to EL1 */
    ldr x0, =0x3c5          /* Target EL1h, Mask Hardware Interrupts */
    msr spsr_el2, x0
    adr x0, .el1_entry
    msr elr_el2, x0
    eret

.el1_entry:
    /* 6. Initialize the Stack */
    ldr x0, =__stack_top
    mov sp, x0

    /* 7. Scrub BSS */
    ldr x1, =__bss_start
    ldr x2, =__bss_end
.clear_bss:
    cmp x1, x2
    b.eq .boot_rust
    stp xzr, xzr, [x1], #16
    b .clear_bss

.boot_rust:
    /* 8. Jump to High-Level Rust */
    bl _start_rust

.park_core:
    wfe
    b .park_core