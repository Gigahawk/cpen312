$MODDE2

TIMER_MIN_HIGH EQU #76
TIMER_MIN_LOW EQU #01
; Should take 20 timer counts to wait 1s but it seems
; as if Jesus made the timer run twice as fast
TIMER_COUNTS EQU #40

MICROTRANSACTIONS EQU EA

ljmp init

org 000BH ; Timer 0 Interrupt Address
    ljmp isr_handler

org 40H
isr_handler:
    ; Preserve value of accumulator
    mov R7, A
    lcall reset_timer_val
    dec B
    mov A, B
    jz timer_finish
    mov A, R7
    reti
timer_finish:
    lcall reset_timer_count
    ; Set display update bit
    setb 30H
    ; Restore value in accumulator
    mov A, R7
    reti

init:
    mov SP, #7FH
    ; Turn off all LEDs
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    ; Enable interrupts
    SETB MICROTRANSACTIONS
    ; Enable Timer 0 ISR
    SETB ET0
    ; Initialize Timer
    lcall reset_timer_val
    lcall reset_timer_count
    ; Set timer mode 1 (16-bit mode)
    mov TMOD, #01h
    ; Start Timer 0
    setb TR0

    mov 20H, #0
    sjmp main


main:
    ; Mask KEY3 into accumulator
    mov A, KEY
    anl A, #1000b
    ; Clear button pressed flag if button is no longer pressed
    lcall check_btn_flag
    ; Check for falling edge of button
    orl A, 20H
    anl A, #1001b
    ; Jump to selector if first time pressing button
    jz select
    jb 30H, run_update
    sjmp main

check_btn_flag:
    jz pressed
    mov 20H, #0
pressed:
    ret

; Jump to last picked animation routine
run_update:
    clr 30H
    mov dptr, #0
    mov A, R6
    jmp @A+dptr

select:
    mov A, SWA
    anl A, #00000111b

    ; Reset animation state
    mov R2, #0

    ; Set button pressed flag
    mov 20H, #1

    ; 000
    mov R6, #six_msd
    jz six_msd

    ; 001
    dec A
    mov R6, #two_lsd
    jz two_lsd

    ; 010
    dec A
    mov R6, #rot_left
    jz rot_left

    ; 011
    dec A
    mov R6, #rot_right
    jz rot_right

    ; 100
    dec A
    mov R6, #blink_lsd
    jz blink_lsd

    ; 101
    dec A
    mov R6, #inc_disp
    jz inc_disp

    ; 110
    dec A
    mov R6, #hello_cpen
    jz hello_cpen

    ; 111
    dec A
    mov R6, #unique
    jz unique

    ; Jump back to main just in case
    sjmp main

; Display the six most significant digits of your student number
; using HEX5 down to HEX0
six_msd:
    lcall six_msd_logic
    ljmp main

; Display the two least significant digits of your student number
; using HEX1 and HEX0. Keep HEX5 down to HEX2 blank.
two_lsd:
    lcall two_lsd_logic
    ljmp main

; Starting with the six most significant digits of your student
; number, scroll one digit to the left every second.  This should
; keep going forever until the selection for SW2 down to SW0 is changed
rot_left:
    lcall rot_left_logic
    ljmp main

; Starting with the six most significant digits of your student
; number, scroll the digits of your student number one digit to the
; right every second. This should keep going forever until the
; selection for SW2 down to SW0 is changed.
rot_right:
    lcall rot_right_logic
    ljmp main

; Make the six least significant digits of your student number blink
; every second.  This should keep going forever until the selection
; for SW2 down to SW0 is changed.
blink_lsd:
    lcall blink_lsd_logic
    ljmp main

; Make the six most significant digits of your student number appear
; one at time every second, starting with a blank display.  This
; should keep going forever until the selection for SW2 down to SW0
; is changed.
inc_disp:
    lcall inc_disp_logic
    ljmp main

; Display “HELLO ” for one second, then the six most significant
; digits of your student number for one second (for example “123456”),
; followed by “CPN312” for one second. This should keep going forever
; until the selection for SW2 down to SW0 is changed.
hello_cpen:
    lcall hello_cpen_logic
    ljmp main

; Display your student number (or part of it) using a format of your
; own creation that is different from any of the formats required above.

; I've chosen to utilize the extra hex display's to display my full
; student number
unique:
    lcall unique_logic
    ljmp main

; PARAMS:
; %0: n'th digit of student number (LSD is 0, 8 to blank)
; %1: n'th HEX display
WRITE_DISP MAC
    mov dptr, #student_number
    mov A, %0
    movc A, @A+dptr
    mov dptr, #sevenseg_lut
    movc A, @A+dptr
    mov HEX%1, A
ENDMAC

WRITE_HELLO MAC
    mov dptr, #sevenseg_hello_lut
    mov A, #0
    movc A, @A+dptr
    mov HEX5, A
    mov A, #1
    movc A, @A+dptr
    mov HEX4, A
    mov A, #2
    movc A, @A+dptr
    mov HEX3, A
    mov HEX2, A
    mov dptr, #sevenseg_lut
    mov A, #0
    movc A, @A+dptr
    mov HEX1, A
    mov A, #10
    movc A, @A+dptr
    mov HEX0, A
ENDMAC

WRITE_CPEN MAC
    mov dptr, #sevenseg_cpen_lut
    mov A, #0
    movc A, @A+dptr
    mov HEX5, A
    mov A, #1
    movc A, @A+dptr
    mov HEX4, A
    mov A, #2
    movc A, @A+dptr
    mov HEX3, A
    mov dptr, #sevenseg_lut
    mov A, #3
    movc A, @A+dptr
    mov HEX2, A
    mov A, #1
    movc A, @A+dptr
    mov HEX1, A
    mov A, #2
    movc A, @A+dptr
    mov HEX0, A
ENDMAC

WRITE_MSD MAC
    WRITE_DISP(#7, 5)
    WRITE_DISP(#6, 4)
    WRITE_DISP(#5, 3)
    WRITE_DISP(#4, 2)
    WRITE_DISP(#3, 1)
    WRITE_DISP(#2, 0)
ENDMAC

WRITE_LSD MAC
    WRITE_DISP(#5, 5)
    WRITE_DISP(#4, 4)
    WRITE_DISP(#3, 3)
    WRITE_DISP(#2, 2)
    WRITE_DISP(#1, 1)
    WRITE_DISP(#0, 0)
ENDMAC

CLR_AUX MAC
    WRITE_DISP(#8, 7)
    WRITE_DISP(#8, 6)
ENDMAC

CLR_DISP MAC
    WRITE_DISP(#8, 5)
    WRITE_DISP(#8, 4)
    WRITE_DISP(#8, 3)
    WRITE_DISP(#8, 2)
    WRITE_DISP(#8, 1)
    WRITE_DISP(#8, 0)
ENDMAC


six_msd_logic:
    CLR_AUX
    WRITE_MSD
    ret

two_lsd_logic:
    WRITE_DISP(#8, 7)
    WRITE_DISP(#8, 6)
    WRITE_DISP(#8, 5)
    WRITE_DISP(#8, 4)
    WRITE_DISP(#8, 3)
    WRITE_DISP(#8, 2)
    WRITE_DISP(#1, 1)
    WRITE_DISP(#0, 0)
    ret

rot_left_logic:
    CLR_AUX
    mov A, #7
    ; Don't subtract carry bit
    clr C
    subb A, R2
    mov R4, A
    WRITE_DISP(R4, 5)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 4)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 3)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 2)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 1)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 0)
    inc R2
    lcall rot_left_constrain_cntr
    ret

rot_left_constrain_cntr:
    ; Check if counter (R2) is in a valid state
    cjne R2, #8, rot_left_cntr_no_constrain
    mov R2, #0
rot_left_cntr_no_constrain:
    ret

rot_right_logic:
    CLR_AUX
    mov A, #7
    ; Don't subtract carry bit
    clr C
    subb A, R2
    mov R4, A
    WRITE_DISP(R4, 5)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 4)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 3)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 2)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 1)
    dec R4
    lcall rot_constrain
    WRITE_DISP(R4, 0)
    dec R2
    lcall rot_right_constrain_cntr
    ret

rot_right_constrain_cntr:
    ; Check if counter (R2) is in a valid state
    cjne R2, #0FFH, rot_left_cntr_no_constrain
    mov R2, #7
rot_right_cntr_no_constrain:
    ret
    
rot_constrain:
    ; Check if R4 is pointing outside valid digit indices
    cjne R4, #0FFH, rot_no_constrain
    mov R4, #7
rot_no_constrain:
    ret

blink_lsd_logic:
    CLR_AUX
    mov A, R2
    anl A, #1b
    inc R2
    jz blink_show
    CLR_DISP
    ret
blink_show:
    WRITE_LSD
    ret

inc_disp_logic:
    CLR_AUX
    mov A, R2
    inc R2
    jz inc_clr
    dec A
    jz inc_draw_1
    dec A
    jz inc_draw_2
    dec A
    jz inc_draw_3
    dec A
    jz inc_draw_4
    dec A
    jz inc_draw_5
    mov R2, #0
    sjmp inc_draw_6
inc_draw_1:
    WRITE_DISP(#7, 5)
    ret
inc_draw_2:
    WRITE_DISP(#6, 4)
    ret
inc_draw_3:
    WRITE_DISP(#5, 3)
    ret
inc_draw_4:
    WRITE_DISP(#4, 2)
    ret
inc_draw_5:
    WRITE_DISP(#3, 1)
    ret
inc_draw_6:
    WRITE_DISP(#2, 0)
    ret
inc_clr:
    CLR_DISP
    ret

hello_cpen_logic:
    CLR_AUX
    mov A, R2
    inc R2
    jz hello_cpen_hello
    dec A
    jz hello_cpen_stuno
    mov R2, #0
    sjmp hello_cpen_cpen
hello_cpen_hello:
    WRITE_HELLO
    ret
hello_cpen_stuno:
    WRITE_MSD
    ret
hello_cpen_cpen:
    WRITE_CPEN
    ret

unique_logic:
    WRITE_DISP(#7, 7)
    WRITE_DISP(#6, 6)
    WRITE_LSD
    ret

reset_timer_val:
    clr TF0
    mov TH0, TIMER_MIN_HIGH
    mov TL0, TIMER_MIN_LOW
    ret

reset_timer_count:
    mov B, TIMER_COUNTS
    ret

sevenseg_lut:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H     ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H     ; 5 TO 9
    DB 0FFH                             ; Blank

sevenseg_hello_lut:
    DB 089H, 086H, 0C7H     ; HEL

WRITE_LSD
sevenseg_cpen_lut:
    DB 0C6H, 08CH, 0C8H     ; CPN

student_number:
    DB 4, 6, 1, 7, 6, 4, 7, 3, 10

