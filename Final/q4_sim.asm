    DSEG at 040H
X:  DS 3 ; six BCD digits for input X
Y:  DS 3 ; six BCD digits for input Y
    XSEG at 4000H
Z:  DS 3 ; six BCD digits for result Z

CSEG

ljmp main

ninecpl MAC
    mov A, #99H
    clr C
    subb A, %0
    mov %0, A
ENDMAC

addbcd MAC
    mov A, %0
    addc A, %1
    da A
ENDMAC

movZ MAC
    mov dptr, %0
    movx @dptr, A
ENDMAC

main:
    ; Clear Z
    clr A
    mov dptr, #Z+0
    movx @dptr, A
    mov dptr, #Z+1
    movx @dptr, A
    mov dptr, #Z+2
    movx @dptr, A
    ; X = 654321
    mov X+0, #21H
    mov X+1, #43H
    mov X+2, #65H
    ; Y = 123456
    mov Y+0, #56H
    mov Y+1, #34H
    mov Y+2, #12H
    lcall six_dig_sub
forever:
    sjmp forever

six_dig_sub:
    ninecpl(Y+0)
    ninecpl(Y+1)
    ninecpl(Y+2)
    setb C
    addbcd(X+0, Y+0)
    movZ(#Z+0)
    addbcd(X+1, Y+1)
    movZ(#Z+1)
    addbcd(X+2, Y+2)
    movZ(#Z+2)
    ret
