$MODDE2

BSEG
UPPER: DBIT 1

CSEG
ljmp init
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

lcd_cmd_write:
    mov LCD_DATA, R5
    clr LCD_RS
    clr LCD_RW
    setb LCD_EN
    lcall wait
    clr LCD_EN
    lcall wait
    ret

lcd_data_write:
    mov LCD_DATA, R5
    setb LCD_RS
    clr LCD_RW
    setb LCD_EN
    lcall wait
    clr LCD_EN
    lcall wait
    ret

init:
    mov LEDRA, #0
    mov LEDRB, #0
    mov LEDRC, #0
    mov LEDG, #0
    mov LCD_MOD, #0FFH ; Set LCD pins as output
    setb LCD_ON ; Turn on LCD
    clr LCD_RW ; Set LCD to write mode
    setb LCD_BLON ; Turn on backlightS
    mov B, #0 ; Start counting from 0
    ljmp main

wait:
    mov R2, #1
L3: mov R1, #250
L2: mov R0, #250
L1: djnz R0, L1
    djnz R1, L2
    djnz R2, L3
    ret

reset_disp:
    mov R5, #0x38 ; Enable 5x7 mode for chars
    lcall lcd_cmd_write
    mov R5, #0x0E ; Display OFF, Cursor ON
    lcall lcd_cmd_write
    mov R5, #0x01 ; Clear display
    lcall lcd_cmd_write
    mov R5, #0x80 ; Move cursor to begining of first line
    lcall lcd_cmd_write
    ret

write_disp:
    mov R5, AR7
    lcall lcd_data_write
    mov R5, AR6
    lcall lcd_data_write
    ret

main:
    lcall hex2ascii
    lcall reset_disp
    lcall write_disp
    mov A, B
    add A, #1
    mov B, A
    jnc no_toggle_upper
    cpl UPPER
no_toggle_upper:
    lcall wait
    sjmp main


