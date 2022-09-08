;**************** 4-bit ALU *************
; 4-bit input data P (P0.3 to P0.1)  in R0
; 4-bit input data Q (P0.3 to P0.1)  in R1  
; 2-bit Control input S1, S0 (P1.1, P1.0) in R2
;S1S0 -> 00 - Addition (P + Q)
;S1S0 -> 01 - Subtraction (P - Q)
;S1S0 -> 10 - Logical AND  (P AND Q) 
;S1S0 -> 11 - Logical OR    (P OR Q).
;Result on P2.4 to P2.0
;*******************************************
        ORG		00h
		SJMP	main
		
;************** Main routine begins ***********
		ORG		64h
MAIN:
        ACALL   INIT
CONTINUE:
        ACALL   READ_CI
        ACALL   DAC1
        ACALL   DELAY1
        SJMP    CONTINUE
;************** Main routine ends **************
INIT:
        ; Configure Port 0 and 1 as inputs
        MOV     P1, #0xFF
        ; Amplitude - DIgital equivalent in R0 and R1
        MOV     R0, #0x7
        MOV     R1, #0x4
        RET
READ_CI:
        ;Read control inputs from Port-1 to R2
        MOV     A, P1
        ANL     A, #0x3
        MOV     R2, A
        RET 
DAC1:
        ;As per the control inputs in R2 
        ;Generate Waveform
        CJNE    R2, #0x0, N1
        ACALL   SQU
        RET
N1:
        CJNE    R2, #0x1, N2
        ACALL   TRI
        RET
N2:     
        CJNE    R2, #0x2, N3
        ACALL   SawRise
        RET
N3:     
        ACALL   SawFall
        RET 
        ;square wave generation 
SQU:
        MOV     P0, R1
        ACALL   DELAY1
        MOV     P0, R0
        ACALL   DELAY1
        RET
        ;Triangular Wave generation
TRI:    
        MOV     R3, 0x1
RiseEdge:
        MOV     P0, R3
        INC     R3
        ACALL   DELAY1
        MOV     A, R3
        SUBB    A, R0
        JC     RiseEdge
FallEdge:        
        DEC     R3
        ACALL   DELAY1
        MOV     P0, R3
        MOV     A, R3
        SUBB    A, R1
        JNC     FallEdge      
        RET
 
        ;Sawtooth waveform generation
SawRise:
        MOV     R3, 0x1
SawRiseEdge:
        MOV     P0, R3
        ACALL   DELAY1
        INC     R3
        MOV     A, R3
        SUBB    A, R0
        JC     SawRiseEdge 
        RET
        
        ;Sawtooth waveform generation. 
SawFall:
        MOV     R3, 0x0
SawFallEdge:
        MOV     P0, R3
        ACALL   DELAY1
        DEC     R3
        MOV     A, R3
        SUBB    A, R1
        JNC     SawFallEdge 
        RET
        
        ;Delay subroutine. 
DELAY1:
        DJNZ    R6, DELAY1
        DJNZ    R7, DELAY1
        DJNZ    R5, DELAY1
        RET
      
        END
