;===============================================
;
;  Aleksey Leshchuk
;  CISP310
;  Decode assignment
;  - takes input from user
;  - decodes and checks for bad bits
;  - displays the bad bit
;  - corrects bad bit and displays decoded balue
;==============================================

    .286
    .MODEL SMALL
    .STACK 256

    EXTRN   GETDEC$:FAR	    ; gets unsigned DEC from user, stores in AX
    EXTRN   PARITY:FAR	    ; returns count of on bits in value in AX
    EXTRN   PUTDEC$:FAR	    ; display DEC in AX 
    EXTRN   PUTOCT:FAR	    ; display OCT in AX, 8bit if BX is 0, 16bit if BX!=0
    .DATA 
	INP_REQ	    DB	10,13,'Enter a number (0-2147): $'
	NO_BAD_BIT  DB	10,13,'There is no bad bit in the number.$'
	BAD_BIT_OUT DB  10,13,'Bad bit in bit #$'
	RESLT_OUT   DB  10,13,'The decoded result is $'
	PAUS	    DB  10,13,'PRESS ANY KEY TO EXIT.',10,13,'Programmed by Aleksey Leshchuk$'

	LSB_MASK    DW	1B
	MASK_P_ARR  DW	10101010101B,1100110011B,11110000B,1111B ; MASK1,MASK2,MASK4,MASK8
	MASK_D_ARR  DW  100000000B,1110000B,111B		 ; Data bits MASK1,MASK2,MASK3
	BAD_BIT	    DW  0
	ORIG	    DW	?
	RESLT	    DW	0

	    ASSUME DS:DGROUP
    .CODE 
	main:
	    MOV	    AX,DGROUP	
	    MOV	    DS,AX		; initialize DGROUP
	input:
	    LEA	    DX,INP_REQ
	    XOR	    AX,AX		; zero out AX
	    MOV	    AH,09H		; DOS int string output DS:DI 
	    INT	    21H
	    CALL    GETDEC$		; get DEC from operator
	    MOV	    ORIG,AX		; Save input into ORIG
	    .IF	    AX>2147
	    JMP	    input 
	    .ENDIF

	    XOR	    CX,CX		; 0 out CX
	    MOV	    CX,4		; loop, and SHL variable
	    MOV	    BX,6		; initial array offset for 1st MASK
	process:
	    
	    MOV	    AX,[MASK_P_ARR+BX]    ; MOV processing mask
	    AND	    AX,ORIG		    ; MASK bits out of ORIG input
	    CALL    PARITY		    ; process masked bits
	    AND	    AX,LSB_MASK		    ; MASK LSB  in PARITY output
	    DEC	    CX
	    SHL	    AX,CL 		    ; SHL LSB by counter reg-1
	    SUB	    BX,2
	    ADD	    BAD_BIT,AX		    ; add shifted LSB to bad bit array
	    .if	    CX>0		    ; loop until cx==0
	    JMP	    process
	    .endif

	    MOV	    AX,1		    ; set AX to 1, and SHL by BAD_BIT-1
	    MOV	    CX,11		    ; SHL by 11-bad bit 
	    SUB	    CX,BAD_BIT
	    SHL	    AX,CL

	    XOR	    ORIG,AX		    ; negate bad bit

	    .if	    BAD_BIT>0
	    LEA	    DX,BAD_BIT_OUT	    ; if there is a bad bit, LEA of bad_bit_output
	    MOV	    AX,0900H
	    INT	    21h			    ; display message in DI:DX
	    MOV	    AX,BAD_BIT
	    CALL    PUTDEC$
	    .else
	    LEA	    DX,NO_BAD_BIT	    ; else, LEA of no_bad_bit message
	    MOV	    AX,0900H
	    INT	    21h			    ; display message in DI:DX
	    .endif
	    
	    MOV	    CX,0		    ; initialize loop variable
	    MOV	    BX,4		    ; initialize array offset variable 
	extract_data:
	    MOV	    AX,[MASK_D_ARR+BX]	    ; MOV MASK into AX
	    AND	    AX,ORIG		    ; MASK corrected ORIG input
	    SHR	    AX,CL		    ; SHR data bits by CL bits
	    ADD	    RESLT,AX		    ; ADD result to AX
	    INC	    CX			    ; increment loop variable
	    SUB	    BX,2		    ; subtract array offset
	    .if	    CX<3		    ; loop until CX == 3
	    JMP	    extract_data
	    .endif

	    LEA	    DX,RESLT_OUT	    
	    MOV	    AX,0900H
	    INT	    21h
	    MOV	    AX, RESLT
	    MOV	    BX,1		    ; output RESLT message, set BL!=0, display RESLT
	    CALL    PUTOCT
	retrn:
	    LEA	    DX,PAUS
	    MOV	    AX,0900H
	    INT	    21H			    ; load pause message and wait to exit
	    CALL    GETDEC$
	    .exit 0
	    
	   END main 
