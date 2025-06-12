; Disk loading utilities

[bits 16]
disk_load:
    pusha
    push dx                     ; Store dx on stack
    
    mov ah, 0x02                ; BIOS read function
    mov al, dh                  ; Number of sectors to read
    mov cl, 0x02                ; Start from sector 2 (sector 1 is bootloader)
    mov ch, 0x00                ; Cylinder 0
    mov dh, 0x00                ; Head 0
    ; dl already contains drive number
    
    int 0x13                    ; BIOS interrupt
    jc disk_error               ; Jump if carry flag set (error)
    
    pop dx                      ; Restore dx
    cmp al, dh                  ; Check if correct number of sectors read
    jne sectors_error
    popa
    ret

disk_error:
    mov bx, DISK_ERROR
    call print_string
    call print_nl
    mov dh, ah                  ; ah = error code
    call print_hex
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print_string
    call print_nl

disk_loop:
    jmp $

print_hex:
    ; Print the value in dh as hex
    pusha
    mov cx, 0                   ; Index variable
hex_loop:
    cmp cx, 4                   ; Loop 4 times
    je end
    
    mov ax, dx                  ; Use ax as working register
    and ax, 0x000f              ; Mask first digit
    add al, 0x30                ; Add 0x30 to convert to ASCII
    cmp al, 0x39                ; Check if > 9
    jle step2
    add al, 7                   ; Add 7 to get ASCII A-F
    
step2:
    mov bx, HEX_OUT + 5         ; Base + length
    sub bx, cx                  ; Subtract index
    mov [bx], al                ; Copy ASCII char to string
    ror dx, 4                   ; Rotate right 4 bits
    
    add cx, 1
    jmp hex_loop

end:
    mov bx, HEX_OUT
    call print_string
    popa
    ret

; Data
DISK_ERROR      db "Disk read error", 0
SECTORS_ERROR   db "Incorrect number of sectors read", 0
HEX_OUT         db "0x0000", 0
