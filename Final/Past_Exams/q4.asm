DSEG at 40H
M:  DS 8
S:  DS 8
R:  DS 8

CSEG
richardstallminus:
    ; Cant really push the stack pointer
    ; to preserve it
    mov R7, SP
    mov SP, #(R-1)
    mov R0, #M
    mov R1, #S
    mov R2, #8
    clr C
loop_zoop:
    mov A, @R0
    subb A, @R1
    push ACC
    inc R0
    inc R1
    djnz R2, loop_zoop
    mov SP, R7
    ret



