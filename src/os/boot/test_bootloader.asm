; Test bootloader - just switch to protected mode without loading kernel
[org 0x7c00]                    ; BIOS loads us at 0x7c00

    mov [BOOT_DRIVE], dl        ; BIOS stores boot drive in DL
    
    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Print boot message
    mov bx, MSG_REAL_MODE
    call print_string
    
    ; Skip kernel loading for now
    ; call load_kernel
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $                       ; Infinite loop (should never reach here)

; Include utility functions
%include "boot/print.asm"
%include "boot/gdt.asm"
%include "boot/switch_pm.asm"

[bits 32]
BEGIN_PM:
    ; Now in 32-bit protected mode
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    ; Test message in protected mode
    mov ebx, MSG_SUCCESS
    call print_string_pm
    
    jmp $                       ; Infinite loop

; Data
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Starting GahiraiOS Test...", 0
MSG_PROT_MODE   db "Switched to 32-bit Protected Mode", 0
MSG_SUCCESS     db " - Success!", 0

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55                       ; Boot signature
