# Build configuration
AS = nasm
CC = i686-elf-gcc
LD = i686-elf-ld
OBJCOPY = objcopy

# Directories
BOOT_DIR = boot
KERNEL_DIR = kernel
DRIVERS_DIR = drivers
INCLUDE_DIR = include
BUILD_DIR = build
TOOLS_DIR = tools

# Flags
ASFLAGS = -f bin
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra -I$(INCLUDE_DIR)
LDFLAGS = -T $(KERNEL_DIR)/linker.ld -nostdlib -lgcc

# Files
BOOTLOADER = $(BUILD_DIR)/bootloader.bin
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
OS_IMAGE = $(BUILD_DIR)/gahiraios.img

# Source files
BOOT_SRC = $(BOOT_DIR)/bootloader.asm
KERNEL_ASM_SRC = $(KERNEL_DIR)/kernel_entry.asm
KERNEL_C_SRC = $(wildcard $(KERNEL_DIR)/*.c)
KERNEL_OBJ = $(BUILD_DIR)/kernel_entry.o $(KERNEL_C_SRC:$(KERNEL_DIR)/%.c=$(BUILD_DIR)/%.o)

.PHONY: all clean run debug setup

all: setup $(OS_IMAGE)

setup:
	@mkdir -p $(BUILD_DIR)

# Build bootloader
$(BOOTLOADER): $(BOOT_SRC)
	$(AS) $(ASFLAGS) $< -o $@

# Build kernel entry point
$(BUILD_DIR)/kernel_entry.o: $(KERNEL_ASM_SRC)
	$(AS) -f elf32 $< -o $@

# Build kernel C files
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# Create OS image
$(OS_IMAGE): $(BOOTLOADER) $(KERNEL_BIN)
	@echo "Creating OS image..."
	@dd if=/dev/zero of=$@ bs=512 count=2880 2>/dev/null
	@dd if=$(BOOTLOADER) of=$@ conv=notrunc 2>/dev/null
	@dd if=$(KERNEL_BIN) of=$@ seek=1 conv=notrunc 2>/dev/null

# Run in QEMU
run: $(OS_IMAGE)
	qemu-system-i386 -fda $(OS_IMAGE)

# Debug with QEMU
debug: $(OS_IMAGE)
	qemu-system-i386 -fda $(OS_IMAGE) -gdb tcp::1234 -S

# Install cross-compiler (Ubuntu/Debian)
install-deps:
	@echo "Installing dependencies..."
	sudo apt update
	sudo apt install -y build-essential nasm qemu-system-x86 gdb
	@echo "Note: You may need to build i686-elf-gcc cross-compiler manually"
	@echo "See: https://wiki.osdev.org/GCC_Cross-Compiler"

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Help
help:
	@echo "GahiraiOS Build System"
	@echo "Available targets:"
	@echo "  all         - Build the complete OS image"
	@echo "  run         - Run OS in QEMU"
	@echo "  debug       - Run OS in QEMU with debugging"
	@echo "  clean       - Clean build files"
	@echo "  install-deps- Install system dependencies"
	@echo "  help        - Show this help"
