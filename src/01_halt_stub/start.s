/*
 * The Halt Stub.
 * This is the absolute smallest valid AArch64 program possible.
 */

/*
 * .section: An assembler directive.
 * It tells the Assembler to categorize the following block of code under the 
 * name ".text.boot". Later, the Linker will use this name to grab this specific 
 * block of code and place it at the exact physical memory address we require.
 */
.section ".text.boot"

/*
 * .global: An assembler directive.
 * By default, labels (like _start) are private to this file. 
 * .global exposes the _start symbol to the Linker so the Linker can designate 
 * it as the official entry point of the entire program.
 */
.global _start

_start:
    /* 
     * wfe (Wait For Event)
     * Physically gates the clock signal to the Arithmetic Logic Unit (ALU).
     * The CPU goes into a deep sleep state, drawing minimal power, until 
     * a hardware event (like our Debug Probe) wakes it up.
     */
    wfe 

    /*
     * b (Branch)
     * If the CPU accidentally wakes up due to a random electrical glitch,
     * instantly rewrite the Program Counter to point back to the _start label.
     * The CPU is trapped here forever.
     */
    b _start
