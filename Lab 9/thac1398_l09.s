/*
-------------------------------------------------------
l09.s
-------------------------------------------------------
Author: Angus Thacker
ID: 169061398
Email: thac1398@mylaurier.ca
Date: 2024-04-03
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
.section .vectors, "ax"
B _start            // reset vector
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0             // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector

.equ  UART_ADDR,  0xff201000
.equ  TIMER_BASE, 0xff202000
.equ  ENTER, 0xA

.org 0x1000   // Start at memory location 1000
.text
.global _start
_start:
/* Set up stack pointers for IRQ and SVC processor modes */
MOV R1, #0b11010010 // interrupts masked, MODE = IRQ
MSR CPSR_c, R1 // change to IRQ mode
LDR SP, =0xFFFFFFFF - 3 // set IRQ stack to A9 onchip memory
/* Change to SVC (supervisor) mode with interrupts disabled */
MOV R1, #0b11010011 // interrupts masked, MODE = SVC
MSR CPSR, R1 // change to supervisor mode
LDR SP, =0x3FFFFFFF - 3 // set SVC stack to top of DDR3 memory
BL CONFIG_GIC // configure the ARM GIC
// set timer
BL TIMER_SETTING
// enable IRQ interrupts in the processor
MOV R0, #0b01010011 // IRQ unmasked, MODE = SVC
MSR CPSR_c, R0
IDLE:
B IDLE // main program simply idles

/* Define the exception service routines */
/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
B SERVICE_UND
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:
B SERVICE_SVC
/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
B SERVICE_ABT_DATA
/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
B SERVICE_ABT_INST
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
stmfd sp!,{R0-R7, LR}
/* Read the ICCIAR from the CPU Interface */
LDR R4, =0xFFFEC100
LDR R5, [R4, #0x0C] // read from ICCIAR

CMP R5, #72
BLEQ INTER_TIMER_ISR

EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
STR R5, [R4, #0x10] // write to ICCEOIR
//BL STOP_TIMER

ldmfd sp!, {R0-R7, LR}
SUBS PC, LR, #4
/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
B SERVICE_FIQ
//.end

/*
* Configure the Generic Interrupt Controller (GIC)
*/
.global CONFIG_GIC
CONFIG_GIC:
stmfd sp!, {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
MOV R0, #72 // Interval timer (Interrupt ID = 72)
MOV R1, #1 // this field is a bit-mask; bit 0 targets cpu0
BL CONFIG_INTERRUPT
/* configure the GIC CPU Interface */
LDR R0, =0xFFFEC100 // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
LDR R1, =0xFFFF // enable interrupts of all priorities levels
STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
MOV R1, #1
STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
LDR R0, =0xFFFED000
STR R1, [R0]
ldmfd sp!, {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
stmfd sp!, {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
LSR R4, R0, #3 // calculate reg_offset
BIC R4, R4, #3 // R4 = reg_offset
LDR R2, =0xFFFED100
ADD R4, R2, R4 // R4 = address of ICDISER
AND R2, R0, #0x1F // N mod 32
MOV R5, #1 // enable
LSL R2, R5, R2 // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
LDR R3, [R4] // read current register value
ORR R3, R3, R2 // set the enable bit
STR R3, [R4] // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
BIC R4, R0, #3 // R4 = reg_offset
LDR R2, =0xFFFED800
ADD R4, R2, R4 // R4 = word address of ICDIPTR
AND R2, R0, #0x3 // N mod 4
ADD R4, R2, R4 // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
STRB R1, [R4]
ldmfd sp!, {R4-R5, PC}

/*************************************************************************
* Timer setting
*
************************************************************************/
.global TIMER_SETTING
TIMER_SETTING:

PUSH {R0-R2, LR}              // save registers
LDR R0, =TIMER_BASE           // FF202000

LDR R1, =200000000            // 2 second timeout

STR R1, [R0, #8]              // store low half word of counter
LSR R2, R1, #16               // start value
STR R2, [R0, #12]             // high half word of counter start value

MOV R1, #0					  //initialize T0 to 0
STR R1, [R0]

MOV R1, #0b111                // bit 3 = stop (0), bit 2 = start (1), bit 1 = continue (1), bit 0 = interrupt enable (1)
STR R1, [R0, #4]              // control register (base+4)

POP {R0-R2, LR}               // restore registers
BX LR

/*************************************************************************
* Interrupt service routine
*
************************************************************************/
.global INTER_TIMER_ISR
INTER_TIMER_ISR:

PUSH {R0-R3, LR}              // save
    
LDR R0, =TIMER_BASE
MOV R1, #0
STR R1, [R0]                  // clear t0
    
LDR R0, =UART_ADDR            // uart base
LDR R1, =ARR1                 // timeout string
    
UART_LOOP:
LDRB R2, [R1], #1             // post increment address
CMP R2, #0                    // null terminator check
BEQ NEWLINE                   // if null, proceed with enter (newline) character
    
WAIT:
LDR R3, [R0, #4]              // uart control register
LSR R3, R3, #16               // shift
CMP R3, #0                   
BEQ WAIT                      // wait for timer to expire
    
STR R2, [R0]                  // write char from string to UART
B UART_LOOP                   // continue output loop
    

NEWLINE:                     // enter char

LDR R3, [R0, #4]              
LSR R3, R3, #16               
CMP R3, #0                    
BEQ NEWLINE                   // wait for timer to expire           

LDR R2, =ENTER
STR R2, [R0]                  // write enter char to UART (0xA)
    
POP {R0-R3, LR}               // pop preserved registers
BX LR                         // return from subroutine

/*****************************************
* data section
*
******************************************/
.data
.align
ARR1:
.asciz "Timeout"

.end

