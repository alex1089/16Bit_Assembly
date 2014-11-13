;==============================================
; Aleksey Leshchuk
; parity driver program
; CISP310 
;  - Accepts input from operator
;  - calls parity subP to return number of on bits
;==============================================
 
    .MODEL SMALL
    .STACK 256
    EXTRN   PARITY:FAR	    ; counts the number of on bits in AX REG, returns result in AX
    EXTRN   NEWLINE:FAR
    EXTRN   GETDEC$:FAR	    ; get unsigned DEC from user
    EXTRN   PUTDEC$:FAR	    ; print unsigned DEC in AX
    EXTRN   PUTBIN:FAR	    ; print binary 16bit if BL>0, 8bit if BL is 0

;==============================================
; 
;   Data definition
;
;==============================================

    .DATA
	UINPUT		DB  'Enter a number for processing $'
	NUM_ENT		DB  'The number entered in BINARY: $'
	ON_BITS_MSG	DB  'ONE BITS IN NUMBER ENTERED: $'
	ODD_RES		DB  'NUMBER OF ONE BITS IS ODD$'
	EVEN_RES	DB  'NUMBER OF ONE BITS IS EVEN$'
	PAUSE		DB  10,'PRESS ANY KEY TO QUIT. BY Aleksey Leshchuk$' ; Line feed,'..'

    .CODE
	ASSUME DS:DGROUP
	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX	    ; initialize DATA SEGMENT to DS REG
	    LEA	    DX,UINPUT 
	    MOV	    AH,09H	    ; output $ terminated string in DS:DX reg
	    INT	    21H
	    CALL    GETDEC$
	    
	    PUSH    AX		    ; SAVE AX
	    LEA	    DX,NUM_ENT	    ; display number entered string 
	    MOV	    AH,09H 
	    INT	    21H
	    MOV	    BL,1	    ; Display 16bits stored in AX
	    POP	    AX		    ; restore AX
	    CALL    PUTBIN
	    CALL    NEWLINE 
	    CALL    PARITY	    ; CALL parity
	    PUSH    AX		    ; SAVE AX
	    LEA	    DX,ON_BITS_MSG
	    MOV	    AH,09h
	    INT	    21H
	    POP	    AX		    ; restore AX
	    CALL    PUTDEC$	    ; display number of one bits in the number entered
	    CALL    NEWLINE
	    AND	    AX,0001H	    ; logical AND value in AX and 1 to determine if AX is ODD/EVEN
	    .IF	    AX>0
	    LEA	    DX,ODD_RES	    ; if result is ODD, LEA of odd results string
	    .ELSE   
	    LEA	    DX,EVEN_RES	    ; else, LEA of even results string
	    .ENDIF
	    MOV	    AH,09H
	    INT	    21H
	Return:
	    LEA	    DX,PAUSE
	    MOV	    AH,09H
	    INT	    21H
	    CALL    GETDEC$	    ; Print PAUSE message, and pause screen by GETDEC$
	    .exit 0
    END MAIN
