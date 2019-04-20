
org 000BH
    ljmp inc_ovf
    reti

inc_ovf:
    ; Carry flag is stored in PSW
    ; Also, PSW should be popped first to maintain parity
    ; (Unlikely to be a big deal but no real reason to not)
    push PSW
    push ACC
    clr C
    mov A, ovf_count+0
    addc A, #1
    mov ovf_count+0, A
    mov A, ovf_count+1
    addc A, #0
    mov ovf_count+1, A
    pop ACC
    pop PSW
    ret

ISEG AT 07FH
ovf_count: ds 2
