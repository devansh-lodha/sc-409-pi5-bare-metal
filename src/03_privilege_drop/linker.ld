ENTRY(_start)
SECTIONS
{
    . = 0x80000;
    .text : ALIGN(4096) { 
        *(.text.boot)
        *(.text) 
    }
    .data : ALIGN(4096) { *(.data) }
    .bss (NOLOAD) : ALIGN(4096) { 
        __bss_start = .;
        *(.bss)
        . = ALIGN(16);
        __bss_end = .;
    }
}