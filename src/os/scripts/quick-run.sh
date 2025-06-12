#!/bin/bash

# Quick build and run script for development

echo "Building GahiraiOS..."
make clean
make all

if [ $? -eq 0 ]; then
    echo "Build successful! Starting QEMU..."
    make run
else
    echo "Build failed!"
    exit 1
fi
