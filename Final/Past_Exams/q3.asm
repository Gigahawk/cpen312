Wait:
    push psw        ; 3 cycles
    push acc        ; 3 cycles
    push AR0        ; 3 cycles
    mov a, R1       ; 1 cycle
    add a, R1       ; 1 cycle
    add a, #50      ; 2 cycles
    mov R0, a       ; 1 cycle
W1: djnz R0, W1     ; 3 cycles while looping, 2 cycles for last loop
    pop AR0         ; 3 cycles
    pop acc         ; 3 cycles
    pop psw         ; 3 cycles
    ret             ; 3 cycles
