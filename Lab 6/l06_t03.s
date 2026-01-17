/*
-------------------------------------------------------
l06_t03.s
-------------------------------------------------------
Author:  Angus Thacker
ID:      169061398
Email:   thac1398@mylaurier.ca
Date:    2025-03-06
-------------------------------------------------------
Working with stack frames.
Finds the common prefix of two null-terminate strings.
-------------------------------------------------------
*/
// Constants
.equ SIZE, 80

.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

//=======================================================


mov    r3, #SIZE     // Set the maximum comparison length
stmfd  sp!, {r3}     // Push the maximum length
ldr    r3, =Common
stmfd  sp!, {r3}     // Push the common address
ldr    r3, =Second
stmfd  sp!, {r3}     // Push the second string address
ldr    r3, =First
stmfd  sp!, {r3}     // Push the first string address



//=======================================================

bl     FindCommon

//=======================================================

add    sp, sp, #16   // Release the parameter memory from stack
// clean up stack

//=======================================================

_stop:
b      _stop

//-------------------------------------------------------
FindCommon:
/*
-------------------------------------------------------
Equivalent of: FindCommon(*first, *second, *common, size)
Finds the common parts of two null-terminated strings from the beginning of the
strings. Example:
first: "pandemic"
second: "pandemonium"
common: "pandem", length 6
-------------------------------------------------------
Parameters:
  first - pointer to start of first string
  second - pointer to start of second string
  common - pointer to storage of common string
  size - maximum size of common
Uses:
  r0 - address of first
  r1 - address of second
  r2 - address of common
  r3 - value of max length of common
  r4 - character in first
  r5 - character in second
-------------------------------------------------------
*/

//=======================================================

// prologue: save registers and get parameters from stack
stmfd   sp!, {fp}       // push frame pointer and lr
mov     fp, sp          // save current stack top to frame pointer
stmfd	sp!, {r0-r5}    // preserve other registers

ldr     r0, [fp, #4]    // get address of first string
ldr     r1, [fp, #8]    // get address of second string
ldr     r2, [fp, #12]    // get address of common
ldr     r3, [fp, #16]    // get address of current max length


//=======================================================


FCLoop:
cmp    r3, #1          // is there room left in common?
beq    _FindCommon     // no, leave subroutine
ldrb   r4, [r0], #1    // get next character in first
ldrb   r5, [r1], #1    // get next character in second
cmp    r4, r5
bne    _FindCommon     // if characters don't match, leave subroutine
cmp    r5, #0          // reached end of first/second?
beq    _FindCommon
strb   r4, [r2], #1    // copy character to common
sub    r3, r3, #1      // decrement space left in common
b      FCLoop

_FindCommon:
mov    r4, #0
strb   r4, [r2]        // terminate common with null character

//=======================================================

// epilogue: clean up stack and return from subroutine

ldmfd   sp!, {r0-r5}      // pop preserved registers
ldmfd   sp!, {fp}      // pop frame pointer and pc
bx      lr           // return from subroutine

//=======================================================


//-------------------------------------------------------
.data
First:
.asciz "pandemic"
Second:
.asciz "pandemonium"
Common:
.space SIZE

.end