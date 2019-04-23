DSEG at 40H
; DSW is only supported in Ax51, not A51
;DSW 8
DS 16
CSEG

avg_8_wrds:
    mov dptr, #0
    mov B, #0
    mov R0, #0x40
    mov R1, #8
add_loop:
    mov A, DPL
    add A, @R0
    mov DPL, A  ; DPL += low_byte
    inc R0
    mov A, DPH
    addc A, @R0
    mov DPH, A  ; DPH += high_byte
    inc R0
    jnc no_carry
    inc B       ; Put carry overflow into B
no_carry:
    djnz R1, add_loop

    mov R1, #3
div_loop:
    clr C
    mov A, B
    rrc A
    mov B, A
    mov A, DPH
    rrc A
    mov DPH, A
    mov A, DPL
    rrc A
    mov DPL, A
    djnz R1, div_loop
    ret

