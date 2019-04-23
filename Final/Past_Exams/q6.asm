CSEG

TO_HEX: DB '0', '1', '2', '3', '4', '5', '6', '7'
        DB '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

hex2ascii:
    mov dptr, #TO_HEX
    mov A, B
    anl A, #0x0F
    movc A, @A+dptr
    mov R6, A
    mov A, B
    swap A
    anl A, #0x0F
    movc A, @A+dptr
    mov R7, A


