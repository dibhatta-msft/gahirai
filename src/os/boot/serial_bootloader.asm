; GahiraiOS Bootloader - Serial output version for testing
; A simple BIOS bootloader that outputs to serial port

[org 0x7c00]                    ; BIOS loads us at 0x7c00

    ; Set up stack
    mov bp, 0x9000              ; Set stack base pointer
    mov sp, bp                  ; Set stack pointer
    
    ; Initialize serial port
    call init_serial
    
    ; Print boot message to serial
    mov si, MSG_REAL_MODE
    call print_serial
    
    ; Switch to 32-bit protected mode
    call switch_to_pm
    
    jmp $                       ; Infinite loop (should never reach here)

init_serial:
    mov dx, 0x3f8               ; COM1 port
    mov al, 0x00
    add dx, 1                   ; Interrupt enable register
    out dx, al                  ; Disable interrupts
    
    sub dx, 1                   ; Back to base port
    add dx, 3                   ; Line control register
    mov al, 0x80               ; Enable DLAB
    out dx, al
    
    sub dx, 3                   ; Divisor latch low
    mov al, 0x03               ; 38400 baud
    out dx, al
    
    add dx, 1                   ; Divisor latch high
    mov al, 0x00
    out dx, al
    
    add dx, 2                   ; Line control register
    mov al, 0x03               ; 8N1
    out dx, al
    
    add dx, 1                   ; FIFO control register
    mov al, 0xC7               ; Enable FIFO
    out dx, al
    
    add dx, 1                   ; Modem control register
    mov al, 0x0B               ; Enable DTR, RTS, OUT2
    out dx, al
    ret

print_serial:
    pusha
.loop:
    lodsb                       ; Load character from SI
    cmp al, 0                   ; Check for null terminator
    je .done
    call write_serial_char
    jmp .loop
.done:
    popa
    ret

write_serial_char:
    push dx
    mov dx, 0x3f8               ; COM1 port
    add dx, 5                   ; Line status register
.wait:
    in al, dx                   ; Read status
    and al, 0x20               ; Check if transmitter is ready
    jz .wait                    ; Wait until ready
    
    sub dx, 5                   ; Back to data register
    pop ax                      ; Get character back
    push ax
    out dx, al                  ; Send character
    pop ax
    pop dx
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
    ; Print success message to serial in 32-bit mode
    mov esi, MSG_PROT_MODE
    call print_serial_32
    
    mov esi, MSG_SUCCESS
    call print_serial_32
    
    ; Infinite loop
    jmp $

print_serial_32:
    pusha
.loop:
    lodsb                       ; Load character
    cmp al, 0
    je .done
    call write_serial_char_32
    jmp .loop
.done:
    popa
    ret

write_serial_char_32:
    push edx
    mov edx, 0x3f8             ; COM1 port
    add edx, 5                 ; Line status register
.wait:
    in al, dx                  ; Read status
    and al, 0x20              ; Check if transmitter is ready
    jz .wait                   ; Wait until ready
    
    sub edx, 5                 ; Back to data register
    pop eax                    ; Get character back
    push eax
    out dx, al                 ; Send character
    pop eax
    pop edx
    ret

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
    db 10011010b    ; Access byte
    db 11001111b    ; Flags
    db 0x0          ; Base (bits 24-31)

; Data segment descriptor
gdt_data:
    dw 0xffff       ; Limit (bits 0-15)
    dw 0x0          ; Base (bits 0-15)
    db 0x0          ; Base (bits 16-23)
    db 10010010b    ; Access byte
    db 11001111b    ; Flags
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
MSG_REAL_MODE   db "Starting GahiraiOS...", 13, 10, 0
MSG_PROT_MODE   db "32-bit Protected Mode OK", 13, 10, 0
MSG_SUCCESS     db "Bootloader working!", 13, 10, 0

; Pad bootloader to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xaa55                       ; Boot signature
