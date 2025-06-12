; Print utilities for bootloader

[bits 16]
print_string:
    pusha
    mov ah, 0x0e                ; BIOS teletype function
.loop:
    mov al, [bx]                ; Get character
    cmp al, 0                   ; Check for null terminator
    je .done
    int 0x10                    ; BIOS interrupt
    inc bx                      ; Next character
    jmp .loop
.done:
    popa
    ret

print_nl:
    pusha
    mov ah, 0x0e
    mov al, 0x0a                ; Newline
    int 0x10
    mov al, 0x0d                ; Carriage return
    int 0x10
    popa
    ret

[bits 32]
; Constants for 32-bit mode printing
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY
.loop:
    mov al, [ebx]               ; Get character
    mov ah, WHITE_ON_BLACK      ; Attribute
    cmp al, 0                   ; Check for null terminator
    je .done
    mov [edx], ax               ; Write to video memory
    add ebx, 1                  ; Next character
    add edx, 2                  ; Next video memory position
    jmp .loop
.done:
    popa
    ret
