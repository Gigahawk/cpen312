BSEG
UPPER: DBIT 1

CSEG
TO_HEX_UPPER: DB '0123456789ABCDEF'
TO_HEX_LOWER: DB '0123456789abcdef'

hex2ascii:
    mov dptr, #TO_HEX_UPPER
    jb UPPER, not_lower
    mov dptr, #TO_HEX_LOWER
not_lower:
    mov A, B
    anl A, #1111B
    movc A, @A+dptr
    mov R6, A
    mov A, B
    swap A
    anl A, #1111B
    movc A, @A+dptr
    mov R7, A


