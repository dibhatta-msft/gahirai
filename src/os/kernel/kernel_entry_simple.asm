; Kernel entry point - minimal version
[bits 32]
[extern kernel_main]            ; Declare external function

call kernel_main                ; Call main kernel function
jmp $                          ; Infinite loop if kernel returns
