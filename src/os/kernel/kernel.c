#include "kernel.h"
#include "vga.h"

void kernel_main(void) {
    // Clear screen
    vga_clear_screen();
    
    // Print welcome message
    vga_print_string("Welcome to GahiraiOS!\n");
    vga_print_string("A toy operating system for learning\n\n");
    
    // Print some system info
    vga_print_string("Kernel loaded successfully\n");
    vga_print_string("Memory management: Not implemented\n");
    vga_print_string("Process scheduling: Not implemented\n");
    vga_print_string("File system: Not implemented\n\n");
    
    vga_print_string("System ready. Halting CPU...\n");
    
    // Halt the CPU
    asm volatile("hlt");
    
    // Infinite loop as fallback
    while (1) {
        asm volatile("hlt");
    }
}
