#!/bin/bash

# GahiraiOS Setup Script
# Installs dependencies needed for OS development

echo "Setting up GahiraiOS development environment..."

# Update package list
echo "Updating package list..."
sudo apt update

# Install basic development tools
echo "Installing development tools..."
sudo apt install -y build-essential nasm qemu-system-x86 gdb curl wget

# Create build directory
mkdir -p build

echo "Checking for cross-compiler..."
if ! command -v i686-elf-gcc &> /dev/null; then
    echo "WARNING: i686-elf-gcc cross-compiler not found!"
    echo ""
    echo "You'll need to build the cross-compiler manually."
    echo "Follow the guide at: https://wiki.osdev.org/GCC_Cross-Compiler"
    echo ""
    echo "Quick setup:"
    echo "1. Download and extract binutils and GCC source"
    echo "2. Build binutils for i686-elf target"
    echo "3. Build GCC for i686-elf target"
    echo "4. Add the cross-compiler to your PATH"
    echo ""
    echo "Alternative: Use a pre-built cross-compiler or Docker image"
else
    echo "Cross-compiler found: $(which i686-elf-gcc)"
fi

echo "Checking QEMU installation..."
if command -v qemu-system-i386 &> /dev/null; then
    echo "QEMU found: $(which qemu-system-i386)"
else
    echo "ERROR: QEMU not installed!"
    exit 1
fi

echo ""
echo "Setup complete!"
echo "To build and run GahiraiOS:"
echo "  make all"
echo "  make run"
echo ""
echo "To debug:"
echo "  make debug"
echo "  # In another terminal:"
echo "  gdb"
echo "  (gdb) target remote localhost:1234"
