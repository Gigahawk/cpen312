$MODDE0CV
org 0000H
   ljmp mp

DSEG at 30H
rx: ds 3

FREQ    EQU 33333333                ; 33.333333 MHz
BAUD    EQU 115200                  ; Baud rate
T2LOAD  EQU 65536- (FREQ/(32*BAUD)) ; Timer reset value for clock generation

CSEG
isp: 
    clr TR2                     ; Stop Timer 2
    mov T2CON #30H              ; Use internal timers for serial communication
    mov R2CAP2H, #high(T2LOAD)  ; Load timer reset value
    mov R2CAP2L, #low(T2LOAD)   ; Load timer reset value
    setb TR2                    ; Start Timer 2
    mov SCON, #52H              ; Initialize serial port (shift register mode, receive only)

get:
    jnb RI, $                   ; Wait for serial receive interrupt
    clr RI                      ; RI must be cleared by program
    mov @R0, SBUF               ; Copy serial buffer to rx
    inc R0                      ; Point to next location of rx
    ret

mp:
    mov SP, #7FH                ; Initialize stack
    mov R0, #rx                 ; Point R0 to rx
    lcall isp                   ; Initialize serial port
    lcall get                   ; Get byte from serial port
    lcall get                   ; Get byte from serial port
    lcall get                   ; Get byte from serial port
    sjmp $                      ; Loop forever
END


    
