/*
-------------------------------------------------------
l08_t02.s
-------------------------------------------------------
Author: Angus Thacker
ID:	169061398
Email:	thac1398@mylaurier.ca
Date:	2024-03-20
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
// Constants
.equ SIZE, 20 // Size of string buffer storage (bytes)

.org 0x1000   // Start at memory location 1000
.text         // Code section
.global _start
_start:

//=======================================================

// your code here
mov    r5, #SIZE  // Set buffer size

//=======================================================

ldr    r4, =First
bl    ReadString
ldr    r4, =Second
bl    ReadString
ldr    r4, =Third
bl     ReadString
ldr    r4, =Last
bl     ReadString

_stop:
b _stop

// Subroutine constants
.equ UART_BASE, 0xff201000  // UART base address
.equ ENTER, 0x0A            // The enter key code
.equ VALID, 0x8000          // Valid data in UART mask

ReadString:
/*
-------------------------------------------------------
Reads an ENTER terminated string from the UART.
-------------------------------------------------------
Parameters:
  r4 - address of string buffer
  r5 - size of string buffer
Uses:
  r0 - holds character to print
  r1 - address of UART
-------------------------------------------------------
*/

//=======================================================

// your code here
stmfd sp!, {r0, r1, r4, r5}  // Preserve temporary registers
ldr   r1, =UART_BASE         // Get address of UART

rsLOOP:
ldr   r0, [r1]               // Read UART data register
tst   r0, #VALID             // Check for data
beq   _ReadString            // Exit loop if no data

cmp   r0, #ENTER             // Check for ENTER key
beq   _ReadString            // Stop reading on ENTER key

strb  r0, [r4]               // Store character in memory
add   r4, r4, #1             // Move to next byte in buffer

subs  r5, r5, #1             // Decrement buffer size counter
beq   _ReadString            // Stop reading if buffer is full


b     rsLOOP

_ReadString:
ldmfd sp!, {r0, r1, r4, r5}  // Restore registers

//=======================================================

bx    lr                    // return from subroutine

.data
.align
// The list of strings
First:
.space  SIZE
Second:
.space SIZE
Third:
.space SIZE
Last:
.space SIZE
_Last:    // End of list address

.end
	
	