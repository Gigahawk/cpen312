$MODDE2

ljmp init

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
    subb A, P2
    clr C
    anl A, #0x0F ; Only care about lower 4 bits
    jz noerror
    setb C ; Set carry if input is different from truth table
noerror:
    pop ACC
    ret

check_xor:
    mov dptr, #truth_table
    mov P0MOD, #0xFF ; All of P0 is outputs
    mov P2MOD, #0x60 ; P2[0:4] is input, P2[5:6] is output
    orl P2, #0x60 ; Disable LEDs
    ; Clear on board status indicators
    mov LEDRB, #0
    mov LEDG, #0
    ; Show state 1
    mov LEDRA, #0b1
wait_press:
    ; Show state 2
    mov LEDRA, #0b10
    jb P2.4, wait_press
wait_release:
    ; Show state 3
    mov LEDRA, #0b100
    jnb P2.4, wait_release
    ; Show state 4
    mov LEDRA, #0b1000
    setb P2.7 ; Power chip
    mov A, #4
loop_zoop:
    dec A
    lcall acc2xor
    mov R2, #30
    lcall wait ; Wait for simulated chip
    lcall cmpxor
    jc invalid ; Bad chip if carry is set
    jnz loop_zoop
    ; Show state 5
    mov LEDRA, #0b10000
valid:
    clr P2.5
    mov LEDG, #1
    sjmp cleanup
invalid:
    clr P2.6
    mov LEDRB, #1
    sjmp cleanup
cleanup:
    clr P2.7
    mov P0, #0

wait:
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
    djnz R1, L2
    djnz R2, L3
    ret

init:
    mov SP, #30H
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    ljmp main

main:
    lcall check_xor
    mov R2, #100
    lcall wait
    ljmp main
