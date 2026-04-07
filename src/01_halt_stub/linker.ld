/*
 * The Linker Script.
 * The GPU bootloader is hardcoded to take our kernel8.img file and blindly 
 * drop it into the Pi 5's physical RAM starting at exactly address 0x80000.
 * We must tell the linker to mathematically align our code to this reality.
 */

/* 
 * ENTRY declares the physical entry point. 
 * It tells the Linker and the Debugger which instruction should be executed first.
 * This symbol must match the .global symbol exported in our assembly file.
 */
ENTRY(_start)

SECTIONS
{
    /* 
     * The Location Counter (.). 
     * This instructs the Linker: "Assume all code from this point forward will be 
     * physically located in RAM starting at address 0x80000."
     */
    . = 0x80000;

    /* 
     * .text is the standard name for executable machine code.
     * We instruct the Linker to look through all compiled object files, find any 
     * code tagged with the ".text.boot" section, and place it exactly here 
     * (at 0x80000).
     */
    .text : { *(.text.boot) }
}
