#![no_std]
#![no_main]

use core::arch::asm;
use core::panic::PanicInfo;

mod uart;

core::arch::global_asm!(include_str!("boot.s"));

#[unsafe(no_mangle)]
pub extern "C" fn _start_rust() -> ! {
    uart::init();

    uart::send_string("\n\n========================================\n");
    uart::send_string("   RASPBERRY PI 5 - MMIO UART ACTIVE    \n");
    uart::send_string("========================================\n");
    uart::send_string("Type something, and I will echo it back:\n> ");

    loop {
        // Block until electrical data arrives
        let c = uart::read_char();
        
        // Echo it back
        if c == b'\r' {
            uart::send_string("\n> ");
        } else {
            uart::send_char(c);
        }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    uart::send_string("\n\n!!! KERNEL PANIC !!!\n");
    loop { 
        unsafe { asm!("wfe") }; 
    }
}