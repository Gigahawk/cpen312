$MODDE2

CSEG at 0
ljmp init

DSEG at 30h
x:      ds 4
y:      ds 4
bcd:    ds 5
op:     ds 1

BSEG
mf:     dbit 1

$include(math32.asm)

; In place RLC (overwrites accumulator)
RLCI MAC
    mov A, %0
    rlc A
    mov %0, A
ENDMAC

WRITE_DISP MAC
    ; Display LSD
    mov A, %0
    anl A, #00001111b
    movc A, @A+DPTR
    mov %1, A

    ; Display MSD
    mov A, %0
    swap A
    anl A, #00001111b
    movc A, @A+DPTR
    mov %2, A
ENDMAC

sevenseg_lut:
    DB 0C0H, 0F9H, 0A4H, 0B0H, 099H        ; 0 TO 4
    DB 092H, 082H, 0F8H, 080H, 090H        ; 4 TO 9

display:
    mov DPTR, #sevenseg_lut
    WRITE_DISP(bcd+0, HEX0, HEX1)
    WRITE_DISP(bcd+1, HEX2, HEX3)
    WRITE_DISP(bcd+2, HEX4, HEX5)
    ret

shift_digits:
    mov R0, #4 ; Shift 1 bcd digit (4 bits)
shift_digits_L0:
    clr c
    RLCI(bcd+0)
    RLCI(bcd+1)
    RLCI(bcd+2)
    RLCI(bcd+3)
    RLCI(bcd+4)
    djnz R0, shift_digits_L0

    ; Move new BCD digit from R7 into bcd+0
    mov A, R7
    orl A, bcd+0
    mov bcd+0, A

    ; Extra digits dont fit (this is probably unnecessary)
    clr A
    mov bcd+4, A
    ret

wait_50ms:
;33.33MHz, 1clk per cycle: 0.03us
    mov R0, #30
L3: mov R1, #74
L2: mov R2, #250
L1: djnz R2, L1
    djnz R1, L2
    djnz R0, L3
    ret

read_number:
    mov R4, SWA ; Read switches 0 to 7
    mov A, SWB  ; Read swithes 8 to 15
    anl A, #00000011B ; Mask for switches 8 and 9
    mov R5, A

    ; Return if all switches are off
    mov A, R4
    orl A, R5
    jz read_number_no_number

    lcall wait_50ms ; debounce switches

    mov A, SWA
    clr C
    subb A, R4
    jnz read_number_no_number ; SWA changed between reads, ignore

    mov A, SWB
    anl A, #00000011B
    clr C
    subb A, R5
    jnz read_number_no_number ; SWB changed between reads, ignore

    ; Start checking at SW15 (could start at SW9 but this is less code)
    mov R7, #16
read_number_L0:
    clr C

    ; Left shift bits across R4 and R5
    RLCI(R4)
    RLCI(R5)

    ; Jump when the enabled switch gets shifted into carry
    jc read_number_decode
    djnz R7, read_number_L0 ; keep shifting
    sjmp read_number_no_number ; didn't find an enabled switch
read_number_decode:
    dec R7 ; Store switch number in R7
    setb C ; Indicate that a switch was detected

; Wait for all input switches to turn off
read_number_L1:
    mov A, SWA
    jnz read_number_L1
read_number_L2:
    mov A, SWB
    anl A, #00000011B
    jnz read_number_L2
    ret

read_number_no_number:
    clr C
    ret

init:
    ; Initialize stack pointer
    mov SP, #7FH

    ; Clear out display and LEDs
    clr A
    mov LEDRA, A
    mov LEDRB, A
    mov LEDRC, A
    mov LEDG, A
    mov bcd+0, A
    mov bcd+1, A
    mov bcd+2, A
    mov bcd+3, A
    mov bcd+4, A

    lcall display
    sjmp menu

do_add:
    lcall add32
    lcall hex2bcd
    ret

do_sub:
    lcall sub32
    lcall hex2bcd
    ret

do_mul:
    lcall mul32
    lcall hex2bcd
    ret

do_div:
    lcall div32
    lcall hex2bcd
    ret

do_op:
    lcall bcd2hex
    lcall xchg_xy ; swap x and y to maintain commutative properties

    mov A, op ; Check which operation to do
    jb acc.0, do_add
    jb acc.1, do_sub
    jb acc.2, do_mul
    jb acc.3, do_div

    ; Reset numbers if something went wrong
    Load_X(0)
    Load_Y(0)
    ret

; Jump if SW10 is high
JSW10 MAC
    mov A, SWB
    anl A, #00000100b
    jnz %0
ENDMAC

menu:
    jb KEY.3, no_add ; check if KEY3 pressed (+/*)
    jnb KEY.3, $ ; wait until KEY3 is released
    lcall bcd2hex ; Grab bcd number and store in x
    lcall copy_xy ; Copy x to y
    Load_X(0) ; Reset x
    lcall hex2bcd ; Overwrite bcd display with x
    lcall display
    ; Use SW10 to as shift key, KEY0 is the reset button
    ; and I have no idea how you're supposed to use it without
    ; making the processor reset
    JSW10(is_mult)
    mov op, #0001B ; set operation to addition
    ljmp menu
is_mult:
    mov op, #0100B ; set operation to multiplication
    ljmp menu
no_add:
    jb KEY.2, no_sub ; Check if KEY2 pressed(-/÷)
    jnb KEY.2, $
    lcall bcd2hex
    lcall copy_xy
    Load_X(0)
    lcall hex2bcd
    lcall display
    JSW10(is_div)
    mov op, #0010B ; set operation to subtraction
    ljmp menu
is_div:
    mov op, #1000B
    ljmp menu
no_sub:
    jb KEY.1, no_equal ; check if KEY1 pressed (=)
    jnb KEY.1, $ ; wait until KEY1 is released
    lcall do_op
    lcall display
    ljmp menu
no_equal:
    lcall read_number
    jnc menu ; continue if no switch was toggled
    lcall shift_digits
    lcall display
    ljmp menu

