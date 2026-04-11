#![no_std]
#![no_main]

use core::arch::asm;
use core::panic::PanicInfo;
use core::hint::black_box; // Import the black_box hint

// Inject the bootloader
core::arch::global_asm!(include_str!("boot.s"));

/// The absolute entry point for our Rust Operating System.
/// Rust 2024 requires no_mangle to be marked unsafe because it alters 
/// global Linker behavior, which could cause namespace collisions.
#[unsafe(no_mangle)]
pub extern "C" fn _start_rust() -> ! {
    
    // We declare a local variable to prove the Stack is perfectly aligned.
    let mut iteration: u64 = 0;

    loop {
        iteration += 1;
        
        // black_box tells the compiler: "Do not optimize this variable away, 
        // and do not warn me that it is unused. I am doing secret hardware things with it."
        black_box(iteration);
        
        // Waste 1 clock cycle
        unsafe { asm!("nop") }; 
    }
}

/// The Hardware Trap for Software Errors.
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop { 
        unsafe { asm!("wfe") }; 
    }
}