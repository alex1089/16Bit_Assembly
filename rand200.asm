;==============================================
;
; Aleksey Leshchuk
; Call reseed and random*200
; 
;==============================================

    .MODEL SMALL    
    .STACK 256

;==============================================
; 
; Externals
;
;==============================================

    EXTRN PUTDEC$:FAR	    ; print unsigned dec in AX
    EXTRN NEWLINE:FAR
    EXTRN RANDOM:FAR	    ; PUSH lower, upper.
    EXTRN RESEED:FAR	    ; Seed RANDOM with time if BX=0, Seed with AX is 1

	.DATA
	LOWER	DW  0
	UPPER   DW  9999
	ODD	DW  0
	EVN	DW  0
	LW	DW  0
	HGH	DW  0
	TWO	DW  2
	
	ODD_OUT DB  '    ODD = $' 
	EVE_OUT DB  '    EVEN = $' 
	LOW_OUT DB  '    LOW = $' 
	HIGH_OUT DB  '    HIGH = $' 
	PAUSE   DB  '          PRESS ANY KEY TO EXIT. By Aleksey Leshchuk $' 



	.CODE
	ASSUME DS:DGROUP
	start:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX		; initialize DATA to DS 

	    MOV	    BX,1		; first 100, seeded with 555h
	    MOV	    AX,5555H		; SEED random with 555H
	    MOV	    CX,0		; init counter to 0
    CallReseed:
	    CALL    RESEED
	Loop1:
	    PUSH    LOWER
	    PUSH    UPPER
	    CALL    RANDOM		; Call RANDOM
	    MOV	    BH,1		; right justify for GETDEC$
	    CALL    PUTDEC$
	    INC	    CX
	    MOV	    BX,10		
	    PUSH    AX			; Save AX to test for LOW,HIGH,ODD,EVEN
	    MOV	    AX,CX   
	    MOV	    DX,0		; zero out DX for division
	    DIV	    BX			; CX/10
	    .IF	    DX == 0		; if remainder is 0, print newline
	    CALL    NEWLINE
	    .ENDIF

	    POP	    AX
	    .IF	    AX<5000		; if number generated is 4999, LW++
	    INC	    LW
	    .ELSE
	    INC	    HGH			; else HGH++
	    .ENDIF 

	    MOV	    DX,0		; zero out DX for DX:AX division
	    DIV	    TWO			; divide by 2
	    .IF	    DX==1		; if remainder is 1, ODD++
	    INC	    ODD
	    .ELSE			; else EVN++
	    INC	    EVN
	    .ENDIF
	    .IF	    CX<100
	    JMP	    Loop1
	    .ENDIF			; loop until CX reaches 100
	    .IF	    CX==100
	    MOV	    BX,0
	    JMP	    CallReseed		; on 100th call, set BX to 0 to reseed to sys time
	    .ENDIF
	    .IF	    CX<200
	    JMP	    Loop1		; loop until counter is 200
	    .ENDIF
	    
	    LEA	    DX,EVE_OUT		; LEA of EVE_OUT, print until $ is met
	    MOV	    AH,09H
	    INT	    21H
	    MOV	    AX,EVN		; output count of even numbersk
	    CALL    PUTDEC$

	    LEA	    DX,ODD_OUT		; LEA of ODD_OUT
	    MOV	    AH,09H		; print string until $ is met
	    INT	    21H
	    MOV	    AX,ODD
	    CALL    PUTDEC$		; Print count of odd numbers
	    
	    LEA	    DX,HIGH_OUT		; LEA of HIGH_OUT
	    MOV	    AH,09H
	    INT	    21H			; print until $ is met
	    MOV	    AX,HGH
	    CALL    PUTDEC$
		
	    LEA	    DX,LOW_OUT		; LEA LOW_OUT
	    MOV	    AH,09H
	    INT	    21H			; Print string until $ is met
	    MOV	    AX,LW
	    CALL    PUTDEC$
	return:
	    .EXIT 

	END start

