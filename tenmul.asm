;==================================
; 
; ten digit multiply program
; By Aleksey Leshchuk
; CISP310
; 
;=================================

    .286
    .MODEL SMALL
    .STACK 256

    EXTRN   PUTDEC$:FAR
    EXTRN   GETDEC$:FAR
    
    .DATA   
	arr1	DB  20 DUP(0)	; 20 nibble array
	arr2	DB  20 DUP(0)	
	accum	DB  20 DUP(0)
	inpARR1	DB  10 DUP(0)	; array to hold user input for first mutliple
	inpARR2 DB  10 DUP(0)	; array to hold user input for second multiple
	mul1Len	DB  ?		; Length of multiple 2
	mul2Len	DB  ?		; Length of multiple 1
	carry	DB  0
	inpReq1 DB  10,13,'Enter first multiple (up to 10 digits): $'
	inpReq2 DB  10,13,'Enter second multiple (up to 10 digits): $'
	inpERR	DB  10,13,'ERROR: Invalid input, try again.$'
	equals	DB  10,13,' = $'
	comma	DB  ',$'
	PAUSE	DB  10,13,'Press ENTER to continue',10,13,'Programmed by Aleksey Leshchuk$'

    .CODE 
	ASSUME	DS:DGROUP

	main:	
		MOV	AX,DGROUP 
		MOV	DS,AX		; initialize data segment
		XOR	BX,BX
	inpMSG1:
		LEA	DX,inpReq1
		MOV	AX,0900H
		INT	21H		; output multiple1 input request
		XOR	BX,BX
	inp1:
		MOV	AX,0100h
		INT	21H
		.if	AL == 13 	; if CR is entered, JMP to inpMSG2
		MOV	mul1Len,BL		; save the length of multiple entered
		JMP	inpMSG2
		.endif
		.if	AL > 47 && AL < 58	; if number entered
		XOR	AH,AH
		SUB	AX,48			; adjust entered ascii code
		MOV	[inpARR1+BX],AL		; MOV number entered into first multiple array
		INC	BX
		.if	BX>9
		MOV	mul1Len,BL
		JMP	inpMSG2
		.endif 
		JMP	inp1
		.endif
		LEA	DX,inpERR		; error message
		MOV	AX,0900H
		INT	21H
		XOR	BX,BX			; Zero out BX to clear array
	    clearArr1:				; clear entire inpARR1
		MOV	[inpARR1+BX],0
		.if	BX<9
		INC	BX
		JMP	clearArr1
		.endif
		JMP inpMSG1
		
	inpMSG2: 
		LEA	DX,inpReq2
		MOV	AX,0900H
		INT	21H		; output multiple2 input request
		XOR	BX,BX
	inp2:
		MOV	AX,0100h
		INT	21H
		.if	AL == 13 || BX>9	; if CR is entered, JMP to multiply
		MOV	mul2Len,BL		; save multiple 2 length
		JMP	initArrays
		.endif
		.if	AL > 47 && AL < 58	; if number entered
		XOR	AH,AH
		SUB	AX,48			; adjust entered ascii code
		MOV	[inpARR2+BX],AL		; MOV number entered into first multiple array
		INC	BX
		.if	BL>9
		MOV	mul2Len,BL		; save multiple 2 length
		JMP	initArrays
		.endif
		JMP	inp2
		.endif
		LEA	DX,inpERR		; error message
		MOV	AX,0900H
		INT	21H
		XOR	BX,BX			; Zero out BX to clear array
	    clearArr2:				; clear entire inpARR1
		MOV	[inpARR2+BX],0
		.if	BX<9
		INC	BX
		JMP	clearArr2
		.endif
		JMP inpMSG2
	initArrays:
		XOR	CX,CX			; zero out CX, inpARR1 index
		
	    arr1FILL:
		MOV	BL,CL
		MOV	AL,[inpARR1+BX]		; copy number entered by op
		MOV	BX,20			; set BX to size of arr1
		SUB	BL,mul1Len		; subtract the offset for multiple 1
		MOV	[arr1+BX],AL		; MOV number entered by op into arr1
		DEC	mul1Len			; DEC length on multiple 1
		INC	CL			; increment index of inpArr1
		.if	mul1Len>0		; if any digits remain in inpArr1
		JMP	arr1FILL
		.endif
		XOR	CX,CX			; zero out inpARR2 index
	    arr2FILL:
		MOV	BL,CL			; MOV beginning inp2ARR index into BL
		MOV	AL,[inpARR2+BX]		; mov value of inp2ARR[BX] into AL
		MOV	BX,20 
		SUB	BL,mul2Len		; subtract offset for multiple 2
		MOV	[arr2+BX],AL		; mov inp2ARR[CX] into arr2[BX]
		DEC	mul2Len			; DEC length of user input2
		INC	CX			; increment user input 2 element
		.if	mul2Len>0		; if any digits left in inp2ARR
		JMP	arr2FILL
		.endif

	multiply:
		XOR	AX,AX
		MOV	AL,[arr2+19]		; move LSB into AL
		AND	AL,1			; MASK LSB 
		XOR	BX,BX			; zero out BX
		MOV	BX,19			; initalize BX to last accum index
		.if	AL>0 			; if AL was odd
		JMP	ACC			; add arr1 to accumulator
		.endif 
		XOR	CX,CX			; zero out counter/exitMultiply flag
		; arr2 is even
	    Edivide:
		XOR	AX,AX			; zero out AX
		DEC	BX			; BX-1
		MOV	AL,00000001B		; AL = 00000001B
		AND	AL,[arr2+BX]		; get LSB of arr2[BX-1]
		INC	BX			; restore BX
		SHR	[arr2+BX],1		; divide by 2
		.if	AL>0			; if BX-1 will have a carry
		ADD	[arr2+BX],5		; add 5 to adjust for carry
		.endif
		DEC	BX			; move on to next element
		.if	BX>0			; if all elements are not processed
		JMP	Edivide
		.endif
		XOR	BX,BX
		MOV	BX,19
	    Emult:
		SHL	[arr1+BX],1		; multiply by 2
		.if	[arr1+BX]>9		; if element overflowed
		ADD	[arr1+BX],6
		.endif
		.if	BX<19			; if not the last element in array
		; check for carry from prev element
		INC	BX
		XOR	AX,AX
		MOV	AL,00010000B		; 5th bit mask
		AND	AL,[arr1+BX]		; mask 5th bit of arr1[BX+1]
		SHR	AL,4			; SHR resulting bit to pos 1
		DEC	BX
		OR	[arr1+BX],AL		; OR masked bit into the element
		.endif 
		.if	BX>0			; loop until all elements are processed
		DEC	BX
		JMP	Emult
		.endif
		XOR	AL,AL
		MOV	AL,00001111B		; MASK to truncate most significant nibble
	    TruncMSNcNonZ:
		; truncate MSN in arr1, and count non zeros in arr2
		AND	[arr1+BX],AL		; mask off LSN
		.if	[arr2+BX]>0		
		INC	CX			; count every non zero of arr2
		.endif
		INC	BX
		.if	BX<20			; process all of arr1
		JMP	TruncMSNcNonZ
		.endif 
		JMP	multiply		; jump back to multiply
	    ACC:
		XOR	AX,AX
		MOV	AL,[arr1+BX]		; MOV arr1[BX] to AL
		ADD	[accum+BX],AL		; ADD arr1[BX] to accum array
		MOV	AL,carry
		ADD	[accum+BX],AL		; ADD carry to arr1[BX] if exists
		MOV	carry,0			; reset carry
		.if	[accum+BX]>9		; if arr1[BX] > 9, add 6, set carry on
		ADD	[accum+BX],6
		AND	[accum+BX],00001111B	; mask of bits 5-8
		MOV	carry,1
		.endif 
		.if	BX>0			; process entire array
		DEC	BX			; move on to next element
		JMP	ACC			; continue accumulating
		.endif
		.if	CX==1 && [arr2+19]==1	; if there is only one number left in arr2, and == 1
		JMP	print			; exit multiply
		.endif
		XOR	BX,BX
		XOR	CX,CX
		MOV	BX,19
		JMP	Edivide	

	print:	
		LEA	DX,equals
		MOV	AX,0900H
		INT	21H
		XOR	AX,AX
		XOR	BX,BX
		XOR	CX,CX	    ; print flag, start displaying when on
	    printM1:
		XOR	AX,AX
		MOV	AL,[accum+BX]
		.if	AL>0	    ; set CX on at first instance of non zero
		MOV	CX,1
		.endif
		.if	CX==1	    ; output if CX is on
		CALL	PUTDEC$
		MOV	AX,BX
		MOV	DL,3
		DIV	DL
		.if	AH==1 && BX<19
		LEA	DX,comma
		MOV	AX,0900H
		INT	21H
		.endif
		.endif
		INC	BX
		.if	BX<20
		JMP	printM1
		.endif

		
	quit:	
		LEA	DX,PAUSE
		MOV	AX,0900H
		INT	21H
		CALL	GETDEC$

		MOV	AX,4C00h
		INT	21H

    END main
