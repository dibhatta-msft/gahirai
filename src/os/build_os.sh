# Quick Build and Test Script
#!/bin/bash

echo "Building GahiraiOS..."
nasm -f bin complete_os_512.asm -o build/usable_os.img

if [ $? -eq 0 ]; then
    echo "✅ Build successful! OS image: build/usable_os.img (512 bytes)"
    echo ""
    echo "To test locally with GUI:"
    echo "  qemu-system-i386 -fda build/usable_os.img"
    echo ""
    echo "To test in headless mode (limited interaction):"
    echo "  qemu-system-i386 -fda build/usable_os.img -nographic -monitor none"
    echo ""
    echo "Commands in the OS:"
    echo "  h - Help"
    echo "  c - Clear screen"
    echo "  r - Reboot"
else
    echo "❌ Build failed!"
    exit 1
fi
