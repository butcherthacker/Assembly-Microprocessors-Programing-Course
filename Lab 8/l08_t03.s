/*
-------------------------------------------------------
l08_t03.s
-------------------------------------------------------
Author: Angus Thacker
ID:	169061398
Email:	thac1398@mylaurier.ca
Date:	2024-03-20
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
.org 0x1000   // Start at memory location 1000
.text         // Code section
.global _start
_start:

bl    EchoString

_stop:
b _stop

// Subroutine constants
.equ UART_BASE, 0xff201000  // UART base address
.equ VALID, 0x8000          // Valid data in UART mask
.equ ENTER, 0x0A            // The enter key code

EchoString:
/*
-------------------------------------------------------
Echoes a string from the UART to the UART.
-------------------------------------------------------
Uses:
  r0 - holds character to print
  r1 - address of UART
-------------------------------------------------------
*/

//=======================================================

// your code here
stmfd sp!, {r0, r1}      // Preserve temporary registers
ldr   r1, =UART_BASE     // Get address of UART

esLOOP:
ldr   r0, [r1]           // Read UART data register
tst   r0, #VALID         // Check for data
beq   esLOOP             // Wait for input

cmp   r0, #ENTER         // Check for ENTER key
beq   _Finish          // Stop reading on ENTER key

str   r0, [r1]           // Echo character to UART
b     esLOOP             // Continue looping

_Finish:
ldmfd sp!, {r0, r1}      // Recover temporary registers

//=======================================================


bx    lr               // return from subroutine

.end