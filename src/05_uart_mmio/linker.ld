ENTRY(_start)

SECTIONS
{
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

    .stack (NOLOAD) : ALIGN(4096) {
        . += 65536;
        . = ALIGN(16);
        __stack_top = .;
    }
}