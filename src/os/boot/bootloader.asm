; GahiraiOS Bootloader
; A simple BIOS bootloader that loads our kernel

[org 0x7c00]                    ; BIOS loads us at 0x7c00

KERNEL_OFFSET equ 0x1000        ; Memory offset where we'll load the kernel

    mov [BOOT_DRIVE], dl        ; BIOS stores boot drive in DL
    
    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Print boot message using direct VGA write
    call print_boot_msg
    
    ; Skip kernel loading for now - we'll test just the bootloader
    ; call load_kernel
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $                       ; Infinite loop (should never reach here)

print_boot_msg:
    ; Write directly to VGA memory in 16-bit mode
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    
    mov si, MSG_REAL_MODE
.loop:
    lodsb                       ; Load byte from SI to AL
    cmp al, 0                   ; Check for null terminator
    je .done
    mov ah, 0x0f               ; White on black
    stosw                      ; Store to VGA memory
    jmp .loop
.done:
    ret

; Include utility functions
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
    ; Write directly to VGA memory
    mov edi, 0xb8000
    add edi, 160               ; Next line (80 chars * 2 bytes)
    
    mov esi, MSG_PROT_MODE
.loop:
    lodsb                      ; Load character
    cmp al, 0
    je .next_msg
    mov ah, 0x0f              ; White on black
    stosw                     ; Store to VGA
    jmp .loop
    
.next_msg:
    mov esi, MSG_SUCCESS
.loop2:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0f
    stosw
    jmp .loop2
    
.done:
    ; Infinite loop - we'll add kernel loading later
    jmp $

; Data
BOOT_DRIVE      db 0
MSG_REAL_MODE   db "Starting GahiraiOS...", 0
MSG_PROT_MODE   db "32-bit Protected Mode OK ", 0
MSG_SUCCESS     db "- Bootloader working!", 0
MSG_LOAD_KERNEL db "Loading kernel into memory...", 0

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55                       ; Boot signature
