;===============================================================
           .MODEL  SMALL,BASIC,FARSTACK
;==============================================================

	    EXTRN   NEWLINE:FAR	    ; prints new line
	    EXTRN   PUTSTRNG:FAR    ; prints string starting at offset es:di, cx bytes
	    EXTRN   PUTDEC:FAR	    ; prints signed decimal from AX reg
	    EXTRN   PUTBIN:FAR	    ; prints binary representation in AX reg
	    EXTRN   PUTHEX:FAR	    ; prints hex in AL if BL is 0, or AX if BL is 1
;===============================================================
;
; S T A C K   S E G M E N T   D E F I N I T I O N
;
           .STACK  256
;===============================================================
;
; D A T A   S E G M E N T   D E F I N I T I O N
;
          .DATA
ALPHA      DB      35
BETA       DW      01ABH
GAMMA      DW      45EFH
LAMDA      DB      CONSTANT
OMEGA      DW      67CDH
CONSTANT   EQU     10001001B
DEBUG	   DB      'AX holds: '
;
;===============================================================
;
; C O D E   S E G M E N T   D E F I N I T I O N
;
           .CODE
           ASSUME  DS:NOTHING,ES:DGROUP

PR_2_2:	   
	   MOV     AX,DGROUP		; set ES reg to data segment
	   MOV     ES,AX
;*** CHECKPOINT A ***
           MOV     AH,CONSTANT
           MOV     AL,ALPHA
           MOV     BX,GAMMA
           XCHG    AH,BH
           XCHG    AX,BETA
           MOV     ALPHA,AH
           MOV     LAMDA,AL
;*** CHECKPOINT B ***
           MOV     CX,OMEGA
           XCHG    BL,CH
           MOV     GAMMA,BX
           MOV     OMEGA,CX
	   call NEWLINE
	   mov     cx,10 		; print 10 bytes
	   lea     di,DEBUG	; offset to debug
	   call    PUTSTRNG		; call putstrng
	   mov     al,LAMDA
	   mov	   bl,0			; 16bit if 1, 8 bit if 0
	   call PUTHEX
;*** CHECKPOINT C ***

           .EXIT 0                      ;RETURN TO DOS, return 0
           END     PR_2_2
