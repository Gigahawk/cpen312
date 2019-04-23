$MODDE2

org 000BH
    ljmp isr_T0

isr_T0:
    ; Note: stopping the clock while we reset will slightly increase
    ; the interval between interrupts.
    ; Whether or not this is acceptable largely depends on the specific
    ; application and whether the timer reset value takes this into account.
    clr TR0
    mov TH0, #high(1000H)
    mov TL0, #low(1000H)
    clr TF0
    ; Starting the timer here will shorten the timer interval
    ; (i.e. shorten the time that the timer is stopped).
    ; For timing critical applications this line may have to be moved
    setb TR0
    push PSW
    push ACC
    mov A, P0
    add A, P1
    mov P3, A
    pop ACC
    pop PSW
    reti
