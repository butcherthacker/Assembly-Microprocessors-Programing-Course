/*
-------------------------------------------------------
count3.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date: 2025/02/06
-------------------------------------------------------
An infinite loop program with a timer delay and
LED display.
-------------------------------------------------------
*/
// Constants
.equ TIMER,     0xfffec600
.equ LEDS,      0xff200000

.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

ldr r0, =LEDS       // LEDs base address
ldr r1, =TIMER      // private timer base address
ldr r2, =LED_BITS   // value to set LEDs
ldr r2, [r2]
ldr r3, =DELAY_TIME // timeout = 1/(200 MHz) x 200x10^6 = 1 sec
ldr r3, [r3]
str r3, [r1]        // write timeout to timer load register
mov r3, #0b011      // set bits: mode = 1 (auto), enable = 1
str r3, [r1, #0x8]  // write to timer control register
LOOP:
str r2, [r0]        // load the LEDs
WAIT:
ldr r3, [r1, #0xC]  // read timer status
cmp r3, #0
beq WAIT            // wait for timer to expire
str r3, [r1, #0xC]  // reset timer flag bit
ror r2, #1          // rotate the LED bits
b LOOP

.data                // Define memory locations
LED_BITS: .word 0x0000FFFF  // Memory storage for LED_BITS
DELAY_TIME: .word 200000000 // Memory storage for delay time

.end