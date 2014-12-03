;=================================
; 
; Delay procedure
; By Aleksey Leshchuk 
; CISP310
; CALL with number of ticks to delay
; in AL reg.
; 
;======================================

    .MODEL SMALL
    .STACK 256
	

    .CODE  tickDelay
	DELAY PROC FAR PUBLIC USES AX CX DX

	    PUSHF		; push all flags
	    CALL    GETTIME
	    ADD	    AL,DL	; ADD current time to number of ticks to delay
	delayLoop:
	    CALL    GETTIME	; GET current time into DL
	    .if	    AL>DL
	    JMP	    delayLoop
	    .endif

	    POPF		; restore flags
	    RET
    DELAY   ENDP

;=============================
;
; GETIME Procedure
; gets system time and stores
; lower byte in DL
;
;=============================

    GETTIME PROC FAR PUBLIC USES AX CX
	
	PUSHF		; PUSH all flags
	MOV	AX,0000H
	INT	1AH	; call read system time
	XOR	DH,DH	; XOR out higher DX byte
	POPF 
	RET
GETTIME ENDP

	END

