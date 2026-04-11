use core::ptr::{read_volatile, write_volatile};
use core::arch::asm;

const RP1_BASE:   usize = 0x1F_0000_0000;
const UART0_BASE: usize = RP1_BASE + 0x03_0000;
const GPIO_BASE:  usize = RP1_BASE + 0x0D_0000;
const PADS_BASE:  usize = RP1_BASE + 0x0F_0000;

const GPIO14_CTRL: *mut u32 = (GPIO_BASE + 0x74) as *mut u32;
const GPIO15_CTRL: *mut u32 = (GPIO_BASE + 0x7C) as *mut u32;
const PADS_GPIO14: *mut u32 = (PADS_BASE + 0x3C) as *mut u32;
const PADS_GPIO15: *mut u32 = (PADS_BASE + 0x40) as *mut u32;

const UART0_DR:   *mut u32 = (UART0_BASE + 0x00) as *mut u32;
const UART0_FR:   *mut u32 = (UART0_BASE + 0x18) as *mut u32;
const UART0_IBRD: *mut u32 = (UART0_BASE + 0x24) as *mut u32;
const UART0_FBRD: *mut u32 = (UART0_BASE + 0x28) as *mut u32;
const UART0_LCRH: *mut u32 = (UART0_BASE + 0x2C) as *mut u32;
const UART0_CR:   *mut u32 = (UART0_BASE + 0x30) as *mut u32;
const UART0_ICR:  *mut u32 = (UART0_BASE + 0x44) as *mut u32;

pub fn init() {
    unsafe {
        write_volatile(UART0_CR, 0);
        write_volatile(UART0_ICR, 0x7FF);

        // GPIO 14 (TX)
        let pad14 = read_volatile(PADS_GPIO14);
        write_volatile(PADS_GPIO14, pad14 & !(1 << 7)); // Clear Output Disable
        write_volatile(GPIO14_CTRL, 4);                 // Alt4 = UART0 TX

        // GPIO 15 (RX)
        let pad15 = read_volatile(PADS_GPIO15);
        write_volatile(PADS_GPIO15, pad15 | (1 << 6) | (1 << 3)); // Input Enable + Pull-Up
        write_volatile(GPIO15_CTRL, 4);                           // Alt4 = UART0 RX

        // 48 MHz Clock -> 115200 Baud
        write_volatile(UART0_IBRD, 26);
        write_volatile(UART0_FBRD, 3);

        // 8N1, Enable FIFOs
        write_volatile(UART0_LCRH, (1 << 4) | (0b11 << 5));
        
        // Enable UART, TX, RX
        write_volatile(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
    }
}

pub fn send_char(c: u8) {
    unsafe {
        while (read_volatile(UART0_FR) & (1 << 5)) != 0 {
            asm!("nop");
        }
        write_volatile(UART0_DR, c as u32);
    }
}

pub fn read_char() -> u8 {
    unsafe {
        while (read_volatile(UART0_FR) & (1 << 4)) != 0 {
            asm!("nop");
        }
        (read_volatile(UART0_DR) & 0xFF) as u8
    }
}

pub fn send_string(s: &str) {
    for b in s.bytes() {
        if b == b'\n' {
            send_char(b'\r'); 
        }
        send_char(b);
    }
}