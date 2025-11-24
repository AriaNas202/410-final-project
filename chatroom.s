    .data


    .global project8
    .global uart_communication_init
    .global output_character_uart2
    .global read_character_uart2

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
GPIOAFSEL:                  .equ 0x420
GPIOPCTL:                   .equ 0x52C



project8:
    PUSH{r4-r12, lr}

    ;pin diagram: page 1328
    ;connect RX: recieve pin (input), TX: transmit pin (output), GND
    BL uart_communication_init

    BL read_character_uart2
    BL output_character_uart2


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
    MOV r5, #0x8                            ;bit 3
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





    POP {r4-r12, lr}
    mov pc, lr



    .end

