; Minimal test bootloader - just switch to protected mode
[org 0x7c00]                    ; BIOS loads us at 0x7c00

    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Switch to 32-bit protected mode immediately
    cli                         ; Disable interrupts
    lgdt [gdt_descriptor]       ; Load GDT
    
    mov eax, cr0               ; Get control register 0
    or eax, 0x1                ; Set protected mode bit
    mov cr0, eax               ; Update control register
    
    jmp CODE_SEG:init_pm       ; Far jump to flush pipeline and set CS

[bits 32]
init_pm:
    ; Update segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Update stack pointer
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Write directly to VGA memory
    mov ebx, 0xb8000           ; VGA text memory
    mov al, 'O'                ; Character
    mov ah, 0x0f               ; White on black
    mov [ebx], ax
    mov al, 'K'
    mov [ebx+2], ax
    
    ; Infinite loop
    jmp $

; GDT setup (inline)
gdt_start:
    ; Null descriptor
    dd 0x0, 0x0
    
    ; Code segment descriptor
    dw 0xffff, 0x0             ; Limit, Base low
    db 0x0, 10011010b          ; Base mid, Access
    db 11001111b, 0x0          ; Flags+Limit high, Base high
    
    ; Data segment descriptor  
    dw 0xffff, 0x0             ; Limit, Base low
    db 0x0, 10010010b          ; Base mid, Access
    db 11001111b, 0x0          ; Flags+Limit high, Base high
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size
    dd gdt_start               ; Address

CODE_SEG equ 8
DATA_SEG equ 16

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55
