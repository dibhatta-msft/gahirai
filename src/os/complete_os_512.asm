; Complete minimal OS in 512 bytes
; Bootloader + basic kernel combined

[org 0x7c00]
[bits 16]

start:
    ; Set up stack
    mov bp, 0x9000
    mov sp, bp
    
    ; Switch to protected mode immediately
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:protected_mode

[bits 32]
protected_mode:
    ; Set up segments
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ebp, 0x90000
    mov esp, ebp
    
    ; Initialize VGA and start OS
    call main

main:
    ; Clear screen
    call clear_screen
    
    ; Print welcome message
    mov esi, welcome_msg
    call print_string
    
    ; Print prompt
    mov esi, prompt
    call print_string
    
    ; Simple command loop
command_loop:
    call get_key
    
    cmp al, 'h'
    je show_help
    
    cmp al, 'c'
    je clear_cmd
    
    cmp al, 'r'
    je reboot_cmd
    
    ; Echo the character
    call put_char
    
    jmp command_loop

show_help:
    mov esi, help_msg
    call print_string
    jmp command_loop

clear_cmd:
    call clear_screen
    mov esi, welcome_msg
    call print_string
    mov esi, prompt
    call print_string
    jmp command_loop

reboot_cmd:
    mov esi, reboot_msg
    call print_string
    ; Reboot via keyboard controller
    mov al, 0xFE
    out 0x64, al
    jmp $

clear_screen:
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x0F20  ; White space on black
    rep stosw
    mov dword [cursor_pos], 0
    ret

print_string:
    pusha
.loop:
    lodsb
    cmp al, 0
    je .done
    call put_char
    jmp .loop
.done:
    popa
    ret

put_char:
    pusha
    mov edi, 0xB8000
    mov ecx, [cursor_pos]
    add edi, ecx
    
    cmp al, 10  ; newline
    je .newline
    
    mov ah, 0x0F  ; White on black
    stosw
    add dword [cursor_pos], 2
    jmp .done
    
.newline:
    mov eax, [cursor_pos]
    mov ebx, 160  ; 80 chars * 2 bytes
    xor edx, edx
    div ebx
    inc eax
    mul ebx
    mov [cursor_pos], eax
    
.done:
    popa
    ret

get_key:
    ; Simple polling keyboard input
.wait:
    in al, 0x64
    and al, 0x01
    jz .wait
    
    in al, 0x60
    
    ; Simple scancode to ASCII (just a few keys)
    cmp al, 0x23  ; h key
    je .h_key
    cmp al, 0x2E  ; c key  
    je .c_key
    cmp al, 0x13  ; r key
    je .r_key
    
    mov al, '?'  ; Unknown key
    ret
    
.h_key:
    mov al, 'h'
    ret
.c_key:
    mov al, 'c'
    ret
.r_key:
    mov al, 'r'
    ret

; GDT
gdt_start:
    dd 0, 0  ; Null descriptor

gdt_code:
    dw 0xFFFF, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00

gdt_data:
    dw 0xFFFF, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Data
cursor_pos dd 0

welcome_msg db 'GahiraiOS v1.0 - Minimal Interactive Shell', 10, 0
prompt db 'Commands: h=help, c=clear, r=reboot > ', 0
help_msg db 10, 'Available commands:', 10, 'h - Show this help', 10, 'c - Clear screen', 10, 'r - Reboot system', 10, 0
reboot_msg db 10, 'Rebooting...', 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
