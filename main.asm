list p=16F877A
#include "p16f877a.inc"

	__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC
	
N0 		EQU 0x21
N1 		EQU 0x22
N2 		EQU 0x23
N3 		EQU 0x24

ROW     EQU 0x30
COL     EQU 0x31
INDEX   EQU 0x32

BUTTON_POLL_RATE_MS 	EQU d'150'

DELAY_COUNT 	EQU 0x25
DELAY_INNER 	EQU 0x26

LCD_CLEAR 	EQU b'00000001'
LCD_ON 		EQU b'00001100'
LCD_OFF 	EQU b'00001000'
LCD_CUR_ON 	EQU b'00001111'
LCD_CUR_OFF EQU b'00001100'
LCD_INS_1 	EQU b'00000000'
LCD_INS_2 	EQU b'00000010'
LCD_TXT_1 	EQU b'00000001'
LCD_TXT_2 	EQU b'00000011'
	
	org	0x0000
	goto start
	
start:
	banksel TRISA
	clrf TRISA
	clrf TRISB
	clrf TRISC
	clrf TRISE
	movlw 0xF0
	movwf TRISD
	
	banksel OPTION_REG
	movlw b'11000010'
	movwf OPTION_REG
	
	banksel PORTA
	clrf PORTA
	clrf PORTB
	clrf PORTC
	clrf PORTD
	clrf PORTE

	call LCD_INIT
	call LCD_WELCOME
	
main:
ROW0:
    movlw b'00001110'
    movwf PORTD
    movlw 0
    movwf ROW
    call SCAN_ROW

ROW1:
    movlw b'00001101'
    movwf PORTD
    movlw 1
    movwf ROW
    call SCAN_ROW

ROW2:
    movlw b'00001011'
    movwf PORTD
    movlw 2
    movwf ROW
    call SCAN_ROW

ROW3:
    movlw b'00000111'
    movwf PORTD
    movlw 3
    movwf ROW
    call SCAN_ROW

    goto main

LCD_INIT:
	banksel PORTB

	movlw LCD_INS_1
	movwf PORTB

	movlw LCD_ON
	movwf PORTC

	movlw LCD_INS_2
	movwf PORTB

	nop

	movlw LCD_INS_1
	movwf PORTB

	movlw d'255'
	call delay_ms

	return

LCD_CLR:
	banksel PORTB

	movlw LCD_INS_1
	movwf PORTB

	movlw LCD_CLEAR
	movwf PORTC

	movlw LCD_INS_2
	movwf PORTB

	nop

	movlw LCD_INS_1
	movwf PORTB

	movlw d'2'
	call delay_ms

	return

LCD_WELCOME:
	movlw 'W'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw 'e'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw 'l'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw 'c'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms
	
	movlw 'o'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw 'm'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw 'e'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw '.'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw '.'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw '.'
	call PRINT_CHAR
	movlw d'100'
	call delay_ms

	movlw d'1'
	call delay_sec

	call LCD_CLR

	goto main

PRINT_CHAR:
    movwf PORTC

	movlw b'11111111'
	movwf PORTD

    movlw LCD_TXT_1
    movwf PORTB
    movlw LCD_TXT_2
    movwf PORTB
    nop
    movlw LCD_TXT_1
    movwf PORTB

    return

GET_KEY:
    addwf PCL, f
    retlw '1'
    retlw '2'
    retlw '3'
    retlw 'A'
    retlw '4'
    retlw '5'
    retlw '6'
    retlw 'B'
    retlw '7'
    retlw '8'
    retlw '9'
    retlw 'C'
    retlw '*'
    retlw '0'
    retlw '#'
    retlw 'D'

GET_COL:
    btfss PORTD,4
        retlw 0
    btfss PORTD,5
        retlw 1
    btfss PORTD,6
        retlw 2
    btfss PORTD,7
        retlw 3
    retlw 0xFF    ; default

SCAN_ROW:
    call GET_COL
    movwf COL
    movlw 0xFF
    xorwf COL, w
    bz NO_KEY

    ; index = row * 4
    movf ROW, w
    addwf ROW, w      ; row * 2
    movwf INDEX
    movf INDEX, w
    addwf INDEX, w    ; row * 4

    ; index += col
    addwf COL, w
    movwf INDEX

    movf INDEX, w
    call GET_KEY
    call PRINT_CHAR

    movlw BUTTON_POLL_RATE_MS
    call delay_ms

NO_KEY:
    return

delay_ms:
	banksel DELAY_COUNT
	movwf DELAY_COUNT
delay_ms_loop:
	movlw d'5'
	movwf DELAY_INNER
delay_ms_inner:
	banksel TMR0
	movlw d'6'
	movwf TMR0
	bcf INTCON, T0IF
wait_tmr0:
	btfss INTCON, T0IF
	goto wait_tmr0
	decfsz DELAY_INNER, f
	goto delay_ms_inner
	decfsz DELAY_COUNT, f
	goto delay_ms_loop
	return

delay_sec:
	banksel DELAY_COUNT
	movwf DELAY_COUNT
delay_sec_loop:
	movlw d'250'
	call delay_ms
	movlw d'250'
	call delay_ms
	movlw d'250'
	call delay_ms
	movlw d'250'
	call delay_ms
	banksel DELAY_COUNT
	decfsz DELAY_COUNT, f
	goto delay_sec_loop
	return

	end
