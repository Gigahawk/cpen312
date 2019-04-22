    DSEG at 040H
X:  DS 3 ; six BCD digits for input X
Y:  DS 3 ; six BCD digits for input Y
    XSEG at 4000H
Z:  DS 3 ; six BCD digits for result Z

CSEG
six_dig_sub:
    ; Point stuff at things
    mov R0, #X
    mov R1, #Y
    mov dptr, #Z
    mov R2, #3
    setb C ; Add extra 1
loop_zoop:
    mov A, #99H
    addc A, #0 ; Add and clear carry
    subb A, @R1
    addc A, @R0
    da A
    movx @dptr, A ; Store answer
    ; Point stuff at next things
    inc R0
    inc R1
    inc dptr
    djnz R2, loop_zoop
    ret
