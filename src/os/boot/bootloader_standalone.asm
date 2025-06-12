; GahiraiOS Bootloader - Self-contained version
; A simple BIOS bootloader that switches to protected mode

[org 0x7c00]                    ; BIOS loads us at 0x7c00

    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Print boot message using direct VGA write
    call print_boot_msg
    
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

[bits 16]
switch_to_pm:
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
    
    call BEGIN_PM              ; Jump to main 32-bit code

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
    ; Infinite loop
    jmp $

; GDT setup
gdt_start:
    ; Null descriptor (required)
    dd 0x0
    dd 0x0

; Code segment descriptor
gdt_code: 
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10011010b    ; Access byte: present=1, privilege=00, type=1, executable=1, direction=0, rw=1, accessed=0
    db 11001111b    ; Flags: granularity=1, size=1, 0, 0 + limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

; Data segment descriptor
gdt_data:
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10010010b    ; Access byte: present=1, privilege=00, type=1, executable=0, direction=0, rw=1, accessed=0
    db 11001111b    ; Flags: granularity=1, size=1, 0, 0 + limit (bits 16-19)
    db 0x0          ; Base (bits 24-31)

gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Start address of GDT

; Segment selector offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Data
MSG_REAL_MODE   db "Starting GahiraiOS...", 0
MSG_PROT_MODE   db "32-bit Protected Mode OK ", 0
MSG_SUCCESS     db "- Bootloader working!", 0

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55                       ; Boot signature
