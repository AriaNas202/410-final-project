    .data


    .global spiInit
    .global lcdSend







     .text





;C6 is latch register
;Using SS2
;Pins are as Followed:
	;D7(MSB) - D4 (LSB) 	--> For Char Transfer: (1) Send upper nibble, delay few microseconds, (2) Send lower nibble
	;D0 --> Register Select Pin
	;D1 --> Enable Pin


;Function to init the lcd and
;temporarily hardcoded to show some value (FOR MY TESTING PURPOSES)
lcdSend:
	PUSH {r4-r12, lr}
	;Process:
		;Unlatch shift reg
		;Wait for transfer
		;set bits in register
		;wait for transfer
		;latch register
		;delay 25 ms for next transmission

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;ARGUMENT r0 contains 2 hex which we're to send
	;(store in r2 for saving)
	MOV r2, r0
		;Eventually we'll probably have an argument which says if hex is command or data but im just trying to init rn


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;FIRST HEX TO SEND!!!!
	;(r0-address; r1-data, r2-argument to send)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Unlatch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	BIC r1, #0x40			;set bit 6 low

	STR r1, [r0]			;update Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Previous Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

PrevTransPoll1:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE PrevTransPoll1		;If r1 ISNT 0, then it's still busy, so poll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Send Data
	;SSIDR (pg 973) (Using SSI2: 4000A008)
	MOV r0, #0xA000
	MOVT r0, #0x4000
	add r0, r0, #0x008		;get effective address

	;Get Higher Nibble hex out of r2 to send
	AND r1, r2, #0xF0		;mask first hex value and put in r1


	STR r1, [r0]			;update register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Current Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	;(r0-address; r1-data)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

CurrTransPoll1:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE CurrTransPoll1		;If r1 ISNT 0, then it's still busy, so poll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Latch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	;(r0-address; r1-data)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	ORR r1, #0x40			;set bit 6 High

	STR r1, [r0]			;update Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;stall a little between data sends (25 ms)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;SECOND HEX TO SEND!!!!
	;(r0-address; r1-data, r2-argument to send)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Unlatch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	BIC r1, #0x40			;set bit 6 low

	STR r1, [r0]			;update Register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Previous Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

PrevTransPoll2:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE PrevTransPoll2		;If r1 ISNT 0, then it's still busy, so poll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Send Data
	;SSIDR (pg 973) (Using SSI2: 4000A008)
	MOV r0, #0xA000
	MOVT r0, #0x4000
	add r0, r0, #0x008		;get effective address

	;Get Higher Nibble hex out of r2 to send
	AND r1, r2, #0xF		;mask second hex value and put in r1


	STR r1, [r0]			;update register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Wait for Current Transmission to Complete
	;SSISR (pg 974) (Using SSI2: 4000A00C)
	;(r0-address; r1-data)
	Mov r0, #0xA000
	Movt r0, #0x4000
	add r0, r0, #0x00C		;get effective address

CurrTransPoll2:
	ldr r1, [r0]			;get register data
	AND r1, r1, #0x10		;mask bit 4 (the busy flag)
	CMP r1, #0				;compare to 0
	BNE CurrTransPoll2		;If r1 ISNT 0, then it's still busy, so poll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Latch Shift Reg
	;GPIODATA (pg 662) (Port C APB: 40006000)
	;(r0-address; r1-data)
	MOv r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x3FC		;get effective address

	ldr r1, [r0]			;get current data
	ORR r1, #0x40			;set bit 6 High

	STR r1, [r0]			;update Register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;stall a little between data sends (25 ms)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	POP {r4-r12, lr}
	MOV pc, lr








spiInit:
	PUSH {r4-r12, lr}	; Store register lr on stack



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable clock to Appropriate GPIO Module
	;RCGCGPIO (pg 340) (400FE608)
	;(r0-address; r1-data)
	;Port B
	;Port C
	MOV r0, #0xE000
	movt r0, #0x400F
	add r0, r0, #0x608		;get effective address

	MOV r1, #0x6			;turn on Port B/C clock

	str r1, [r0]			;update register

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Configure Pins to be in Alt Function Mode
	;GPIOAFSEL (pg 671) (Port B APB: 40005420)
	;(r0-address; r1-data)
	;Port B4/B7
	mov r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x420		;get effective address

	MOV r1, #0x90 			;set pins 4 and 7 to be in alt function mode

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Tell GPIO Which alt Function to use
	;GPIOPCTL (pg 688) (Port B APB 4000552C)
	;(r0-address; r1-data)
	;Port B4/B7
	mov r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x52C		;get effective address

	MOV r1, #0x0000
	movt r1, #0x2002		;write Pins 4 and 7 to be the value (2)

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set Pins as Digital
	;GPIODEN (pg 682)
	;(r0-address; r1-data)

	;Port B, Pins 4/7 (4000551C)
	MOV r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x51C		;get effective address

	MOV r1, #0x90			;set pins 4/7

	str r1, [r0]			;update register

	;Port C, Pin 6 (4000651C)
	;NOTE: I Changes this FROM pin7 to pin6 (7 segment used 7, but LCD 6) (I think)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x51C		;get effective address

	MOV r1, #0x40			;set pins 6

	str r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set Pins as Output
	;GPIODIR  (pg 663)
	;(r0-address; r1-data)


	;Port B, Pins 4/7 (40005400)
	MOV r0, #0x5000
	movt r0, #0x4000
	add r0, r0, #0x400		;get effective address

	MOV r1, #0x90			;set pins 4/7 as output

	str r1, [r0]			;update register

	;Port C, Pins 6 (40006400)
	;NOTE: I Changes this FROM pin7 to pin6 (7 segment used 7, but LCD 6) (I think)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x400		;get effective address

	MOV r1, #0x40			;set pin 6 as output

	str r1, [r0]			;update register


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Configure SSI Module

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Turn On SSI Module
	;RCGCSSI (pg 346) (400FE61C)
	;(r0-address; r1-data)
	mov r0, #0xE000
	movt r0, #0x400F
	add r0, r0, #0x61C		;get effective address

	MOV r1, #0x4			;enable ssi module 2

	str r1, [r0]			;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Disable SSI2 to be able to config it
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x4	;get effective address

	ldr r1, [r0]		;get current data
	BIC r1, #0x2		;write 0 to bit to disable

	str r1, [r0]		;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set SSI to Lead
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x4	;get effective address

	ldr r1, [r0]		;get current data
	BIC r1, #0x4		;write 0 to bit to select leader mode

	str r1, [r0]		;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Configure SSI Clock
	;SSICC (pg 984) (Using SSI2: 4000AFC8)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	MOVT r0, #0x4000
	add r0, r0, #0xFC8		;get effective address

	MOV r1, #0x0			;set to use system clock

	str r1, [r0]			;update register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Set SSI Clock Prescale Divisor
	;SSICPSR (pg 976) (Using SSI2: 4000A010)
	;Note: SSInClk = SysClk/ (CPSDVSR * (1+SCR)) BUT we're making SRC 0, so it doesn't affect anything (Default is 0, I don't need to touch it and I wont)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x010		;get effective address

	mov r1, #0x4			;16MHz/4=4MHz

	STR r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Select the 8-Bit Data Size
	;SSICR0 (pg 969) (Using SSI2: 4000A000)
	;(r0-address; r1-data)
	;NOTE: I Changes this FROM 16bit to 8bit (LCD doesnt read more than 8 bits at once)
		;Evetually I may change it to 6-bit but Im trying 8 for now

	MOV r0, #0xA000
	movt r0, #0x4000	;get effective address

	MOV r1, #0xF		;set SSI Data size to 8-bit

	STR r1, [r0]		;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable Loopback
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	;NOTE: I AM REMOVING LOOPBACK FOR NOW!!!!

	;MOv r0, #0xA000
	;movt r0, #0x4000
	;add r0, r0, #0x004		;get effective address

	;LDR r1, [r0]			;get current data
	;ORR r1, #0x1			;set the LSB to 1 (turns on loopback mode)

	;STR r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable SSE (Synchronous Serial Port)
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOv r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x004		;get effective address

	ldr r1, [r0]			;get current data
	ORR r1, #0x2			;set bit 1 to enable SSE

	STR r1, [r0]			;update Register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop


	POP {r4-r12, lr}
	MOV pc, lr
























































    .end
