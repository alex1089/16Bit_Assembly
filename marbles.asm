;========================================
;
; By: Aleksey Leshchuk CISP310
; Marbles assignment
; 
;========================================

    .286
    .MODEL SMALL 
    .STACK 256

    EXTRN   PUTDEC$:FAR	    ; print unsigned AX
    EXTRN   GETDEC$:FAR 
    EXTRN   NEWLINE:FAR

;========================================
;
; DATA
;
;========================================

    .DATA 
	marbles	    DB 500 DUP(1) 	
	intro	    db 10,13,'Marbles assignment, results of processing array without any modifications',10,13,'Returns all square numbers because they are XORed/toggled an ODD amount of times.',10,13,'$'
	PAUSE	    DB 10,13,'Press ENTER to continue, PROGRAMMED BY ALEKSEY LESHCHUK.$'
   

    .CODE 
	    ASSUME DS:DGROUP
	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX	    ; initialize DS with DGROUP
	    XOR	    CX,CX	    ; ZERO out COUNTER
	    MOV	    CX,1	    ; start at element 2
	    LEA	    DX,intro 
	    MOV	    AX,0900h
	    INT	    21H
	OUTERLOOP:
	    .if	    CX==500	    ; if outer loop is complete, break out
	    XOR	    CX,CX	    ; zero out CX
	    XOR	    BX,BX	    ; BX=0
	    JMP	    OUTP
	    .endif
	    XOR	    BX,BX	    ; iterator index
	    MOV	    BX,CX	    ; index iterator = COUNTER
	    INC	    CX		    ; increment COUNTER
	INNERLOOP:
	    XOR	    [marbles+BX],1    ; toggle array element
	    ADD	    BX,CX	    ; BX=BX+CX next array element
	    .if	    BX<500	    ; continue looping while iterator index < 500
	    JMP	    INNERLOOP	    
	    .endif
	    JMP	    OUTERLOOP	    ; jump to outter loop
	OUTP:
	    MOV	    AL,[marbles+BX]
	    .if	    AL==1
	    XCHG    BX,AX	    ; XCHG index number into AX
	    MOV	    BH,1	    ; right justify output
	    INC	    AX		    ; increment array index by 1
	    CALL    PUTDEC$
	    DEC	    AX		    ; decrement array index and XCHG with BX
	    XCHG    BX,AX
	    .endif
	    INC	    BX
	    .if	    BX==500	    ; loop until BX == 500
	    JMP	    QUIT
	    .endif
	    JMP	    OUTP
	QUIT:
	    LEA	    DX,PAUSE
	    MOV	    AX,0900H
	    INT	    21H		    ; output pause message
	    CALL    GETDEC$	    ; wait for input before exit 
	    MOV	    AX,4C00H
	    INT	    21H

	END main
	    
	    

	    
	    
	    
