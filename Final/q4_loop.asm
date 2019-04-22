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
    setb C ; Add extra 1
    push PSW ; Don't underflow the stack
loop_zoop:
    pop PSW ; Preserve carry after CJNE
    mov A, #99H
    ; Addition and subtraction are commutative,
    ; but carrys must be added, so addc comes first
    addc A, @R0
    subb A, @R1
    da A
    movx @dptr, A ; Store answer
    ; Point stuff at next things
    inc R0
    inc R1
    inc dptr
    push PSW ; Preserve carry after CJNE
    cjne R0, #X+3, loop_zoop ; CJNE sets carry if R0 < #X+3
    pop PSW ; Don't need no Flex Seal here
    ret
