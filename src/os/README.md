# GahiraiOS - A Toy Operating System

A learning-focused operating system built from scratch to explore OS fundamentals.

## Features (Current/Planned)
- [x] Basic bootloader
- [x] Minimal kernel with VGA text output
- [ ] Interrupt handling
- [ ] Memory management
- [ ] Process scheduling
- [ ] File system
- [ ] Device drivers

## Building and Running

### Prerequisites
- GCC cross-compiler for i686-elf
- NASM assembler
- QEMU emulator
- Make

### Build
```bash
make all
```

### Run in QEMU
```bash
make run
```

### Debug
```bash
make debug
```

## Project Structure
```
.
├── boot/           # Bootloader code
├── kernel/         # Kernel source code
├── drivers/        # Device drivers
├── include/        # Header files
├── scripts/        # Build scripts
├── tools/          # Development tools
└── build/          # Build output
```

## Architecture
- **Target**: x86 (32-bit)
- **Bootloader**: Custom BIOS bootloader
- **Kernel**: Monolithic kernel in C
- **Memory Model**: Flat memory model

## Learning Resources
This project is designed for educational purposes. Key concepts covered:
- Bootloader development
- Kernel initialization
- Hardware abstraction
- Memory management
- Process management
- I/O operations

## Contributing
This is a learning project. Feel free to experiment and add features!
