           PAGE    80,132
;===================================================================
;
;                  PROGRAM LISTING 3.1
;
; PROGRAM  TO  CONVERT  A  TEMPERATURE  FROM
; FAHRENHEIT TO CENTIGRADE USING THE FORMULA
;
; C = 5*(F-32)/9  ROUNDED TO NEAREST INTEGER
;===================================================================
           DOSSEG
           .MODEL  SMALL,BASIC,FARSTACK
;===================================================================
                                       ;PROCEDURES TO
           EXTRN   GETDEC:FAR          ;GET 16-BIT DECIMAL INTEGER
           EXTRN   NEWLINE:FAR         ;DISPLAY NEWLINE CHARACTER
           EXTRN   PUTDEC:FAR          ;DISPLAY 16-BIT DECIMAL INTEGER
           EXTRN   PUTSTRNG:FAR        ;DISPLAY CHARACTER STRING
;===================================================================
;
; S T A C K   S E G M E N T   D E F I N I T I O N
;
           .STACK  256
;===================================================================
;
; C O N S T A N T   S E G M E N T   D E F I N I T I O N
;
           .CONST
PROMPT     DB      'ENTER TEMPERATURE IN DEGREES FAHRENHEIT   '
ANNOTATION DB      '      TEMPERATURE IN DEGREES CENTIGRADE   '
;===================================================================
;
; C O D E   S E G M E N T   D E F I N I T I O N
;
           .CODE
EX_3_1:
           MOV     AX,SEG DGROUP       ;SET ES-REGISTER TO ADDRESS
           MOV     ES,AX               ;    DGROUP
;
           LEA     DI,PROMPT           ;PROMPT FOR F_TEMP
           MOV     CX,42
           CALL    PUTSTRNG
           CALL    GETDEC              ;GET F_TEMP
           SUB     AX,32               ;C_TEMP = (F_TEMP -32) * 5 / 9
           MOV     BX,5
           IMUL    BX
           MOV     BX,9
           IDIV    BX
           XCHG    AX,DX               ;REMAIN = (F_TEMP-32)*5 rem 9
           MOV     BL,5                ;ROUND  = REMAIN / 5
           IDIV    BL
           CBW
           ADD     AX,DX               ;C_TEMP = C_TEMP + ROUND
;
           LEA     DI,ANNOTATION       ;DISPLAY C_TEMP
;          MOV     CX,42
           CALL    PUTSTRNG
           MOV     BH,0
           CALL    PUTDEC
           CALL    NEWLINE
           .EXIT                       ;RETURN TO DOS
;
           END     EX_3_1
;===================================================================
