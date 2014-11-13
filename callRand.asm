;=================================================
;
; By aleksey Leshchuk, call random 200 TIMES with reseed
; CISP310
; 10/4/14
; 
;=================================================

    .MODEL SMALL
    .STACK 256
    .386

    EXTRN  NEWLINE:FAR		; Prints newline
    EXTRN  PUTDEC$:FAR		; Prints unsigned decimal in AX
    EXTRN  RANDOM:FAR		; push lower,upper, call random
    EXTRN  RESEED:FAR		; Reseed RANDOM with time is BX is 0, with AX if BX
    EXTRN  GETDEC:FAR

    .CONST
	PAUS DB	      '         Press any key to continue. BY ALEKSEY LESHCHUK','$'
	; PAUSE constant with newline char in beginning
;=================================================
;
;   CODE
;
;=================================================
    
	    ASSUME DS:DGROUP 
.CODE
    init:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX
	    MOV	    CX,0	;initialize counter reg to 0
	    MOV	    BX,1	; seed with value in AX
	    MOV	    AX,5555h
	    CALL    RESEED
    call_random:
	    MOV	    AX,0
	    PUSH    AX		; push lower bound of 1
	    MOV	    AX,9999
	    PUSH    AX		; push upper bound of 52
	    CALL    RANDOM	; Call random
	    CALL    PUTDEC$	; print unsigned AX reg
	    CALL    NEWLINE
	    INC	    CX		; inrement counter
	    CMP	    CX,5
	    JL	    call_random	; if counter reg is less than 5, loop back to call_random
    return:
	    LEA	    DX,PAUS
	    MOV	    AH,09H	; print c style string

	    INT	    21H		; system function to print to stdout
	    CALL    GETDEC	; wait for user input

	    MOV	    AX,4C00H	
	    INT	    21H		; return 0
    END init


    
