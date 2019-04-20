Dec7Seg:
    DB 40H, 79H, 24H, 30H, 19H, 12H, 02H, 78H, 00H, 10H

writeDec MAC
    ; Grab 7seg from LUT
    movc A, @A+dptr
    ; Write out to latch
    mov P0, A
    ; Enable latch (active rising edge)
    setb %0
ENDMAC

incBandDisp:
    ; Set CLK low
    clr P1.0
    clr P1.1
    ; Point to LUT
    mov dptr, #Dec7Seg
    ; BCD increment B
    mov A, B 
    inc A
    da A
    mov B, A
    ; Mask lower nibble
    anl A, #1111b
    ; Write out to LSD display
    writeDec(P1.1)
    ; Mask higher nibble
    mov A, B
    swap A
    anl A, #1111b
    ; Write out to MSD display
    writeDec(P1.0)
    ret


