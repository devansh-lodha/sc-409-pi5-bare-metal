/*
 * The Privilege Drop
 * Demonstrates forging hardware state registers to execute a safe ERET to EL1.
 */

.section .text.boot
.global _start

_start:
    /* 
     * 1. HCR_EL2 (Hypervisor Configuration Register)
     * Defensively assert that EL1 must run in 64-bit AArch64 mode.
     * Bit 31 (RW) = 1.
     */
    mov x0, #(1 << 31)
    msr hcr_el2, x0

    /* 
     * 2. SPSR_EL2 (Saved Program Status Register)
     * We forge the PSTATE we want to "return" to.
     * 
     * Base Target: 0x3c5 (EL1h, Interrupts Masked)
     * Forge N Flag (Bit 31): 1 << 31 = 0x80000000
     * Forge Z Flag (Bit 30): 1 << 30 = 0x40000000
     * Combined Hex: 0xC00003C5
     */
    ldr x0, =0xC00003C5
    msr spsr_el2, x0

    /* 
     * 3. ELR_EL2 (Exception Link Register)
     * We forge the return address, pointing it to our EL1 landing pad.
     */
    adr x0, el1_entry
    msr elr_el2, x0

    /* 
     * 4. PULL THE TRIGGER
     * The hardware reads SPSR_EL2 -> PSTATE, and ELR_EL2 -> PC.
     */
    eret

/* ------------------------------------------------------------------------- */

.section .text

el1_entry:
    /* We have successfully teleported to EL1. */
.halt:
    wfe
    b .halt