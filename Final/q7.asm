
org 000BH
    lcall inc_ovf
    reti

inc_ovf:
    ; Carry flag is stored in PSW
    ; Also, PSW should be popped first to maintain parity
    ; (Unlikely to be a big deal but no real reason to not)
    push PSW
    push ACC
    push AR0
    clr C
    mov R0, #ovf_count
    mov A, @R0
    addc A, #1
    mov @R0, A
    inc R0
    mov A, @R0
    addc A, #0
    mov @R0, A
    pop AR0
    pop ACC
    pop PSW
    ret

ISEG AT 07FH
ovf_count: ds 2
