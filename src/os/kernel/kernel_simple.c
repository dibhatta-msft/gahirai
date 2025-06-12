#include "kernel_simple.h"

// VGA text mode constants
#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_ATTRIBUTE_BYTE 0x0F  // White text on black background

// Keyboard constants
#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

static char* vga_buffer = (char*)VGA_MEMORY;
static int vga_cursor_x = 0;
static int vga_cursor_y = 0;

// Simple scancode to ASCII mapping (US keyboard)
static char scancode_to_ascii[] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' '
};

// Port I/O functions
static inline unsigned char inb(unsigned short port) {
    unsigned char result;
    asm volatile("in %%dx, %%al" : "=a" (result) : "d" (port));
    return result;
}

static inline void outb(unsigned short port, unsigned char data) {
    asm volatile("out %%al, %%dx" : : "a" (data), "d" (port));
}

void vga_clear_screen(void) {
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i * 2] = ' ';
        vga_buffer[i * 2 + 1] = VGA_ATTRIBUTE_BYTE;
    }
    vga_cursor_x = 0;
    vga_cursor_y = 0;
}

void vga_scroll_screen(void) {
    // Move all lines up by one
    for (int i = 0; i < (VGA_HEIGHT - 1) * VGA_WIDTH; i++) {
        vga_buffer[i * 2] = vga_buffer[(i + VGA_WIDTH) * 2];
        vga_buffer[i * 2 + 1] = vga_buffer[(i + VGA_WIDTH) * 2 + 1];
    }
    
    // Clear the last line
    for (int i = (VGA_HEIGHT - 1) * VGA_WIDTH; i < VGA_HEIGHT * VGA_WIDTH; i++) {
        vga_buffer[i * 2] = ' ';
        vga_buffer[i * 2 + 1] = VGA_ATTRIBUTE_BYTE;
    }
    
    vga_cursor_y = VGA_HEIGHT - 1;
    vga_cursor_x = 0;
}

void vga_put_char(char c) {
    if (c == '\n') {
        vga_cursor_x = 0;
        vga_cursor_y++;
    } else if (c == '\b') {
        if (vga_cursor_x > 0) {
            vga_cursor_x--;
            int index = (vga_cursor_y * VGA_WIDTH + vga_cursor_x) * 2;
            vga_buffer[index] = ' ';
            vga_buffer[index + 1] = VGA_ATTRIBUTE_BYTE;
        }
    } else {
        int index = (vga_cursor_y * VGA_WIDTH + vga_cursor_x) * 2;
        vga_buffer[index] = c;
        vga_buffer[index + 1] = VGA_ATTRIBUTE_BYTE;
        vga_cursor_x++;
    }
    
    // Handle line wrapping
    if (vga_cursor_x >= VGA_WIDTH) {
        vga_cursor_x = 0;
        vga_cursor_y++;
    }
    
    // Handle scrolling
    if (vga_cursor_y >= VGA_HEIGHT) {
        vga_scroll_screen();
    }
}

void vga_print_string(const char* str) {
    while (*str) {
        vga_put_char(*str);
        str++;
    }
}

void vga_print_hex(unsigned int value) {
    vga_print_string("0x");
    char hex_chars[] = "0123456789ABCDEF";
    char hex_str[9];
    hex_str[8] = '\0';
    
    for (int i = 7; i >= 0; i--) {
        hex_str[i] = hex_chars[value & 0xF];
        value >>= 4;
    }
    
    vga_print_string(hex_str);
}

void keyboard_init(void) {
    // Simple keyboard initialization
    // Clear any pending data
    while (inb(KEYBOARD_STATUS_PORT) & 0x01) {
        inb(KEYBOARD_DATA_PORT);
    }
}

char keyboard_get_char(void) {
    unsigned char scancode;
    
    // Wait for a key press
    while (!(inb(KEYBOARD_STATUS_PORT) & 0x01)) {
        // Wait
    }
    
    scancode = inb(KEYBOARD_DATA_PORT);
    
    // Only handle key press events (not key release)
    if (scancode & 0x80) {
        return 0; // Key release, ignore
    }
    
    // Convert scancode to ASCII
    if (scancode < sizeof(scancode_to_ascii)) {
        return scancode_to_ascii[scancode];
    }
    
    return 0; // Unknown key
}

void process_command(const char* command) {
    if (command[0] == '\0') {
        return; // Empty command
    }
    
    // Simple string comparison
    int help_match = 1;
    const char* help_cmd = "help";
    for (int i = 0; help_cmd[i] != '\0'; i++) {
        if (command[i] != help_cmd[i]) {
            help_match = 0;
            break;
        }
    }
    
    int clear_match = 1;
    const char* clear_cmd = "clear";
    for (int i = 0; clear_cmd[i] != '\0'; i++) {
        if (command[i] != clear_cmd[i]) {
            clear_match = 0;
            break;
        }
    }
    
    int reboot_match = 1;
    const char* reboot_cmd = "reboot";
    for (int i = 0; reboot_cmd[i] != '\0'; i++) {
        if (command[i] != reboot_cmd[i]) {
            reboot_match = 0;
            break;
        }
    }
    
    if (help_match && command[4] == '\0') {
        vga_print_string("Available commands:\n");
        vga_print_string("  help   - Show this help\n");
        vga_print_string("  clear  - Clear screen\n");
        vga_print_string("  reboot - Restart system\n");
    } else if (clear_match && command[5] == '\0') {
        vga_clear_screen();
    } else if (reboot_match && command[6] == '\0') {
        vga_print_string("Rebooting system...\n");
        // Reboot using keyboard controller
        outb(0x64, 0xFE);
    } else {
        vga_print_string("Unknown command: ");
        vga_print_string(command);
        vga_print_string("\nType 'help' for available commands.\n");
    }
}

void kernel_main(void) {
    // Initialize
    vga_clear_screen();
    keyboard_init();
    
    // Print welcome message
    vga_print_string("Welcome to GahiraiOS - Minimal Interactive Shell\n");
    vga_print_string("Type 'help' for available commands.\n\n");
    
    char command_buffer[256];
    int command_pos = 0;
    
    while (1) {
        vga_print_string("gahirai> ");
        command_pos = 0;
        
        // Read command
        while (1) {
            char c = keyboard_get_char();
            
            if (c == 0) continue; // No valid key
            
            if (c == '\n') {
                // Execute command
                command_buffer[command_pos] = '\0';
                vga_put_char('\n');
                process_command(command_buffer);
                break;
            } else if (c == '\b') {
                // Backspace
                if (command_pos > 0) {
                    command_pos--;
                    vga_put_char('\b');
                }
            } else if (command_pos < 255) {
                // Add character to command
                command_buffer[command_pos] = c;
                command_pos++;
                vga_put_char(c);
            }
        }
    }
}
