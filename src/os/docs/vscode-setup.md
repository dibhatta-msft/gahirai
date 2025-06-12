# VS Code Configuration for GahiraiOS

## Recommended Extensions
- C/C++ (Microsoft)
- x86 and x86_64 Assembly
- Makefile Tools
- Hex Editor

## Debug Configuration
Add this to your `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug GahiraiOS",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/kernel.bin",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "integratedTerminal",
            "MIMode": "gdb",
            "miDebuggerPath": "/usr/bin/gdb",
            "miDebuggerServerAddress": "localhost:1234",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

## Usage
1. Run `make debug` to start QEMU with GDB server
2. Use F5 to start debugging in VS Code
3. Set breakpoints in kernel source files
