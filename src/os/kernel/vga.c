#include "vga.h"

// VGA text mode constants
#define VGA_MEMORY 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_ATTRIBUTE_BYTE 0x0F  // White text on black background

static char* vga_buffer = (char*)VGA_MEMORY;
static int vga_cursor_x = 0;
static int vga_cursor_y = 0;

void vga_clear_screen(void) {
    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i * 2] = ' ';
        vga_buffer[i * 2 + 1] = VGA_ATTRIBUTE_BYTE;
    }
    vga_cursor_x = 0;
    vga_cursor_y = 0;
}

void vga_put_char(char c) {
    if (c == '\n') {
        vga_cursor_x = 0;
        vga_cursor_y++;
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
    
    // Handle scrolling (simple implementation)
    if (vga_cursor_y >= VGA_HEIGHT) {
        vga_cursor_y = VGA_HEIGHT - 1;
        // Scroll screen up (simple clear for now)
        vga_clear_screen();
    }
}

void vga_print_string(const char* str) {
    while (*str) {
        vga_put_char(*str);
        str++;
    }
}

void vga_set_cursor_position(int x, int y) {
    if (x >= 0 && x < VGA_WIDTH && y >= 0 && y < VGA_HEIGHT) {
        vga_cursor_x = x;
        vga_cursor_y = y;
    }
}

void vga_get_cursor_position(int* x, int* y) {
    *x = vga_cursor_x;
    *y = vga_cursor_y;
}
