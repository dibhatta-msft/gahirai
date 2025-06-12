; Complete minimal OS with serial output for headless testing
[org 0x7c00]
[bits 16]

start:
    ; Set up stack
    mov bp, 0x9000
    mov sp, bp
    
    ; Initialize serial port first
    call init_serial
    
    ; Send boot message to serial
    mov si, boot_msg
    call print_serial_16
    
    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:protected_mode

init_serial:
    mov dx, 0x3f8               ; COM1
    mov al, 0x00
    add dx, 1
    out dx, al                  ; Disable interrupts
    
    sub dx, 1
    add dx, 3
    mov al, 0x80
    out dx, al                  ; Enable DLAB
    
    sub dx, 3
    mov al, 0x03
    out dx, al                  ; 38400 baud low
    
    add dx, 1
    mov al, 0x00
    out dx, al                  ; 38400 baud high
    
    add dx, 2
    mov al, 0x03
    out dx, al                  ; 8N1
    
    add dx, 1
    mov al, 0xC7
    out dx, al                  ; Enable FIFO
    
    add dx, 1
    mov al, 0x0B
    out dx, al                  ; Enable DTR, RTS, OUT2
    ret

print_serial_16:
    pusha
.loop:
    lodsb
    cmp al, 0
    je .done
    call write_serial_16
    jmp .loop
.done:
    popa
    ret

write_serial_16:
    push dx
    mov dx, 0x3f8
    add dx, 5
.wait:
    in al, dx
    and al, 0x20
    jz .wait
    
    sub dx, 5
    pop ax
    push ax
    out dx, al
    pop ax
    pop dx
    ret

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
    
    ; Send ready message to serial
    mov esi, ready_msg
    call print_serial_32
    
    ; Initialize VGA and start OS
    call main

main:
    ; Clear screen
    call clear_screen
    
    ; Print welcome message to both VGA and serial
    mov esi, welcome_msg
    call print_both
    
    ; Print instructions to serial
    mov esi, instructions
    call print_serial_32
    
    ; Print prompt
    mov esi, prompt
    call print_both
    
    ; Simple command loop with serial feedback
command_loop:
    mov esi, waiting_msg
    call print_serial_32
    
    call get_key
    
    ; Send received key to serial for debugging
    mov esi, received_msg
    call print_serial_32
    push eax
    call print_hex_serial
    pop eax
    mov esi, newline
    call print_serial_32
    
    cmp al, 'h'
    je show_help
    
    cmp al, 'c'
    je clear_cmd
    
    cmp al, 'r'
    je reboot_cmd
    
    ; Echo the character to both
    call put_char
    push eax
    call put_char_serial
    pop eax
    
    jmp command_loop

show_help:
    mov esi, help_msg
    call print_both
    jmp command_loop

clear_cmd:
    call clear_screen
    mov esi, welcome_msg
    call print_both
    mov esi, prompt
    call print_both
    jmp command_loop

reboot_cmd:
    mov esi, reboot_msg
    call print_both
    ; Reboot via keyboard controller
    mov al, 0xFE
    out 0x64, al
    jmp $

print_both:
    ; Print to both VGA and serial
    pusha
    call print_string  ; VGA
    popa
    call print_serial_32  ; Serial
    ret

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

print_serial_32:
    pusha
.loop:
    lodsb
    cmp al, 0
    je .done
    call put_char_serial
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

put_char_serial:
    push edx
    mov edx, 0x3f8
    add edx, 5
.wait:
    in al, dx
    and al, 0x20
    jz .wait
    
    sub edx, 5
    out dx, al
    pop edx
    ret

print_hex_serial:
    push eax
    push eax
    shr eax, 4
    and eax, 0xF
    add al, '0'
    cmp al, '9'
    jle .first_digit
    add al, 7
.first_digit:
    call put_char_serial
    
    pop eax
    and eax, 0xF
    add al, '0'
    cmp al, '9'
    jle .second_digit
    add al, 7
.second_digit:
    call put_char_serial
    pop eax
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

boot_msg db 'GahiraiOS: Booting...', 13, 10, 0
ready_msg db 'GahiraiOS: Protected mode ready!', 13, 10, 0
welcome_msg db 'GahiraiOS v1.0 - Interactive Shell', 10, 0
instructions db 'INSTRUCTIONS: Press h, c, or r keys on your keyboard', 13, 10, 0
prompt db 'Commands: h=help, c=clear, r=reboot > ', 0
help_msg db 10, 'Available commands:', 10, 'h - Show this help', 10, 'c - Clear screen', 10, 'r - Reboot system', 10, 0
reboot_msg db 10, 'Rebooting...', 10, 0
waiting_msg db 'Waiting for key press...', 13, 10, 0
received_msg db 'Received scancode: 0x', 0
newline db 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
