#include<Arduino.h>

void setup() {
    // PORTA as inputs (gpio 22-29)
    DDRA = 0x00;
    // PORTC as outputs (gpio 37-30)
    DDRC = 0xFF;
}

/* Note: The ATmega2560 used in the Arduino Mega only runs at 16MHz.
 * This is too slow to properly simulate a 74HC86 chip from the
 * perspective of an 8051 running at 33MHz. This code is somewhat
 * optimized for speed but a delay must be put into the DE2-8052
 * test code to ensure proper functionality.*/
void loop() {
    /* Each bit pair of PINA is an input to an xor gate.
     * Each bit pair of PINA corresponds with a single bit of PORTC.
     * PINA[0:1](GPIO 22:23) => PORTC[0](GPIO 37)
     * PINA[2:3](GPIO 24:25) => PORTC[2](GPIO 35)
     * PINA[4:5](GPIO 26:27) => PORTC[4](GPIO 33)
     * PINA[6:7](GPIO 28:29) => PORTC[6](GPIO 31)
     * Odd indices of PORTC are unused. */
    PORTC = PINA ^ (PINA >> 1);
}
