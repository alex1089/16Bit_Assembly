;======================================== 
; 
;  By Aleksey Leschuk
;  CISP310
;
;=========================================

    .MODEL small
    .STACK 256
    .386

    EXTRN   GETDEC$:FAR	    ; Get decimal, store in AX
    EXTRN   PUTSTRNG:FAR    ; Print string in ES:DI register of CX bytes long
    EXTRN   PUTDEC$:FAR	    ; Prints decimal in AX
    EXTRN   BLANKS:FAR	    ; Print DX blanks at current position
    EXTRN   NEWLINE:FAR	    ; prints newline

;=========================================
; 
; Data definition
;
;=========================================
    
    .DATA
	INTRO	DB  'Enter a to see its Ulams pattern '
	ERR	DB  '        ERROR: Overflow occured on element '
	RSLT1	DB  '    Done! There are '
	RSLT2   DB  ' elements in Ulams pattern of number '
	SPACE	DB  '              '
	PAUSE   DB  '        Programmed by: Aleksey Leshchuk PRESS ANY KEY TO EXIT'
	ORIGINP DW  ?

    .CODE

    Ulams:
	MOV	AX,DGROUP   ; initialize ES with DGROUP
	MOV	ES,AX
	
	LEA	DI,INTRO    ; LEA of string to print
	MOV	CX,34	    ; call PUTSTRING and print 34 bytes
	CALL	PUTSTRNG

	MOV	CX,1	    ; initialize counter to 0
	CALL	GETDEC$	    ; get decimal as starting point for pattern
	MOV	ORIGINP,AX  ; Save starting number in sequence
	CALL	NEWLINE
    Cycle:
	CALL	PUTDEC$
	MOV	DX,1	    ; print one blank space
	CALL	BLANKS
	PUSH    AX	    ; Save AX incase number is odd and needs to be restored
	CMP	AX,1	    ; if number in sequence is 1, return
	JE	Return
	
	mov	bx,2
	MOV     DX,0	    ; extend AX into DX
	DIV     BX	    ; divide AX/2
	CMP	DX,1 
	JE	Odd	    ; if remainder is 1, number is odd, Jump to Odd
    Evn: 
	INC	CX	    ; increment sequence counter
	JMP	Cycle	    ; Jump to top of Cycle, element is even, already divided
    Odd:
	POP	AX	    ; restore AX to prior to dividing state in cycle
	INC	CX	    ; Increment counter
	MOV	Bx,3
	MUL	Bx	    ; Multiply by 3

	JC	Error	    ; Jump to error if overflow occurs
	ADD	AX,1
	JC	Error	    ; Add 1, Jump to error if overflow occurs
	JMP	Cycle	    ; Jump to beginning of Cycle
	
	
    Error: 
	MOV	AX,CX	    ; Save element counter to be displayed
	CALL	NEWLINE
	LEA	DI,ERR	    ; LEA of error message to be displayed
	MOV	CX,44
	CALL	PUTSTRNG    ; Print 39 bytes
	CALL	PUTDEC$	    ; Print number of elements
	CALL	NEWLINE

	LEA	DI,PAUSE    ; LEA of pause message
	MOV	CX,61
	CALL	PUTSTRNG    
	CALL	GETDEC$	    ; PAUSE Screen

	MOV	AX,4C00H    ; return 0
	INT	21H
	
    Return:
	CALL	NEWLINE
	PUSH	CX	    ; Save counter reg
	LEA	DI,RSLT1    ; first part of output
	MOV	CX,20	    ; print 20 bytes 
	CALL    PUTSTRNG
	POP	AX	    ; Restore saved CX counter into AX
	CALL	PUTDEC$	    ; Print amount of elements in sequence
	LEA	DI,RSLT2    ; Print second part of results
	MOV     CX,37
	CALL	PUTSTRNG
	MOV	AX,ORIGINP  ; print starting number of sequence
	CALL	PUTDEC$
        
	CALL	NEWLINE
	LEA	DI,PAUSE    ; LEA of pause message
	MOV	CX,61
	CALL	PUTSTRNG    
	CALL	GETDEC$	    ; PAUSE Screen
	.exit
    END Ulams

