; =================================================
; Program to convert Celsius to Farenheit
; Takes input from operator and outputs converted
; farenheit value
;
; By: Aleksey Leshchuk
; 9/25/14
; CISP310
; = = = = = = = = = = = = = = = = = = = = = = = = =  

    .MODEL SMALL, NEARSTACK
    .386

    EXTRN   GETDEC:FAR	    ; Get decimal from user, store in AX
    EXTRN   NEWLINE:FAR	    ; \n
    EXTRN   PUTSTRNG:FAR    ; Print string, 46 bytes long, in ES:DI
    EXTRN   PUTDEC:FAR	    ; Prints signed decimal in AX reg

; ===============================================
;
; Define stack size
;
; ===============================================
    
    .STACK 256

; ==============================================
; 
; Define DATA segment
; 
; ==============================================

    .DATA
	REQINP	DB  '  Enter celsius temperature value to convert: '
	OUTPUT	DB  '  The temperature in farenheit is '
	PAUSE	DB  '      Programmed by: Aleksey Leshchuk PRESS ANY KEY TO CONTINUE'

; ==============================================
;
; Code Segment
;
    .CODE
    ASSUME ES:DGROUP
CtoFConv:
	MOV	AX,DGROUP	; ES register to point to DSGROUP
	MOV	ES,AX

	LEA	DI,REQINP	; LEA of REQINP offset
	MOV	CX,46		; print 46 bytes
	mov	AX,hi
	call PUTdec
	CALL	PUTSTRNG	; Call to print string
	CALL    GETDEC		; Get C value from user
	CALL	NEWLINE

	MOV	BX,9		; input*9
	IMUL	AX,BX
	MOV	BX,5
	CWD			; Convert ax to word dx:ax for division
	IDIV	BX		; Input*9/5
	PUSH	AX		; push result to stack

	MOV	AX,DX		; process remainder
	CWD
	MOV	BX,3		; copy remainer to AX,	
	IDIV	BX		; divide by 3, add quotient 
	MOV	DX,AX		; input*9/5+(rounded remainder)
	POP	AX		; restore AX from stack
	ADD	AX,DX
	
	ADD	AX,32		; add to result input*9/5+rounding+32

	MOV	CX,34		; print 34 bytes starting at OUTPUT offset
	LEA	DI,OUTPUT
	CALL	PUTSTRNG 
	CALL	PUTDEC
	
	CALL	NEWLINE
	Call	NEWLINE
	MOV	CX,65		; pause screen, print name, any key to continue
	LEA     DI,PAUSE
	CALL	PUTSTRNG
	CALL	GETDEC 
	.EXIT
	END CtoFConv
	   

