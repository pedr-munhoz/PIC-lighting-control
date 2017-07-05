#include "p16f873a.inc"

; CONFIG
; __config 0xFF39
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF


CBLOCK 0x20
    TICS
    SEC
    DIST_MULT
    AUX
    TRIGGER
ENDC
    
ORG 0
    GOTO Start
ORG 4
    BANKSEL INTCON
    BTFSS INTCON, TMR0IF
    GOTO Loop
    
    BTFSC TRIGGER, 0
    GOTO S2
    
S1:
    DECFSZ TICS, 1
    GOTO Loop2
    
    MOVLW d'62'
    MOVWF TICS
    
    INCF SEC, 1
    GOTO Loop2
    
S2:
    DECFSZ TICS,1
    GOTO Loop5
    
    MOVLW d'62'
    MOVWF TICS
    
    DECFSZ SEC,1
    GOTO Loop5
    
    MOVLW d'0'
    ADDWF AUX, 0	; W = AUX
    MOVWF SEC		; SEC = AUX
    
    DECFSZ DIST_MULT,1
    GOTO Loop5
    
    GOTO Loop
    
    RETFIE
 
Start:
    BANKSEL TRISB	
    MOVLW b'11111110'
    MOVWF TRISB		; RB[1-7] = input RB[0] = OUTPUT
    
    BANKSEL OPTION_REG
    MOVLW b'10000101'
    MOVWF OPTION_REG	; configuração do timer
    
    BANKSEL TMR0
    MOVLW d'131'
    MOVWF TMR0
    
Loop:
    BANKSEL INTCON
    MOVLW b'10000000'
    MOVWF INTCON	; deactivate timer based interruption
    
Loop3:  
    BANKSEL PORTB
    BTFSC PORTB, RB1	; read RB[1] pin
    GOTO Delay		; if the RB[1] is active, jumps to the delay routine
    
Off:
    BCF PORTB, RB0	; RB[0] = 0
    GOTO Loop3
    
    
Delay:
    BANKSEL PORTB
    BSF PORTB, RB0	; RB[0] = 1
    
    MOVLW d'0'
    MOVWF AUX
    
    MOVLW d'0'
    MOVWF SEC
    
    MOVLW d'62'
    MOVWF TICS
    
    MOVLW d'0'
    MOVWF TRIGGER
    
    MOVLW d'2'
    MOVWF DIST_MULT
    
Loop2:
    BANKSEL INTCON
    MOVLW b'10100000'
    MOVWF INTCON	; activate timer based interruption
    
Loop4:
    BANKSEL PORTB
    BTFSS PORTB, RB2	; read RB[2] pin
    GOTO Loop4		; if the RB[2] iS active,
    
    MOVLW d'1'
    MOVWF TRIGGER
    
    MOVLW d'0'
    ADDWF SEC, 0	; W = SEC
    MOVWF AUX		; AUX = SEC
    
Loop5:
    BANKSEL INTCON
    MOVLW b'10100000'
    MOVWF INTCON	; activate timer based interruption
    
    GOTO $
    
end