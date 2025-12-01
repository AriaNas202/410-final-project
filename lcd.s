    .data


    .global spiInit







     .text





;C6 is latch register
;Using SS2
;Pins are as Followed:
	;D7(MSB) - D4 (LSB) 	--> For Char Transfer: (1) Send upper nibble, delay few microseconds, (2) Send lower nibble
	;D0 --> Register Select Pin
	;D1 --> Enable Pin

;WORK IN PROGRESS
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
	;NOTE: CURRENTLY NOT SETTING PORT C (because that's a latch for alice board, not spi)
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

	;Port C, Pin 7 (4000651C)
	;For some reason this regiser seems to be init t 0xF which turns into 0x8f, idk if that's an issue (i dont think so)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x51C		;get effective address

	MOV r1, #0x80			;set pins 7

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

	;Port C, Pins 7 (40006400)
	MOV r0, #0x6000
	movt r0, #0x4000
	add r0, r0, #0x400		;get effective address

	MOV r1, #0x80			;set pin 7 as output

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

	MOV r1, #0x4			;enable ssi module 2 (notes say so)

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
	;Set SSI as Master
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
	;Note: SSInClk = SysClk/ (CPSDVSR * (1+SCR)) BUT we're making SRC 0, so it doesn't affect anything
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x010		;get effective address

	mov r1, #0x4			;16MHz/4=4MHz

	STR r1, [r0]			;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;?				Select the 16-Bit Data Size
	;				PROBABLY WILL NEED TO CHANGE THE DATA SIZE
	;SSICR0 (pg 969) (Using SSI2: 4000A000)
	;(r0-address; r1-data)
	MOV r0, #0xA000
	movt r0, #0x4000	;get effective address

	MOV r1, #0xF		;set SSI Data size to 16-bit

	STR r1, [r0]		;update register

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable Loopback
	;SSICR1 (pg 971) (Using SSI2: 4000A004)
	;(r0-address; r1-data)
	MOv r0, #0xA000
	movt r0, #0x4000
	add r0, r0, #0x004		;get effective address

	LDR r1, [r0]			;get current data
	ORR r1, #0x1			;set the LSB to 1 (turns on loopback mode)

	STR r1, [r0]			;update register

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


