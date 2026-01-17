/*
-------------------------------------------------------
l04_t02.s
-------------------------------------------------------
Author:  Angus Thacker
ID:      169061398
Email:   thac1398@mylaurier.ca
Date:    2025-02-14
-------------------------------------------------------
A simple list demo program. Traverses all elements of an integer list.
r0: temp storage of value in list
r2: address of start of list
r3: address of end of list
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

ldr    r2, =Data    // Store address of start of list
ldr    r3, =_Data   // Store address of end of list
mov    r1, #0       // Start with a sum of 0 in r1
sub    r5, r3, r2   // Calculates total number of bytes in list to r5
// By subtracting the address for the start of the list from the end, we can determine the total number of bytes with no loop

Loop:
ldr    r0, [r2], #4 // Read address with post-increment (r0 = *r2, r2 += 4)
add    r4, r4, #1   // Increment the count for number of values in list to r4
cmp    r3, r2       // Compare current address with end of list
bne    Loop         // If not at end, continue

_stop:
b _stop

.data
.align
Data:
.word   4,5,-9,0,3,0,8,-7,12    // The list of data
_Data: // End of list address

.end

	