/*
 * Bare-Metal Linker Script
 * Maps physical memory and safely allocates a hardware Stack.
 */

ENTRY(_start)

SECTIONS
{
    /* Anchor execution at the GPU bootloader's target address */
    . = 0x80000;

    .text : ALIGN(4096) { 
        *(.text.boot)
        *(.text) 
    }

    .rodata : ALIGN(4096) {
        *(.rodata)
        *(.rodata.*)
    }

    .data : ALIGN(4096) { 
        *(.data) 
    }

    .bss (NOLOAD) : ALIGN(4096) { 
        __bss_start = .;
        *(.bss)
        . = ALIGN(16);
        __bss_end = .;
    }

    /* 
     * THE STACK ALLOCATION
     * We dynamically allocate a 64 Kilobyte stack AFTER the BSS section.
     * The Stack Pointer (__stack_top) is set to the very end of this block.
     * The stack grows DOWNWARDS (towards __bss_end).
     */
    .stack (NOLOAD) : ALIGN(4096) {
        /* Reserve exactly 64 KB (65,536 bytes) of empty RAM */
        . += 65536;
        
        /* 
         * Align the top of the stack to 16 bytes. 
         * This strictly enforces the AArch64 hardware alignment law.
         */
        . = ALIGN(16);
        __stack_top = .;
    }
}