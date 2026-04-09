/*
 * Bare-Metal Linker Script
 * Defines the physical memory map. Sections are aligned to 4096 bytes (4KB) 
 * to match the hardware page granularity of the ARM Memory Management Unit.
 */

ENTRY(_start)

SECTIONS
{
    /* Anchor the execution at the physical address expected by the GPU bootloader */
    . = 0x80000;

    /* 1. EXECUTABLE CODE (PROGBITS) */
    .text : ALIGN(4096) { 
        *(.text.boot)
        *(.text) 
    }

    /* 2. INITIALIZED DATA (PROGBITS) */
    .data : ALIGN(4096) { 
        *(.data) 
    }

    /* 
     * 3. UNINITIALIZED DATA (NOBITS)
     * Placed at the absolute bottom to prevent the objcopy from having to reserve space in the middle for this.
     * Because it is NOBITS and at the end, objcopy will truncate the .img file here.
     */
    .bss : ALIGN(4096) { 
        /* Export the exact physical start address for our assembly scrubber */
        __bss_start = .;
        
        *(.bss)
        
        /* 
         * Align the end address to 16 bytes. Our assembly scrubber writes 16 bytes 
         * at a time (STP). If the BSS size isn't a multiple of 16, we would 
         * overwrite memory past the end of the BSS section.
         */
        . = ALIGN(16);
        __bss_end = .;
    }
}