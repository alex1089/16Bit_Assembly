;========================================
;
; By: Aleksey Leshchuk CISP310
; Marbles assignment
; MODIFIED TO OUTPUT PRIMES
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
	marbles	    DB 500 DUP(0) 	
	intro	    db 10,13,'Marbles assignment, results of processing array WITH modifications',10,13,'Program is modified to increment each element of the array when if is hit',10,13,'and outputting only the indexes of elements that were hit TWICE,',10,13,'meaning their ONLY factors are 1 and itself.',10,13,'$'
	PAUSE	    DB 10,13,'Press ENTER to continue, PROGRAMMED BY ALEKSEY LESHCHUK.$'
   

    .CODE 
	    ASSUME DS:DGROUP
	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX	    ; initialize DS with DGROUP
	    XOR	    CX,CX	    ; ZERO out COUNTER
	    MOV	    CX,0	    ; start at element 2
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
	; modification made here to increment array elements instead of toggling
	    INC	    [marbles+BX]    ; toggle array element
	    ADD	    BX,CX	    ; BX=BX+CX next array element
	    .if	    BX<500	    ; continue looping while iterator index < 500
	    JMP	    INNERLOOP	    
	    .endif
	    JMP	    OUTERLOOP	    ; jump to outter loop
	OUTP:
	    MOV	    AL,[marbles+BX]
	; modification made here to output only elements that contain a two
	    .if	    AL==2 || AL==1
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
	    
	    

	    
	    
	    
