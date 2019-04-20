    DSEG at 040H
X:  DS 3 ; six BCD digits for input X
Y:  DS 3 ; six BCD digits for input Y
    XSEG at 4000H
Z:  DS 3 ; six BCD digits for result Z

CSEG

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
