#ifndef KERNEL_H
#define KERNEL_H

// Main kernel entry point
void kernel_main(void);

// Basic types
typedef unsigned int   uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char  uint8_t;
typedef signed int     int32_t;
typedef signed short   int16_t;
typedef signed char    int8_t;

// Boolean type
typedef enum {
    false = 0,
    true = 1
} bool;

// NULL definition
#define NULL ((void*)0)

// Kernel constants
#define KERNEL_VERSION_MAJOR 0
#define KERNEL_VERSION_MINOR 1
#define KERNEL_VERSION_PATCH 0

#endif // KERNEL_H
