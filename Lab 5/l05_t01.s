/*
-------------------------------------------------------
l05_t01.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date:    2024-02-21
-------------------------------------------------------
Does a running total of an integer list.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

ldr    r1, =Data    // Store address of start of list
ldr    r2, =_Data   // Store address of end of list
bl     list_total   // Call subroutine - total returned in r0

_stop:
b      _stop

//-------------------------------------------------------
list_total:
/*
-------------------------------------------------------
Totals values in a list.
Equivalent of: int total(*start, *end)
-------------------------------------------------------
Parameters:
  r1 - start address of list
  r2 - end address of list
Uses:
  r3 - temporary value
Returns:
  r0 - total of values in list
-------------------------------------------------------
*/

mov r0, #0 // Initializes sum in r0 to 0

loop:
cmp r1, r2 // Check if we have reached the end of list
beq finish // If 0 then exit program

ldr r3, [r1], #4 // Loads the current list value into r3 before iterating to the next
add r0, r0, r3 // Adds the value in r3 to the sum in r0

b loop // Continues loop


finish:
mov pc, lr // Return statement



.data
.align
Data:
.word   4,5,-9,0,3,0,8,-7,12    // The list of data
_Data: // End of list address

.end