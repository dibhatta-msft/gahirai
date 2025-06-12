; Global Descriptor Table setup

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
