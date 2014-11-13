;==============================================
; By aleksey Leshchuk
; Procedure that counts how many bits are set
; in register AX
;==============================================

    .MODEL SMALL

;==============================================
; - assign value to be processed into AX
; - call PARITY
; - results will be stored in AX reg
;==============================================

    .CODE   PAR
    
    PARITY  PROC    FAR	    USES CX DX BX

	PUSHF		    ; Save any current flags
	MOV	DX,0	    ; initialize number of on bits to 0
	MOV	CX,16	    ; initialize loop counter to 16
	MOV	BX,0001H    ; initial mask, to be shifted to the left
    PROC_NUM:
	PUSH	BX	    ; save BX before ANDing
	AND	BX,AX
	.IF	BX!=0
	INC	DX	    ; if ANDing operation yields a number !=0 there exists a 1 bit
	.ENDIF
	POP	BX	    ; restore BX to state before ANDing
	SHL	BX,1	    ; SHIFT to the LEFT 1 bit
	LOOP	PROC_NUM    ; CX-- and loop PROC_NUM until CX==0
    Return:
	MOV	AX,DX	    ; MOVE results to AX
	POPF		    ; retore flags
	RET
    PARITY  ENDP    
    END

	
	
    


