/*
-------------------------------------------------------
errors1.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date: 2025/01/30
-------------------------------------------------------
Assign to and add contents of registers.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

// Copy data from memory to registers
ldr r3, =A //Fixed the line by removing semicolon and added equals sign
ldr r0, [r3]
ldr r3, =B //Fixed the line by removing colon and added equals sign
ldr r1, [r3]
add r2, r1, r0 //Fixed the line by removing square brackets around r0
// Copy data to memory
ldr r3, =Result // Assign address of Result to r3
str r2, [r3] // Store contents of r2 to address in r3
// End program
_stop:
b _stop

.data      // Initialized data section
A:
.word 4
B:
.word 8
.bss     // Uninitialized data section
Result:
.space 4 // Set aside 4 bytes for result

.end