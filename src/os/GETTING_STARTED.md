# Getting Started with GahiraiOS

## Quick Start

1. **Test the bootloader:**
   ```bash
   make -f Makefile.simple run-simple
   ```

2. **Build and run the full OS:**
   ```bash
   make -f Makefile.simple all
   make -f Makefile.simple run
   ```

## Development Setup

### For Cross-Compiler Development
If you want to use the full i686-elf cross-compiler:

1. Install the cross-compiler following the [OSDev Guide](https://wiki.osdev.org/GCC_Cross-Compiler)
2. Use the main `Makefile`

### For Quick Development  
Use `Makefile.simple` which uses standard GCC with 32-bit flags.

## Project Features

### Current
- ✅ BIOS bootloader that loads from disk
- ✅ 16-bit to 32-bit protected mode transition
- ✅ Basic VGA text output
- ✅ Simple kernel structure

### Next Steps
- [ ] Interrupt handling (IDT)
- [ ] Keyboard input
- [ ] Memory management
- [ ] Process scheduling
- [ ] Simple shell

## Architecture Overview

```
Boot Process:
1. BIOS loads bootloader at 0x7c00
2. Bootloader sets up stack and GDT
3. Loads kernel from disk to 0x1000
4. Switches to 32-bit protected mode
5. Jumps to kernel entry point
6. Kernel initializes VGA and prints messages
```

## Debugging

1. Start QEMU with debugging:
   ```bash
   make -f Makefile.simple debug
   ```

2. In another terminal:
   ```bash
   gdb
   (gdb) target remote localhost:1234
   (gdb) continue
   ```

## Extending the OS

The codebase is designed to be educational and extensible:

- Add new drivers in `drivers/` directory
- Extend kernel functionality in `kernel/`  
- Add system calls and user programs
- Implement file systems and networking

Have fun building your operating system! 🚀
