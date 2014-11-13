;=============================================
; 
; Encode program
; Encodes a 7 bit value using Hamming code
; By Aleksey Leshchuk 
; CISP310
;
;=============================================
 
    .286
    .MODEL SMALL
    .STACK 256
    EXTRN   NEWLINE:FAR
    EXTRN   PUTSTRNG:FAR    ; prints string at ES:DI reg pair for CX bytes
    EXTRN   GETDEC$:FAR     ; get unsigned DEC, store in AX
    EXTRN   PUTOCT:FAR	    ; print oct, 8bit in AL if BL is 0, 16bit AX if BL!=0
    EXTRN   PUTDEC$:FAR
    EXTRN   PARITY:FAR	    ; CALL with value stored in AX, return # of one bits

;=============================================
;   
; Data and code segment
;
;=============================================

    .DATA
	INPT	    DB  'Enter a value (0-127): '	; 23bytes
	VAL_ENTD    DB  10,'Value entered: '		; 16bytes
	ENC_OUT	    DB  10,13,'Encoded value in OCT: '	; 24bytes
	PAUSE	    DB  10,13,'Press any key to continue.',10,13,'PROGRAMMED BY Aleksey Leshchuk' ; 60bytes
	ORIG	    DW	?	    ; original input
	MASK8	    DW  111b	    ; mask for the last three bits of value
	MASK4	    DW  111000B	    ; mask for bits 2-4
	MASK2	    DW	1100110011B ; mask for bits 2,3,6,7,10,11
	MASK1	    DW  10101010101B; mask for bits 1,3,5,7,9,11
	LSBMASK	    DW  1B	    ; mask for LSB
	RES	    DW	0B	    ; result

		ASSUME ES:DGROUP,DS:DGROUP
    .CODE 
	main:
	    MOV	    AX,DGROUP
	    MOV	    ES,AX	    ; initialize DGROUP
	    MOV	    DS,AX	    ; initialize DGROUP to DS for MOV to work
	input:
	    LEA	    DI,INPT 
	    MOV	    CX,23	    ; LEA of input value request, print 23bytes
	    CALL    PUTSTRNG
	    CALL    GETDEC$
	    MOV	    ORIG,AX	    ; MOV input into ORIG
	    .if	    (AX>127)
	    JMP	    input
	    .endif
	    MOV	    AX,MASK8	    ; MOV mask for bits 5,6,7
	    AND	    AX,ORIG	    ; AND orig input with mask
	    ADD	    RES,AX	    ; ADD result of mask to RES
	    CALL    PARITY 

	    AND	    AX,LSBMASK	    ; AND result of PARITY to extract LSB
	    SHL     AX,3	    ; SHL resulting LSB
	    ADD	    RES,AX	    ; ADD resulting bit to RES

	    MOV	    AX,ORIG	    ; MOV ORIG into AX
	    AND	    AX,MASK4        ; MASK bits 2,3,4
	    SHL	    AX,1
	    ADD	    RES,AX	    ; RES=RES+shiftedAX
	    CALL    PARITY	    ; call PARITY to process bits 2,3,4

	    AND	    AX,LSBMASK	    ; mask LSB of result
	    SHL	    AX,7	    ; SHL 7 bits
	    ADD	    RES,AX	    ; ADD resulting bit to RES

	    MOV     AX,1000000b	    ; MASK for 1st bit
	    AND	    AX,ORIG	    ; mask 1st bit
	    SHL	    AX,2	    ; SHL and ADD to result
	    ADD	    RES,AX	    

	    MOV	    AX,RES
	    AND	    AX,MASK2	    ; mask bits 2,3,6,7,10,11
	    CALL    PARITY
	    AND	    AX,LSBMASK	    ; mask LSB of result from PARITY
	    SHL	    AX,9	    ; SHL LSB
	    ADD	    RES,AX	    ; ADD shift bit to RES
	    
	    MOV	    AX,RES	    
	    AND	    AX,MASK1	    ; mask bits 1,3,5,7,9,11
	    CALL    PARITY  
	    AND	    AX,LSBMASK	    ; mask LSB
	    SHL	    AX,10	    ; SHL LSB 10bits
	    ADD	    RES,AX	    ; ADD first bit to RES

	    LEA	    DI,ENC_OUT
	    MOV	    CX,24	    ; encoded output string
	    CALL    PUTSTRNG
	    MOV	    AX,RES
	    MOV	    BL,1	    ; MOV result into AX, set BL to !=0 
	    CALL    PUTOCT	    ; display 16bit result in oct
	    
	    LEA	    DI,PAUSE
	    MOV	    CX,60
	    CALL    PUTSTRNG	    ; pause message
	    CALL    GETDEC$
	exit:
	    .exit
	    END main
