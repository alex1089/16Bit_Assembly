           PAGE    80,132
;===================================================================
;               PROGRAM LISTING 1.1
; this is done for  an example in class
; PROGRAM TO PRINT NUMBER SYSTEM TRANSLATION TABLES
;===================================================================
                                       ;PROCEDURES TO
           EXTRN   CLEAR:FAR           ;CLEAR SCREEN
           EXTRN   NEWLINE:FAR         ;DISPLAY NEWLINE CHARACTER
           EXTRN   PAUSE:FAR           ;PAUSE UNTIL KEY STROKE
           EXTRN   PUTBIN:FAR          ;DISPLAY BINARY (BYTE OR WORD)
           EXTRN   PUTDEC:FAR          ;DISPLAY 16-BIT DECIMAL INT.
           EXTRN   PUTHEX:FAR          ;DISPLAY HEX   (BYTE OR WORD)
           EXTRN   PUTOCT:FAR          ;DISPLAY OCTAL (BYTE OR WORD)
           EXTRN   PUTSTRNG:FAR        ;DISPLAY CHARACTER STRING
;===================================================================
;S T A C K   S E G M E N T   D E F I N I T I O N
;
STACK      SEGMENT STACK
           DB      256 DUP(?)
STACK      ENDS
;===================================================================
;D A T A   S E G M E N T   D E F I N I T I O N
;
DATA       SEGMENT
HEADERS    DB      'DECIMAL        '
           DB      'BINARY                  '
           DB      'OCTAL      '
           DB      'HEXADECIMAL '
SPACES     DB      '        '
PAUSE_MSG  DB      '   ANY KEY CONTINUES'
DATA       ENDS
;===================================================================
;C O D E   S E G M E N T   D E F I N I T I O N
;
CODE       SEGMENT 'CODE'
           ASSUME  CS:CODE,DS:NOTHING,ES:DATA,SS:STACK
EX_1_1:
           MOV     AX,SEG DATA         ;SET ES-REGISTER TO POINT TO
           MOV     ES,AX               ;DATA SEGMENT
;
           MOV     AX,-128             ;NUMBER = -128
NUM_LOOP:                              ;REPEAT
           CALL    CLEAR               ;   CLEAR SCREEN
           LEA     DI,HEADERS          ;   DISPLAY HEADERS
           MOV     CX,61
           CALL    PUTSTRNG
           MOV     CX,24               ;   LOOP_COUNT = 24
PAGE_LOOP:                             ;   REPEAT
           CALL    NEWLINE             ;      DISPLAY NEWLINE CHAR.
           PUSH    CX                  ;      PUSH LOOP_COUNT
           MOV     BH,+1               ;      DISPLAY NUMBER IN
           CALL    PUTDEC              ;      DECIMAL RIGHT JUSTIFIED
           LEA     DI,SPACES           ;      DISPLAY 3 SPACES
           MOV     CX,3
           CALL    PUTSTRNG
           MOV     BL,0                ;      DISPLAY LOWER 8 BITS
           CALL    PUTBIN              ;      OF NUMBER IN BINARY
           MOV     CX,1                ;      DISPLAY 1 SPACE
           CALL    PUTSTRNG
           MOV     BL,1                ;      DISPLAY NUMBER IN
           CALL    PUTBIN              ;      BINARY
           MOV     CX,3                ;      DISPLAY 3 SPACES
           CALL    PUTSTRNG
           MOV     BL,0                ;      DISPLAY LOWER 8 BITS
           CALL    PUTOCT              ;      OF NUMBER IN OCTAL
           MOV     CX,1                ;      DISPLAY 1 SPACE
           CALL    PUTSTRNG
           MOV     BL,1                ;      DISPLAY NUMBER IN
           CALL    PUTOCT              ;      OCTAL
           MOV     CX,5                ;      DISPLAY 5 SPACES
           CALL    PUTSTRNG
           MOV     BL,0                ;      DISPLAY LOWER 8 BITS
           CALL    PUTHEX              ;      OF NUMBER IN HEX
           MOV     CX,1                ;      DISPLAY 1 SPACE
           CALL    PUTSTRNG
           MOV     BL,1                ;      DISPLAY NUMBER IN HEX
           CALL    PUTHEX
           POP     CX                  ;      POP LOOP_COUNT
           INC     AX                  ;      NUMBER = NUMBER + 1
           LOOP    PAGE_LOOP           ;      DECREMENT LOOP_COUNT
                                       ;   UNTIL LOOP_COUNT = 0
           PUSH    AX                  ;   PUSH NUMBER
           LEA     DI,PAUSE_MSG        ;   PAUSE AND WAIT FOR 
           MOV     CX,20               ;   KEY STROKE
           CALL    PAUSE
           POP     AX                  ;   POP NUMBER
           CMP     AX,256
           JGE     RETURN              ;UNTIL NUMBER = 256
           JMP     NUM_LOOP
RETURN:
           MOV     AX,4C00H            ;RETURN TO OS
           INT     21H
CODE       ENDS
           END     EX_1_1
