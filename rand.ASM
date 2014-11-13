    
;===================================================================
;                   RAND.ASM
;      r a n d o m   n u m b e r   g e n e r a t o r
;
; GENERATES PSEUDO-RANDOM INTEGERS IN THE RANGE LOWER TO UPPER
; INPUT:  TWO STACK PARAMETERS - LOWER AND UPPER ENDS OF RANGE
; OUTPUT: AX-REG CONTAINS RANDOM INTEGER
; CALLING SEQUENCE:     PUSH    <LOWER END OF RANGE>
;                       PUSH    <UPPER END OF RANGE>
;                       CALL    RANDOM
;===================================================================
           .MODEL  SMALL,BASIC
;===================================================================
FALSE      EQU     0                   ;CONSTANT FALSE
TRUE       EQU     1                   ;CONSTANT TRUE
;===================================================================
; D A T A   S E G M E N T   D E F I N I T I O N
           .FARDATA RAND_DATA
SEED       DW      ?                   ;SEED FOR RANDOM NUMBER GEN.
MULTIPLIER DW      25173               ;MULTIPLIER AND
ADDEND     DW      13849               ;ADDEND FOR MIXED
                                       ;LINEAR CONGRUENTIAL METHOD
;===================================================================
; C O D E   S E G M E N T   D E F I N I T I O N
;
           .CODE   RAND
           ASSUME  DS:RAND_DATA
;
RANDOM     PROC    FAR PUBLIC USES CX DX DS,
                   LOWER:WORD, UPPER:WORD
                                    ;FUNCTION RANDOM(LOWER,UPPER)
                                       ;SAVE REGISTERS (USES LIST)
           PUSHF                       ;SAVE FLAGS
           MOV     AX,SEG RAND_DATA    ;SET DS-REGISTER TO POINT
           MOV     DS,AX               ;TO LOCAL DATA SEGMENT
           MOV     AX,SEED             ;X = SEED * MULTIPLIER mod
           MUL     MULTIPLIER          ;                       65536
           ADD     AX,ADDEND           ;SEED = (X + ADDEND) mod 65536
           MOV     SEED,AX
           MOV     CX,UPPER            ;RANGE = UPPER - LOWER + 1
           SUB     CX,LOWER
           INC     CX
           MUL     CX                  ;RANDOM = (SEED*RANGE)/65536
           ADD     DX,LOWER            ;                    + LOWER
           MOV     AX,DX
           POPF                        ;RESTORE FLAGS
                                       ;RESTORE REGISTERS (ASSEMBLER
                                       ;   GENERATES INSTRUCTIONS TO
                                       ;   RESTORE REGISTERS - USES)
           RET                         ;RETURN (RANDOM)
RANDOM     ENDP                     ;END RANDOM

;=======================================
; RESEED for RANDOM
; if BX is 0, seed with lower word of system time
; if BX is 1 or more, seed with number in AX reg
;=======================================

RESEED	    PROC    FAR PUBlIC USES DX DS CX	    ; Save DX reg to restore later

	    PUSHF			    ; Save flags
	    PUSH    AX			    ; Save value of AX to initialize DATA SEGMENT
	    MOV	    AX,RAND_DATA
	    MOV	    DS,AX
	    POP	    AX			    ; restore AX
	    CMP	    BX,0
	    JE	    SeedTime		    ; if B == 0, seed with lower word of time(DX)
	    CMP	    BX,1		    
	    JGE	    SeedAX		    ; if BX is set to 1, seed with value in AX
	SeedTime:
	    MOV	    AH,00H 
	    INT	    1AH			    ; get system time into CX:DX reg
	    MOV	    SEED,DX		    ; Seed RANDOM using lower bit of sys time
	    JMP	    Return
	SeedAX:
	    MOV	    SEED,AX		    ; Seed RANDOM using value in AX
	Return:
	    POPF			    ; return flags to state before subproc
	    RET
	    
RESEED      ENDP
           END
