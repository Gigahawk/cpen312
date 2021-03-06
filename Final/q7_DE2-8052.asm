$MODDE2

ljmp init

org 000BH
    lcall inc_ovf
    reti

org 40H
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

Init_counter_0:
    clr EA              ; Disable interrupts
    clr TR0             ; Stop counter 0
    ; Note: original question sets Timer 0 as a counter
    ; (mov TMOD, #05H), but I'm too lazy to attach an 
    ; external clock, the internal clock will have to do
    mov TMOD, #01H       ; Configure counter 0 in mode 1
    clr TF0             ; Clear overflow flag
    mov TH0, #0
    mov TL0, #0
    clr A
    mov R0, #ovf_count
    mov @R0, A          ; Clear overflow counter low
    inc R0
    mov @R0, A          ; Clear overflow counter high
    setb TR0            ; Start counter 0
    setb ET0            ; Enable counter 0 overflow interrupt
    setb EA             ; Enable global interrupts
    ret

sevenseg_lut:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H     ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H     ; 5 TO 9
    DB 088H, 08BH, 0C6H, 0A1H, 086H, 08EH ; A to F ( b is an h because reasons )
    DB 0FFH                             ; Blank

init:
    mov SP, #30H ; Stack pointer before ovf_count because tips should never touch
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    lcall Init_counter_0
    sjmp main

main:
	; Show value of ovf_count
	lcall disp
    sjmp main

disp:
    mov dptr, #sevenseg_lut
    mov R0, #ovf_count
    mov A, @R0
    anl A, #0FH
    movc A, @A+dptr
    mov HEX0, A
    mov A, @R0
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX1, A
    inc R0
    mov A, @R0
    anl A, #0FH
    movc A, @A+dptr
    mov HEX2, A
    mov A, @R0
    swap A
    anl A, #0FH
    movc A, @A+dptr
    mov HEX3, A
    ret

ISEG AT 07FH
ovf_count: ds 2
