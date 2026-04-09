/*
 * Array Summation
 * Demonstrates BSS zeroing, post-indexed addressing, and hardware loops.
 */

/* -------------------------------------------------------------------------
 * THE BOOT STUB & BSS SCRUBBER
 * ------------------------------------------------------------------------- */
.section .text.boot
.global _start

_start:
    /* 
     * 1. The BSS Zeroing Loop
     * Physical RAM contains garbage data on power-up. We must manually zero 
     * the .bss section before executing our main logic.
     * We load the physical boundary addresses exported by the Linker Script.
     */
    ldr x1, =__bss_start
    ldr x2, =__bss_end

.clear_bss:
    /* If the current address (X1) equals the end address (X2), we are done. */
    cmp x1, x2
    b.eq main

    /* 
     * Store Pair Zero Register (STP XZR, XZR).
     * Writes 16 bytes of absolute zero to the address in X1.
     * Post-index (#16): Automatically increments X1 by 16 in the same cycle.
     */
    stp xzr, xzr, [x1], #16
    b .clear_bss


/* -------------------------------------------------------------------------
 * THE EXECUTABLE LOGIC
 * ------------------------------------------------------------------------- */
.section .text

main:
    mov x0, #0              /* X0: Accumulator */
    ldr x1, =my_array       /* X1: Array pointer */
    ldr x2, =sum_result     /* X2: Destination pointer */

.loop:
    /* Post-Indexed Load: Read 8 bytes into X3, then increment X1 by 8 */
    ldr x3, [x1], #8

    /* Check: If X3 is exactly 0, break the loop immediately */
    cbz x3, .done

    /* Accumulate and Repeat */
    add x0, x0, x3
    b .loop

.done:
    /* Commit the 64-bit result to physical RAM */
    str x0, [x2]

.halt:
    /* Gate the ALU clock and sleep */
    wfe
    b .halt


/* -------------------------------------------------------------------------
 * INITIALIZED DATA (PROGBITS - Stored in the binary)
 * ------------------------------------------------------------------------- */
.section .data
.balign 8                   /* Ensure 8-byte alignment for 64-bit .quad */
my_array:
    .quad 10, 20, 30, 0     /* Payload terminated by 0 */


/* -------------------------------------------------------------------------
 * UNINITIALIZED DATA (NOBITS - RAM only)
 * ------------------------------------------------------------------------- */
.section .bss
.balign 8
sum_result:
    .space 8                /* Reserve 8 bytes for the final answer */