/*
-------------------------------------------------------
l05_t02.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date:    2024-02-21
-------------------------------------------------------
Calculates stats on an integer list.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

mov    r1, #0       // Initialize counters
mov    r2, #0
mov    r3, #0
ldr    r4, =Data    // Store address of start of list
ldr    r5, =_Data   // Store address of end of list
bl     list_stats   // Call subroutine - total returned in r0

_stop:
b      _stop

//-------------------------------------------------------
list_stats:
/*
-------------------------------------------------------
Counts number of positive, negative, and 0 values in a list.
Equivalent of: void stats(*start, *end, *zero, *positive, *negatives)
-------------------------------------------------------
Parameters:
  r1 - number of zero values
  r2 - number of positive values
  r3 - number of negative values
  r4 - start address of list
  r5 - end address of list
Uses:
  r0 - temporary value
-------------------------------------------------------
*/

stmfd sp!, {r4, r5, lr} // Sets registers to consecutive memory locations

loop:
cmp r4, r5 // Compares to see if the starting list pointer address reaches end pointer
beq finish // If 0 then the end of the list has been reached, exit program

ldr r0, [r4], #4 // Loads the current list value into r0 before iterating to the next
cmp r0, #0 // Compares list value in r0 to zero
beq zeroes_count // If 0, branch to zeroes_count
bmi negatives_count // If negative, branch to negatives_count

add r2, r2, #1 // If we didn't branch, add one to positive count
b loop // Continues loop

zeroes_count:
add r1, r1, #1 // Adds one to the zero count
b loop // Continues loop

negatives_count:
add r3, r3, #1 // Adds one to the negative count
b loop // Continues loop

finish:
ldmfd sp!, {r4, r5, lr} // Recover registers from being set to consecutive memory locations
bx lr // Return from subroutine

.data
.align
Data:
.word   4,5,-9,0,3,0,8,-7,12    // The list of data
_Data: // End of list address

.end