    .data

    .global project8
    .global EEprom_init
    .global EEprom_write
    .global EEprom_read
    .global uart_init
    .global EEprom_read_message
    .global output_string
    .global output_character
    .global read_character
    .global read_string
    .global lcdInit
    .global readingLCD
    .global lcdSendByte


message_buffer:                      .space 32
prev_prompt:                         .string "Previous Message: ", 0
curr_prompt:                         .string "Enter a message: ", 0



    .text

ptr_to_messbuffer:                  .word message_buffer
ptr_to_prevprompt:                  .word prev_prompt
ptr_to_currprompt:                  .word curr_prompt

RCGCEEPROM:                         .equ 0x658
EEDONE:                             .equ 0x018
EEBLOCK:                            .equ 0x004
EEOFFSET:                           .equ 0x008
EERDWRINC:                          .equ 0x014

U0FR:								.equ 0x18

project8:
    PUSH{r4-r12, lr}

    BL EEprom_init
    BL uart_init
    bl lcdInit

    ;read last message
    BL EEprom_read_message
    BL readingLCD

    LDR r0, ptr_to_prevprompt
    BL output_string

    LDR r0, ptr_to_messbuffer
    BL output_string

    MOV r0, #0xA 				;load ascii for new line
	BL output_character
	MOV r0, #0xD 				;load ascii for carriage return
	BL output_character

begin_prompt:

    LDR r0, ptr_to_currprompt
    BL output_string

    LDR r0, ptr_to_messbuffer
    BL read_string

    BL EEprom_write_message

    MOV r0, #0xA 				;load ascii for new line
	BL output_character
	MOV r0, #0xD 				;load ascii for carriage return
	BL output_character


	BL readingLCD


    B begin_prompt


    POP{r4-r12, lr}
    mov pc, lr





EEprom_init:
    PUSH{r4-r12, lr}

    ;Enable EEPROM clock
    MOV r4, #0xE000
    MOVT r4, #0x400F                        ;clock base address
    MOV r5, #0x1
    STR r5, [r4, #RCGCEEPROM]

    ORR r10, r10, r10
	ORR r10, r10, r10
	ORR r10, r10, r10               ;NOPS

    ;Poll until EEprom is ready
EEprom_poll:
    MOV r4, #0xF000
    MOVT r4, #0x400A                        ;EEprom base address
    LDR r5, [r4, #EEDONE]
    AND r5, r5, #1
    CMP r5, #0
    BNE EEprom_poll

    POP{r4-r12, lr}
    mov pc, lr




EEprom_read_message:
    PUSH{r4-r12, lr}
    LDR r9, ptr_to_messbuffer

    MOV r4, #0xF000
    MOVT r4, #0x400A                    ;EEprom base address

    MOV r5, #0                          ;count

EEprom_read_loop:
    CMP r5, #16
    BLT read_block0
    MOV r6, #1
    SUB r7, r5, #16
    B read_offset

read_block0:
    MOV r6, #0
    MOV r7, r5

read_offset:
    STR r6, [r4, #EEBLOCK]
    STR r7, [r4, #EEOFFSET]

    LDRB r8, [r4, #EERDWRINC]

    CMP r8, #0xFF
    BEQ EEprom_read_done

    CMP r8, #0
    BEQ EEprom_read_done

    STRB r8, [r9, r5]

    ADD r5, r5, #1
    B EEprom_read_loop

EEprom_read_done:

    POP{r4-r12, lr}
    mov pc, lr





EEprom_write_message:
    PUSH{r4-r12, lr}
    LDR r9, ptr_to_messbuffer

    MOV r4, #0xF000
    MOVT r4, #0x400A                    ;EEprom base address

    MOV r5, #0

EEprom_write_loop:
    LDRB r8, [r9, r5]
    CMP r8, #0
    BEQ EEprom_write_done

    CMP r5, #16
    BLT write_block0
    MOV r6, #1
    SUB r7, r5, #16
    B write_offset

write_block0:
    MOV r6, #0
    MOV r7, r5

write_offset:
    STR r6, [r4, #EEBLOCK]
    STR r7, [r4, #EEOFFSET]

    STRB r8, [r4, #EERDWRINC]

EEprom_write_poll:
    LDR r10, [r4, #EEDONE]
    AND r10, r10, #1
    CMP r10, #0
    BNE EEprom_write_poll

    ADD r5, r5, #1
    B EEprom_write_loop

EEprom_write_done:

    CMP r5, #16
    BLT write_block0_2
    MOV r6, #1
    SUB r7, r5, #16
    B write_offset_2

write_block0_2:
    MOV r6, #0
    MOV r7, r5

write_offset_2:
    STR r6, [r4, #EEBLOCK]
    STR r7, [r4, #EEOFFSET]

    STRB r8, [r4, #EERDWRINC]

EEprom_write_poll_2:
    LDR r10, [r4, #EEDONE]
    AND r10, r10, #1
    CMP r10, #0
    BNE EEprom_write_poll_2

    POP{r4-r12, lr}
    mov pc, lr






uart_init:
	PUSH {r4-r12,lr} 		; Store any registers in the range of r4 through r12
							; that are used in your routine.  Include lr if this
							; routine calls another routine.
							; Your code for your uart_init routine is placed here

	;Provide clock to UART0
	MOV r4, #0xE618
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4]

	;Enable clock to PortA
	MOV r4, #0xE608
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4]

	;Disable UART0 control
	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0
	STR r5, [r4]

	;Set UART0_IBRD_R for 115,200 baud
	MOV r4, #0xC024
	MOVT r4, #0x4000
	MOV r5, #8
	STR r5, [r4]

	;Set UART0_FBRD_R for 115,200 baud
	MOV r4, #0xC028
	MOVT r4, #0x4000
	MOV r5, #44
	STR r5, [r4]

	;Use system clock
	MOV r4, #0xCFC8
	MOVT r4, #0x4000
	MOV r5, #0
	STR r5, [r4]

	;Use 8-bit word length, 1 stop bit, no parity
	MOV r4, #0xC02C
	MOVT r4, #0x4000
	MOV r5, #0x60
	STR r5, [r4]

	;Enable UART0 Control
	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0x301
	STR r5, [r4]

	;Make PA0 and PA1 as Digital Ports
	MOV r4, #0x451C
	MOVT r4, #0x4000
	LDR r6, [r4]
	MOV r5, #0x03
	ORR r6, r6, r5
	STR r6, [r4]

	;Change PA0,PA1 to Use an Alternate Function
	MOV r4, #0x4420
	MOVT r4, #0x4000
	LDR r6, [r4]
	MOV r5, #0x03
	ORR r6, r6, r5
	STR r6, [r4]

	;Configure PA0 and PA1 for UART
	MOV r4, #0x452C
	MOVT r4, #0x4000
	LDR r6, [r4]
	MOV r5, #0x11
	ORR r6, r6, r5
	STR r6, [r4]


	POP {r4-r12,lr}   ; Restore registers all registers preserved in the
							; PUSH at the top of this routine from the stack.
	mov pc, lr


output_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

CHECK_FLAG:
	MOV R3, #0xC000    ;move the address of the uart data reg to r3
	MOVT r3, #0x4000

	LDRB r4, [r3,#U0FR]    ;load a byte from the uart flag reg into r4
	MOV r5, #0x20           ; move a mask value 0x20 to r5

	AND r6,r4,r5           ; and the mask and the flag reg byte together

	CMP r6,#0              ;if r6 == 0, proceed, else repeat
	BNE CHECK_FLAG

	STRB r0,[r3]           ;store byte from r0 into the transmit reg
					; routine calls another routine.

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr



read_character:
	PUSH {r4-r12,lr}	; Spill registers to stack

check_flag_read:

	MOV r4, #0xC000
	MOVT r4,#0x4000     ;load address of UART

	LDRB r1, [r4,#U0FR]
	MOV r3, #0x10       ;r3 = mask for RxFe
	AND r2, r1, r3

	CMP r2, #0
	BNE check_flag_read
	LDRB r0, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


read_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

     MOV r7, r0			;r0 = address

check_flag3:

    BL read_character
    MOV r5, r0            ;store char into r5
    BL output_character

    CMP r5, #0xD    ;Enter key
    BEQ read_string_done


    STRB r5, [r7]       ;load char
    ADD r7, r7, #1      ;increment address
    B check_flag3

read_string_done:

    MOV r6, #0
    STRB r6, [r7]   ;null terminate

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


output_string:
	PUSH {r4-r12,lr}	; Spill registers to stack

    MOV r5, r0 ; move the value of r0 to r5
		; Your code for your output_string routine is placed here
output_string_loop:
    LDRB r0, [r5] ; load in r1 the byte at address r0
    ADD r5, r5, #1
    CMP r0, #0
    BEQ output_string_done
    BL output_character
    B output_string_loop

output_string_done:
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readingLCD:
    PUSH {r4-r12, lr}
    ;reset the lcd screen between function calls
		;Clear display (0X01)
	MOV r0, #0x01
	MOV r1, #0x0
	bl lcdSendByte
		;put cursor back to first line
	MOV r0, #0x80
	MOV r1, #0x0
	bl lcdSendByte

    ;init values

                                ;(each line in lcd screen has 16 squares, count to know where to take it to the next line)
    MOV r4, #0                  ;(r4-how many chars have been written to the screen already)

    ldr r5, ptr_to_messbuffer   ;(r5-address where message is stored )

    ;Start reading letters
keepPrintingLcd:
    CMP r4, #16             ;when we write 16 chars to the screen, it's time to go to next line
    BEQ goToNextLine

    ;Print next char
    ldrb r0, [r5]    ;get next char and put as argument
    CMP r0, #0x0
    BEQ endOfPrint   ;if we're at the end, then stop printing
    MOV r1, #1       ;flag argument as char data
    bl lcdSendByte

    ;Increment the lcd counter
    add r4,r4, #1

    ;Increment to the next char address
    add r5, r5, #1

    B keepPrintingLcd

goToNextLine:
    ;move cursor to next line after 16 prints
    MOV r0, #0xc0
    mov r1, #0x0
    bl lcdSendByte

    ;increment the char counter (DO NOT reset the char counter, our wanted behavior is that it just goes off the screen if the message is too long, not overrides the previous line's work)
    add r4,r4,#1

    ;go back to the print loop
    B keepPrintingLcd

endOfPrint:
    POP {r4-r12, lr}
    MOV pc, lr






    .end
