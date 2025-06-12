; Switch from 16-bit real mode to 32-bit protected mode

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
