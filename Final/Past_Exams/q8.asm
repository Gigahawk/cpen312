$MODDE2

org 000BH
    ljmp isr_T0

isr_T0:
    ; Carry flag is stored in PSW
    ; Also, PSW should be popped first to maintain parity
    ; (Unlikely to be a big deal but no real reason to not)
    clr TR0
    mov TH0, #high(1000H)
    mov TL0, #low(1000H)
    push PSW
    push ACC
    mov A, P0
    add A, P1
    mov P3, A
    pop ACC
    pop PSW
    reti
