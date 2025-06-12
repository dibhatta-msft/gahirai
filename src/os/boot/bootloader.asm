; GahiraiOS Bootloader
; A simple BIOS bootloader that loads our kernel

[org 0x7c00]                    ; BIOS loads us at 0x7c00

KERNEL_OFFSET equ 0x1000        ; Memory offset where we'll load the kernel

    mov [BOOT_DRIVE], dl        ; BIOS stores boot drive in DL
    
    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Print boot message
    mov bx, MSG_REAL_MODE
    call print_string
    
    ; Load kernel from disk
    call load_kernel
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $                       ; Infinite loop (should never reach here)

; Include utility functions
%include "boot/print.asm"
%include "boot/disk.asm"
%include "boot/gdt.asm"
%include "boot/switch_pm.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string
    
    mov bx, KERNEL_OFFSET       ; Load kernel to this memory address
    mov dh, 2                   ; Load 2 sectors (after bootloader)
    mov dl, [BOOT_DRIVE]        ; Drive to load from
    call disk_load
    
    ret

[bits 32]
BEGIN_PM:
    ; Now in 32-bit protected mode
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    
    ; Jump to kernel
    call KERNEL_OFFSET
    
    jmp $                       ; Infinite loop

; Data
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Starting GahiraiOS...", 0
MSG_PROT_MODE   db "Switched to 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory...", 0

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55                       ; Boot signature
