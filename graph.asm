;=======================================
; 
; graphics assignment 
; Aleksey Leshchuk
; CISP310
;
;======================================

    .286
    .MODEL SMALL
    .STACK 256
    
    EXTRN   DELAY:FAR 
    EXTRN   PUTDEC$:FAR

    .DATA
	border	DB  960 DUP(5H)	    ; top border color 5H, 3 lines
;		DB  194 DUP(3 DUP(5H), 324 DUP(7H), 3 DUP(5h))	; side borders, 194 lines
;		DB  960 DUP(5H)	    ; bottom border, 3 lines

	loopvar dw 0
	pause DB 10,13,'BYE$'

    
    .CODE
	ASSUME	    DS:DGROUP
	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX
	    MOV	    AX,0012H
	    INT	    10H		    ; set video mode to 16 color 320x200
	    XOR	    CX,CX
	    XOR	    DX,DX	    ; zero out y and x 
	    XOR	    BX,BX	    ; beginning of pixel array

	drawLine:
	    MOV	    AL,border[BX]   ; current pixel
	    MOV	    AH,0CH	; output pixel
	    PUSH    BX
	    MOV	    BX,0	; video page
	    POP	    BX 
	    int 10h		; output pixel
	    INC	    CX		; increment X 
	    .if	    CX>320	; if end of screen reached
	    XOR	    CX,CX	; reset CX
	    INC	    DX		; inc Y
	    .endif
	    .if	    DX==3 && CX==320
	    JMP	    quit
	    .endif
	    INC	    BX		; inc pixel array pointer
	    JMP	    drawLine
	   
	quit:
	    MOV	AL,55
	    CALL delay
	    ;MOV	    AX,0007H
	    ;int 10H	; return to video mode1
	    MOV	    AX,4c00H
	    int 21H

	END main
