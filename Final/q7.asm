
org 000BH
    ljmp inc_ovf
    reti

inc_ovf:
    push ACC
    push PSW ; Carry flag is stored in PSW
    clr C
    mov A, ovf_count+0
    addc A, #1
    mov ovf_count+0, A
    mov A, ovf_count+1
    addc A, #0
    mov ovf_count+1, A
    pop PSW
    pop ACC
    ret

ISEG AT 07FH
ovf_count: ds 2
