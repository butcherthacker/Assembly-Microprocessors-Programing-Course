/*
-------------------------------------------------------
errors3.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date: 2025/01/30
-------------------------------------------------------
Copies contents of one vector to another.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

//Removed unnecessary duplication of .text code section previously here
// Copy contents of first element of Vec1 to Vec2
ldr r0, =Vec1
ldr r1, =Vec2
ldr r2, [r0]
str r2, [r1]
// Copy contents of second element of Vec1 to Vec2
add r0, r0, #4 // Fixed line to increment by 4 bypes at a time and prevent misalignment
add r1, r1, #4 // Fixed line to increment by 4 bypes at a time and prevent misalignment
ldr r2, [r0]
str r2, [r1]
// Copy contents of second element of Vec1 to Vec2
add r0, r0, #4 //Fixed line to increment r0 instead of incrementing r1 twice
add r1, r1, #4
ldr r2, [r0]
str r2, [r1] //Fixed line by storing the value at address of r1 in r2 in memory
// End program
_stop:
b _stop

.data // Initialized data section
Vec1:
.word 1, 2, 3
.bss // Uninitialized data section
Vec2:
.space 6 //Changed from word to space 

.end