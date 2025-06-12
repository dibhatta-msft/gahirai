; Simple working bootloader
[org 0x7c00]

    ; Set up stack
    mov bp, 0x9000
    mov sp, bp
    
    ; Write directly to VGA in 16-bit mode
    mov ax, 0xb800      ; VGA text segment
    mov es, ax
    mov di, 0           ; Offset 0
    
    mov al, 'H'         ; Character
    mov ah, 0x0f        ; White on black
    stosw               ; Store to ES:DI and increment DI
    
    mov al, 'i'
    stosw
    
    mov al, '!'
    stosw
    
    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:pm_mode

[bits 32]
pm_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Write OK to VGA in 32-bit mode  
    mov edi, 0xb8000
    add edi, 160        ; Next line
    mov al, 'O'
    mov ah, 0x0f
    stosd
    mov al, 'K'
    stosd
    
    jmp $

; GDT
gdt_start:
    dd 0x0, 0x0         ; Null descriptor
    
    ; Code segment
    dw 0xffff, 0x0
    db 0x0, 10011010b
    db 11001111b, 0x0
    
    ; Data segment
    dw 0xffff, 0x0
    db 0x0, 10010010b
    db 11001111b, 0x0
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 8
DATA_SEG equ 16

times 510-($-$$) db 0
dw 0xaa55
