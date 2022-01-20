;LAB 2 MORSE CODE
;REGISTER R16 = IN/UT-ARGUMENT FÖR TABELLERNA
;R17 = INARGUMENT FÖR BEEPRUTINERNA (N,2N...)
	jmp		NEXT

;BEEP HASTIGHET (HÖGRE VÄRDE -> LÅNGSAMMARE)
	.equ	SPEED = 3

;-----------------------------------------------------------------
; set stack
NEXT:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	
	call	INIT
	jmp		MAIN

;ABCDEF
;GHIJKL
;MNOPQR
;STUVWX
;YZ0123
;456789
	.org	$0300
BTAB:
	.db 0b01100000,0b10001000,0b10100000,0b10010000,0b01000000,0b00101000, \
		0b11010000,0b00001000,0b00100000,0b01111000,0b10110000,0b01001000, \
		0b11100000,0b10100000,0b11110000,0b01101000,0b11011000,0b01010000, \
		0b00010000,0b11000000,0b00100000,0b00010000,0b01100000,0b10011000, \
		0b10111000,0b11001000,0b11111100,0b01111100,0b00111100,0b00011100, \
		0b00001100,0b00000100,0b10000100,0b11000100,0b11100100,0b11110100, \
		$00, $00

	.org	$0400
ALPHABET:
	.db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",$00, $00	;Extra characters .,?/@1234567890

	.org	$0500
TEXT:
	.db "TAITA693 TAITA693 TAITA693",$00




;DELUPPGIFT 2
MAIN:
	ldi		ZH,HIGH(TEXT*2)
	ldi		ZL,LOW(TEXT*2)
GET_NEXT:
	lpm		r16,Z+				;r16 argument till LOOKUP, r17 utargument med binärkodning
	cpi		r16,0
	breq	MAIN_END
	cpi		r16,' '
	breq	TEXT_SPACE

	call	LOOKUP
	call	SEND
	ldi		r18,2
	call	NOBEEP
	jmp		GET_NEXT
MAIN_END:						;Wait 7 time units before morsing again (space)
	ldi		r18,7
	call	NOBEEP

	jmp		MAIN
TEXT_SPACE:
	ldi		r18,4
	call	NOBEEP

	jmp		GET_NEXT




;SEND FUNCTION
SEND:
		push	r17
		push	r18
		clc
	LOOP_START:
		lsl		r17
		
		breq	END
		brcs	CALL_LONG_BEEP
		jmp		CALL_SHORT_BEEP
	

	CALL_LONG_BEEP:
		ldi		r18,3		;argument till beep
		call	BEEP
		ldi		r18,1
		call	NOBEEP
		clz
		clc
		jmp		LOOP_START

	CALL_SHORT_BEEP:
		ldi		r18,1
		call	BEEP
		ldi		r18,1
		call	NOBEEP
		clz
		clc
		jmp		LOOP_START

	END:
		pop		r17
		pop		r18
		ret



;LOOKUP FUNCTION 
LOOKUP:
		push	r16
		push	r18
		clr		r18
		push	ZH
		push	ZL

		ldi		ZH,HIGH(ALPHABET*2)
		ldi		ZL,LOW(ALPHABET*2)
	LOOP3:
		lpm		r17,Z+
		inc		r18
		cp		r17,r16
		brne	LOOP3

		ldi		ZH,HIGH(BTAB*2)
		ldi		ZL,LOW(BTAB*2)
		dec		r18
		add		ZL,r18				;No carry needs to be handled as the table is small enough
		lpm		r17,Z


		pop		ZL
		pop		ZH
		pop		r18
		pop		r16
		ret
;call INIT
;
; ----Init. Pinnar on C in, B3-B0 out
INIT:
		clr		r16
		out		DDRC, r16	; <----
		ldi		r16, $F0
		out		DDRB, r16
		ret

;
;NOBEEP will not beep for 20 ms times the number in argument
NOBEEP:
		push	r16
		push	r18

		cbi		PORTB,4
	LOOP_ARG2:
		ldi		r16,3
	LOOP1:
		call	DELAY
		dec		r16
		brne	LOOP1
		dec		r18	
		brne	LOOP_ARG2

		pop		r18
		pop		r16
		ret

;
;BEEP will beep for 20 ms times the number in argument
BEEP:
		push	r16
		push	r18

		sbi		PORTB,4

	ARG_LOOP1:
		ldi		r16,3
	LOOP2:
		call	DELAY
		dec		r16
		brne	LOOP2
		dec		r18
		brne	ARG_LOOP1

		pop		r18
		pop		r16
		ret


;
;DECREMENTS LOOP 256*256*2 (r16*r17*r18) times eqv. of
;24 ms at 16 MHz
DELAY:
		push	r18
		push	r17 
		push	r16

		ldi		r18, SPEED
	D_3:
		ldi		r17, 0
	D_2:
		ldi		r16, 0
	D_1:
		dec		r16
		brne	D_1
		dec		r17
		brne	D_2
		dec		r18
		brne	D_3

		pop		r16
		pop		r17
		pop		r18
		ret
