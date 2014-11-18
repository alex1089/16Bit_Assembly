;========================================
;
; Aleksey Leshchuk
; CISP310
; Fibonacci Assignment
;
;=======================================

    .286
    .MODEL SMALL
    .STACK 256

    EXTRN GETDEC$:FAR
    EXTRN PUTDEC$:FAR

;=========================================
;
; DATA DEFINITION
;
;=========================================

    .DATA
    arr1	DB	72 DUP(0)
    arr2	DB  72 DUP(0)
    arr3	DB  72 DUP(0)
    carryF	DB  0
    elementN	DW  ?
    inpMSG	DB  10,13,'Enter fibonocci element to calculate:$'
    overFMSG	DB  10,13,'Overflow occured on element #$'
    PAUSE	DB  10,13,'Programmed by Aleksey Leshchuk',10,13,'Press ENTER to quit$'

    .CODE   
	ASSUME DS:DGROUP

	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX	    ; initialize DGROUP to DS
	    LEA	    DX,inpMSG
	    MOV	    AX,0900H	    ; print inpMSG
	    INT	    21H
	    CALL    GETDEC$	    ; get elementNumber from operator
	    MOV	    elementN,AX	    ; store value in elementN
	    XOR	    CX,CX	    ; zero out CX, element counter
	    XOR	    BX,BX	    ; zero out BX, Array index
	    XOR	    AX,AX
	    MOV	    BX,71	    ; initialize BX to the last element of the array
	    INC	    [arr3+BX]
	    INC	    CX		    ; 1st element 
	begin:
	    .if	    CX==elementN    ; if requested element number is reached
	    XOR	    BX,BX
	    XOR	    DX,DX
	    JMP	    print
	    .endif
	    ; move up
	    MOV	    BX,71	    ; start moving elements up from the last element
	mUp: 
	    MOV	    AL,[arr2+BX] ; shift up arr2 elements into arr1
	    MOV	    [arr1+BX],AL
	    MOV	    AL,[arr3+BX] ; shift up arr3 elements into arr2
	    MOV	    [arr2+BX],AL
	    MOV	    [arr3+BX],0 ; ZERO out arr3 elements
	    .if	    BX>0		; jmp to mUp for all array elements
	    DEC	    BX
	    JMP	    mUp
	    .endif
	    MOV	    BX,71		; reset arr index to 71
	addElem:
	    ; add all elements
	    MOV	    AL,[arr3+BX]	; MOV initial number into AL 
	    ADD	    AL,carryF		; ADD carry if it exists
	    MOV	    carryF,0		; reset carry flag
	    ADD	    AL,[arr2+BX]	; add arr2[BX]
	    ADD	    AL,[arr1+BX]	; add arr3[BX]
	    MOV	    [arr3+BX],AL	; MOV result into arr3[BX] 
	    .if	    [arr3+BX]>9		; arr3+BX overflowed
	    ADD	    [arr3+BX],6		; add 6 to get LS bits to hold MOD10 result
	    AND	    [arr3+BX],1111B	; MASK off on the LS 4 bits
	    MOV	    carryF,1
	    .endif
	    .if	    BX>0		; if end of array not reached
	    DEC	    BX			; move on to the next arr element
	    JMP	    addElem
	    .endif
	    .if	    carryF>0		; overflow occured if there is still a carry left
	    JMP	    OFError 
	    .endif
	    INC	    CX			; one element processed, INC element counter
	    JMP	    begin		; JMP to begin
	PRINT:
	    mOV	    al,[ARR3+bx]
	    .if	    AL>0
	    MOV	    DX,1	; at the first appearance of al>0, flag beginning of number
	    .endif
	    .if	    DX>0
	    CALL     PUTDEC$
	    .endif
	    INC	    BX
	    .if	    BX<72
	    JMP	    PRINT
	    .endif
	    JMP	    quit
	OFError:
	    LEA	    DX,overFMSG		; display overflow error message
	    MOV	    AX,0900H
	    INT	    21H			
	    MOV	    AX,CX 
	    INC	    AX
	    CALL    PUTDEC$		; display element number at which overflow occured
	    MOV	    AX,4C00H
	    INT	    21H			; quit on error
	QUIT:
	    LEA	    DX,PAUSE
	    MOV	    AX,0900H
	    INT	    21H
	    CALL    GETDEC$
	    MOV	    AX,4C00H
	    INT	    21H

	END main
