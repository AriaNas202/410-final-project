    .data

message:					.string "R", 0

    .global project8
    .global uart_communication_init
    .global output_character_uart2
    .global read_character_uart2
	.global rgb_led_init

    .text

RCGCUART:                   .equ 0x618
RCGCGPIO:                   .equ 0x608
UARTCTL:                    .equ 0x030
UARTIBRD:                   .equ 0x024
UARTFBRD:                   .equ 0x028
UARTCC:                     .equ 0xFC8
UARTLCRH:                   .equ 0x02C
UARTFR:                     .equ 0x018

GPIODEN:                    .equ 0x51C
GPIODIR: 		           	.equ 0x400              ;direction reg, 1 - output, 0 - input
GPIOAFSEL:                  .equ 0x420
GPIOPCTL:                   .equ 0x52C
GPIODATA:                   .equ 0x3FC              ;data reg

ptr_to_message:				.word message


project8:
    PUSH{r4-r12, lr}

    ;pin diagram: page 1328
    ;connect RX: recieve pin (input), TX: transmit pin (output), GND
    BL uart_communication_init
	BL rgb_led_init

	MOV r4, #0x5000
	MOVT r4, #0x4002						;port F base address
	LDR r6, [r4, #GPIODATA]
	ORR r6, r6, #0x4
	STR r6, [r4, #GPIODATA]

	BL read_character_uart2


	CMP r0, #0x52
	BNE infinite_loop

	MOV r4, #0x5000
	MOVT r4, #0x4002						;port F base address
	LDR r6, [r4, #GPIODATA]
	ORR r6, r6, #0x2
	STR r6, [r4, #GPIODATA]


infinite_loop:



	B infinite_loop




    POP{r4-r12, lr}
    mov pc, lr






uart_communication_init:
    PUSH{r4-r12, lr}

    ;Provide clock to UART2
    MOV r4, #0xE000
    MOVT r4, #0x400F                        ;Base address of clock gating
    MOV r5, #0x4                            ;bit 2
    STR r5, [r4, #RCGCUART]

    ;Enable clock to port D, (PD6: RX, PD7: TX)
    MOV r4, #0xE000
    MOVT r4, #0x400F                        ;Base address of clock gating
    MOV r5, #0x3F                            ;bit 3
    STR r5, [r4, #RCGCGPIO]

    ;Disable UART2 control
    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
    MOV r5, #0x0
    STR r5, [r4, #UARTCTL]

    ;Set UART2_IBRD_R for 115,200 baud
    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
    MOV r5, #0x8
    STR r5, [r4, #UARTIBRD]

    ;Set UART2_FBRD_R for 115,200 baud
    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
    MOV r5, #44
    STR r5, [r4, #UARTFBRD]

    ;Use system clock
	MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
	MOV r5, #0x0
	STR r5, [r4, #UARTCC]

    ;Use 8-bit word length, 1 stop bit, no parity
    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
    MOV r5, #0x60
    STR r5, [r4, #UARTLCRH]

    ;Enable UART2 control, RX, TX
    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2
    MOV r5, #0x301
    STR r5, [r4, #UARTCTL]

    ;Make PD6 and PD7 as Digital Ports
    MOV r4, #0x7000
    MOVT r4, #0x4000                        ;Base address of Port D
    LDR r6, [r4, #GPIODEN]
    ORR r6, r6, #0xC0                       ;pins 6, 7
    STR r6, [r4, #GPIODEN]

    ;Change PD6 and PD7 to Use an Alternate Function
    MOV r4, #0x7000
    MOVT r4, #0x4000                        ;Base address of Port D
    LDR r6, [r4, #GPIOAFSEL]
    ORR r6, r6, #0xC0                       ;pins 6, 7
    STR r6, [r4, #GPIOAFSEL]

    ;Configure PD6 and PD7 for UART
    MOV r4, #0x7000
    MOVT r4, #0x4000                        ;Base address of Port D
    LDR r6, [r4, #GPIOPCTL]
    MOV r5, #0x0000
    MOVT r5, #0x1100
    ORR r6, r6, r5
    STR r6, [r4, #GPIOPCTL]

    POP{r4-r12, lr}
    mov pc, lr




output_character_uart2:
    PUSH {r4-r12, lr}

output_flag:

    MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2

    LDRB r6, [r4, #UARTFR]
    MOV r5, #0x20

    AND r7, r5, r6

    CMP r7, #0
    BNE output_flag

    STRB r0, [r4]

    POP {r4-r12, lr}
    mov pc, lr



read_character_uart2:
    PUSH {r4-r12, lr}

read_flag:

	MOV r4, #0xE000
    MOVT r4, #0x4000                        ;Base address of UART2

	LDRB r6, [r4, #UARTFR]
    MOV r5, #0x10

    AND r7, r5, r6

    CMP r7, #0
    BNE read_flag

    LDRB r0, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr








rgb_led_init:
	PUSH {r4-r12, lr}

	;MOV r9, #0xE000                 ;address of clock
    ;MOVT r9, #0x400F

    ;MOV r5, #0x20
    ;STR r5, [r9, #RCGCGPIO]            ;enable clock for GPIO port F

    ORR r10, r10, r10
	ORR r10, r10, r10
	ORR r10, r10, r10               ;NOPS

	MOV r4, #0x5000
    MOVT r4, #0x4002				;port F base address

	;enable output
	MOV r7, #0xE
    LDR r6, [r4, #GPIODIR]
    ORR r6, r7, r6             		;store 1 into (pin 2-5) - output
    STR r6, [r4, #GPIODIR]

	;enable digital
    MOV r7, #0xE
    LDR r6, [r4, #GPIODEN]
    ORR r6, r6, r7                  ;store 1 into (pin 2-5) - digital
    STR r6, [r4, #GPIODEN]



	POP {r4-r12, lr}
    mov pc, lr

    .end

