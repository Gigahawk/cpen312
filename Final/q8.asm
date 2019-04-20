$MODDE2

truth_table:
    db 0, 1, 1, 0

acc2xor:
    push ACC
    mov B, #0x55
    mul AB ; Fill accumulator with lower 2 bits
    mov P0, A ; Write outputs to P0
    pop ACC
    ret

cmpxor:
    push ACC
    movc A, @A+dptr ; Move answer into accumulator
    mov B, #0xF
    mul AB ; Fill lower 4 bits with answer
    orl A, #0xF0 ; Prevent underflow issues
    clr C
    subb A, P0
    clr C
    anl A, #0x0F ; Only care about lower 4 bits
    jz noerror
    setb C ; Set carry if input is different from truth table
noerror:
    pop ACC
    ret

check_xor:
    mov dptr, #truth_table
    mov P0MOD, #0xFF
    mov P2MOD, #0x1F
    orl P2MOD, #0x60 ; Disable LEDs
wait_press:
    jb P2.4, wait_press
wait_release:
    jnb P2.4, wait_release
    setb P2.7 ; Power chip
    mov A, #4
loop_zoop:
    dec A
    lcall acc2xor
    lcall cmpxor
    jc invalid ; Bad chip if carry is set
    jnz loop_zoop
valid:
    clr P2.5
    sjmp cleanup
invalid:
    clr P2.6
    sjmp cleanup
cleanup:
    clr P2.7
    mov P0, #0
