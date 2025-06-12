; Test OS with visible graphics
[org 0x7c00]
[bits 16]

start:
    ; Set up stack
    mov bp, 0x9000
    mov sp, bp
    
    ; Clear screen with colored background
    mov ax, 0xb800
    mov es, ax
    xor di, di
    
    ; Fill screen with colored characters to make it visible
    mov cx, 80*25
    mov ax, 0x4741     ; White 'A' on red background
    rep stosw
    
    ; Write a clear message
    mov di, 160        ; Second line
    mov si, test_msg
    mov ah, 0x0F       ; White on black
    
write_msg:
    lodsb
    cmp al, 0
    je msg_done
    stosw
    jmp write_msg
    
msg_done:
    ; Switch to protected mode
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
    
    ; Clear screen and write message in 32-bit mode
    call clear_and_write
    
    ; Simple key detection loop
key_loop:
    in al, 0x64
    and al, 0x01
    jz key_loop
    
    in al, 0x60
    
    ; Flash screen when any key is pressed
    call flash_screen
    jmp key_loop

clear_and_write:
    ; Clear with blue background
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0x1720      ; White space on blue
    rep stosw
    
    ; Write visible message
    mov edi, 0xB8000
    mov esi, welcome_32
    
write_loop:
    lodsb
    cmp al, 0
    je write_done
    mov ah, 0x1F        ; White on blue
    stosw
    jmp write_loop
    
write_done:
    ret

flash_screen:
    ; Flash the screen white briefly when key pressed
    pusha
    mov edi, 0xB8000
    mov ecx, 80*25
    mov ax, 0xF020      ; Black space on white
    rep stosw
    
    ; Delay
    mov ecx, 0x100000
delay_loop:
    dec ecx
    jnz delay_loop
    
    ; Restore blue screen
    call clear_and_write
    popa
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

test_msg db 'GahiraiOS Loading...', 0
welcome_32 db 'GahiraiOS Interactive! Press any key to flash screen!', 0

times 510-($-$$) db 0
dw 0xAA55
