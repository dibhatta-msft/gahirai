<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# GahiraiOS Copilot Instructions

This is an operating system development project written primarily in C and x86 assembly. When working on this codebase:

## Code Style & Architecture
- Follow kernel development best practices
- Use minimal, efficient code suitable for kernel space
- Avoid standard library functions (we're in kernel space)
- Use direct hardware manipulation where needed
- Keep functions small and focused
- Use proper error handling and validation

## Memory Management
- Be extremely careful with memory access
- Validate pointers before dereferencing
- Use explicit memory addresses for hardware interaction
- Avoid buffer overflows and memory leaks

## Assembly Code
- Use NASM syntax for assembly files
- Include clear comments explaining hardware interactions
- Follow x86 calling conventions
- Use proper segment selectors in protected mode

## Hardware Programming
- Direct VGA memory manipulation for display
- BIOS interrupts in real mode
- Port I/O for device communication
- Interrupt handling and CPU state management

## Build System
- Use the provided Makefile for all builds
- Cross-compilation targeting i686-elf
- Separate bootloader and kernel builds
- Generate floppy disk images for QEMU

## Testing & Debugging
- Test with QEMU emulator
- Use GDB for kernel debugging
- Verify boot process works correctly
- Test on real hardware when appropriate

## Safety Considerations
- This code runs in kernel mode with full system access
- Always validate input parameters
- Handle edge cases gracefully
- Use defensive programming practices
