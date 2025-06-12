#ifndef KERNEL_SIMPLE_H
#define KERNEL_SIMPLE_H

// VGA functions
void vga_clear_screen(void);
void vga_put_char(char c);
void vga_print_string(const char* str);
void vga_print_hex(unsigned int value);

// Keyboard functions
void keyboard_init(void);
char keyboard_get_char(void);

// System functions
void kernel_main(void);

#endif
