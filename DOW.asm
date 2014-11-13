;========================================
;
; Day of week assignment
; CISP310
; Aleksey Leshchuk
; 
;=======================================

    .286
    .MODEL SMALL
    .STACK 256
    EXTRN GETDEC$:FAR		; get decimal from user store in AX
    EXTRN NEWLINE:FAR 
    EXTRN PUTDEC$:FAR

;=====================================
;
; DATA segment
;
;====================================

   .DATA

	MONTHS		DB  'January $','February $','March $','April $','May $','June $','July $','August $','September $','October $','November $','December $'
	MONTHSARROFFSET DB  0,9,19,26,33,38,44,50,58,69,78,88
	DAYSTRINGS	DB  'Tuesday $Wednesday $Thursday $Friday $Saturday $Sunday $Monday $'
	DAYSARROFFSET	DB  0,9,20,30,38,48,56
	DAYSINMONTH	DB  0,31,28,31,30,31,30,31,31,30,31,30,31
	MONTHOFFSET	DB  0,0,3,3,6,1,4,6,2,5,0,3,5,1
	EnterMessage	DB  10,13,'Enter a date (month day year) $'
	EntryError	DB  10,13,'Invalid date entered, try again (month day year): $'
	IsA		DB  ' is a $'
	COMMA		DB  ', $'
	PAUSE		DB  10,13,'Press any key to continue, Programmed by Aleksey Leshchuk$'
	MONTH		DB  ?
	DAY		DB  ?
	YEAR		DW  ?
	DAYSPASSED	DW  ?
	LEAPFLAG	DB  0		; flag set to 1 if year is a leap year
	

    .CODE
	    ASSUME	DS:DGROUP
	
	main:	MOV	AX,DGROUP
		MOV	DS,AX		; initalize DGROUP to DS reg
		XOR	AX,AX		; zero out AX
		LEA	DX,EnterMessage 
	input:	mov	AH,09H		; string to STDOUT 
		int	21H
		call	GETDEC$		; get month
		mov	MONTH,AL
		call	GETDEC$		; get day
		DEC	AX		; decrement AX
		mov	DAY,AL
		call	GETDEC$		; get year
		mov	YEAR,AX
		.if	YEAR < 1901 || YEAR > 2099	    ; if YEAR is out of range [1901-2099]
		JMP	inputError
		.endif
		SUB	AX,1901
		MOV	DAYSPASSED,AX		; MOV difference YEAR-1901 to DAYSPASSED
		MOV	BL,4
		DIV	BL		
		.if	AH == 3		; if leap year, set LEAPFLAG on
		MOV	LEAPFLAG,1
		.endif
		XOR	AH,AH		; 0 out AH for division
		ADD	DAYSPASSED,AX	; ADD to DAYSPASSED leap years
	validate: 
		XOR	BX,BX			; zero out BX, copy month entered into BL
		MOV	BL,MONTH
		MOV	AL,[DAYSINMONTH+BX]	; MOV number of days in the month entered into AX
		.if	DAY < AL		; if day entered is <= then the days in the MONTH entered
		JMP	PROCSS			; Date entered is valid, jump to PROCSS
		.endif
		.if	LEAPFLAG == 1 && MONTH == 2 && DAY == 28    ; if february 29th on a leap year
		JMP	PROCSS			; Date entered is valid, jump to PROCSS
		.endif
	inputError:
		LEA	DX,EntryError		; else, Date entered is invalid, LEA of ErrorMessage
		XOR	AX,AX			; zero out AX
		MOV	AX,0900H
		JMP	input			; JMP back to input

	PROCSS: XOR	AX,AX			; zero out AX
		MOV	AL,DAY			; MOV DAY entered into AX
		ADD	AX,DAYSPASSED		; ADD number of leap years to day
		XOR	CX,CX			; clear out CX
		MOV	CL,[MONTHOFFSET+BX]	; MOV MONTHOFFSET for month in BX
		ADD	AX,CX	; ADD offset of days for the MONTH(BL) entered
		.if	MONTH>2 && LEAPFLAG == 1	; if date is past February
		INC	AX		; ADD LEAPFLAG to days
		.endif
		XOR	DX,DX			; zero out DX for division
		MOV	BX,7
		DIV	BX			; total offset days MOD 7
		mov	BX,DX			; MOV weekday into BX
		PUSH	BX			; push BX to stack
	print:
		LEA	DX,MONTHS		; LEA address on beginning of MONTHS array
		XOR	BX,BX			; Zero out BX
		MOV	BL,MONTH		; MOV month to BL 
		DEC	BX
		MOV	AL,[MONTHSARROFFSET+BX]
		ADD	DX,AX
		MOV	AX,0900H
		int	21H		    
		XOR	AX,AX			;zero out AX
		MOV	AL,DAY
		INC	AX
		call	PUTDEC$ 
		LEA	DX,COMMA		; LEA of ','
		MOV	AX,0900H
		INT	21H
    
		MOV	AX,YEAR
		CALL	PUTDEC$
		LEA	DX,IsA			; LEA of IsA
		MOV	AX,0900H
		INT	21H			; output
		XOR	AX,AX		
		POP	BX			; retrive BX (day of week) from stack
		MOV	AL,[DAYSARROFFSET+BX]	; load offset for DAYS String array for the BX day
		LEA	DX,DAYSTRINGS
		ADD	DX,AX
		MOV	AX,0900H
		int	21H
	quit:	LEA	DX,PAUSE		; pause message
		MOV	AX,0900H
		INT	21H
		CALL	GETDEC$
		MOV	AX,4C00h		; exit
		int	21h		    

	END MAIN

		
