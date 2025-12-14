    .data

    .global project8
    .global buzzer_init
    .global buzz_sound


    .text

RCGCGPIO:                   .equ 0x608
DIR: 		                .equ 0x400              ;direction reg, 1 - output, 0 - input
DEN: 		                .equ 0x51C              ;digital enable reg, 1 - enable
GPIOASFSEL:                 .equ 0x420              ;GPIO Alternate Function Select
GPIOPCTL:                   .equ 0x52C              ;GPIO Port Control

RCGCTIMER:                  .equ 0x604                  
GPTMCTL:                    .equ 0x00C
GPTMCFG:                    .equ 0x000
GPTMTAMR:                   .equ 0x004
GPTMTAILR:     	            .equ 0x028

project8:
    PUSH{r4-r12, lr}

    BL buzzer_init
    BL buzz_sound


infinite_loop:


    B infinite_loop




    POP{r4-r12, lr}
    mov pc, lr





buzzer_init:    
    PUSH{r4-r12, lr}

    ;Enable clock to port C, (PC4)
    MOV r4, #0xE000
    MOVT r4, #0x400F                        ;Base address of clock gating
    MOV r5, #0x4                            
    STR r5, [r4, #RCGCGPIO]

    ORR r10, r10, r10
	ORR r10, r10, r10
	ORR r10, r10, r10               ;NOPS

    MOV r4, #0x6000
    MOVT r4, #0x4000           ;port C base address
    MOV r6, #0x10              ;pin 4

    ;enable output
    LDR r6, [r4, #DIR]
    ORR r6, r6, r5
    STR r6, [r4, #DIR]         ;store 1 into (pin 4 and 7) - output

    ;enable digital
    LDR r6, [r4, #DEN]
    ORR r6, r6, r5
    STR r6, [r4, #DEN]         ;store 1 into (pin 4 and 7) - digital

    ;Enable alternate function
    LDR r6, [r4, #GPIOASFSEL]
    ORR r6, r6, r5
    STR r6, [r4, #GPIOASFSEL]   ;GPIO Pins Alternate Function Mode

    ;GPIOCTL to use SPI function
    MOV r6, #0x6000
    MOVT r6, #0x4000            ;Port C base address
    LDR r5, [r6, #GPIOPCTL]
    MOV r7, #0x0000
    MOVT r7, #0x000F
    BIC r5, r5, r7
    MOV r7, #0x0000
    MOVT r7, #0x0007            ;pin 4 (16-19)
    ORR r5, r5, r7              ;store 7 to use WT0CCP0
    STR r5, [r6, #GPIOPCTL]     ;

	;Timer1A
	MOV r1, #0xE000
	MOVT r1, #0x400F
    MOV r2, #0x2

    LDR r3, [r1, #RCGCTIMER]        ;Enable clock
    ORR r3, r3, r2
    STR r3, [r1, #RCGCTIMER]

    MOV r1, #0x1000
    MOVT r1, #0x4003
    MOV r4, #0

    LDR r3, [r1, #GPTMCTL]          ;Disable timer
    BFI r3, r4, #0, #1
    STR r3, [r1, #GPTMCTL]

	LDR r3, [r1, #GPTMCFG]          ;Set up timer
    BFI r3, r4, #0, #3              ;(0 configuration)
    STR r3, [r1, #GPTMCFG]

	MOV r2, #0x12

    LDR r3, [r1, #GPTMTAMR]          ;Setup timer for 32 bit
    ORR r3, r3, r2
    STR r3, [r1, #GPTMTAMR]

	;10000
    MOV r2, #0x4000
    MOVT r2, #0xF2                  ;16M    
    LDR r3, [r1, #GPTMTAILR]		;GPTMTAILR ticks per interrupt
    AND r3, r3, r2
    STR r2, [r1, #GPTMTAILR]


    POP{r4-r12, lr}
    mov pc, lr


buzz_sound: 
    PUSH{r4-r12, lr}

    MOV r4, #0x1000
    MOVT r4, #0x4003                 ;Timer 1A base

	LDR r9, [r1, #GPTMCTL]
	ORR r9, r9, #0x1
	STR r9, [r1, #GPTMCTL]          ;enable timer

    MOV r5, #0x1200
    MOVT r5, #0x7A                  ;8 mill

buzz_loop:
    SUBS r5, r5, #1

    CMP r5, #0
    BNE buzz_loop

    MOV r1, #0x1000
    MOVT r1, #0x4003
    MOV r4, #0

    LDR r3, [r1, #GPTMCTL]          ;Disable timer
    BFI r3, r4, #0, #1
    STR r3, [r1, #GPTMCTL]


    POP{r4-r12, lr}
    mov pc, lr

.end
