; Minimal bootloader - just infinite loop
[org 0x7c00]

jmp $                          ; Infinite loop

times 510-($-$$) db 0          ; Pad to 510 bytes
dw 0xaa55                      ; Boot signature
