; GahiraiOS Bootloader - Loads kernel and starts OS
[org 0x7c00]

KERNEL_OFFSET equ 0x1000        ; Where to load kernel

    ; Set up stack
    mov bp, 0x9000
    mov sp, bp
    
    ; Save boot drive
    mov [BOOT_DRIVE], dl
    
    ; Load kernel from disk
    mov bx, KERNEL_OFFSET       ; Load to this address
    mov dh, 10                  ; Load 10 sectors (enough for our kernel)
    mov dl, [BOOT_DRIVE]
    call disk_load
    
    ; Switch to protected mode
    call switch_to_pm
    
    jmp $

; Simple disk loading function
disk_load:
    pusha
    push dx
    
    mov ah, 0x02                ; BIOS read function
    mov al, dh                  ; Number of sectors
    mov cl, 0x02                ; Start from sector 2
    mov ch, 0x00                ; Cylinder 0
    mov dh, 0x00                ; Head 0
    
    int 0x13                    ; BIOS disk interrupt
    jc disk_error               ; Jump on error
    
    pop dx
    popa
    ret

disk_error:
    ; Simple error handling - just halt
    jmp $

; Protected mode switch
switch_to_pm:
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_pm

[bits 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Jump to kernel
    jmp KERNEL_OFFSET

; GDT
gdt_start:
    dd 0x0, 0x0                 ; Null descriptor
    
gdt_code:
    dw 0xffff, 0x0              ; Code segment
    db 0x0, 10011010b
    db 11001111b, 0x0
    
gdt_data:
    dw 0xffff, 0x0              ; Data segment  
    db 0x0, 10010010b
    db 11001111b, 0x0
    
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xaa55
