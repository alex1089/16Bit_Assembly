;==================================
;
; Aleksey Leshchuk
; Graphics assignment/Final
; CISP310
;
;==================================

    .286
    .MODEL SMALL
    .STACK 256
    
    EXTRN   DELAY:FAR
    EXTRN   GETDEC$:FAR
    EXTRN   PUTDEC$:FAR
    EXTRN   RANDOM:FAR
    EXTRN   RESEED:FAR

    .DATA
	ScoreMSG    DB  'SCORE:  '
	startVid    DW	0b800H
	speed	    DB  4
	crashed	    DB	0
	direction   DB	?
	score	    DW  0
	X	    DB	0	    ; current X Y position
	Y	    DB  0
	AppleLoc    DW	0
	SnakeXY	    DW	80 DUP(0)   ; XY position in video memory
	BLACKATTR   DB	00h
	WHITEATTR   DB  07h
	REDATTR	    DB	04H
	

    .CODE 
	ASSUME DS:DGROUP

	main:
	    MOV	    AX,DGROUP
	    MOV	    DS,AX
	    MOV	    AX,startVid
	    MOV	    ES,AX	    ; video memeory offset
	    MOV	    AX,0003H	    ; change video mode to test 80x25
	    XOR	    BX,BX	    ; BH=video page=0
	    INT	    10H
	    mov cx,80
	    XOR DI,DI
	initAll:
	    MOV	    Speed,4
	    MOV	    Crashed,0
	    MOV	    score,0
	DrawBorder:
	    MOV	    AX,03DBh	    ; AL=ASCII 219, AH=attribute cyan
	    XOR	    BX,BX
	  top:
	    .if	    DI>143
	    MOV	    AL,ScoreMSG[BX]
	    INC	    BX
	    .endif
	    MOV	    ES:[DI],al	    ; move char into position
	    inc di
	    .if	    DI>144
	    MOV	    AH,30h
	    .endif
	    MOV	    ES:[DI],ah	    ; move attribute into position
	    inc di
	    LOOP top		    ; loop 80 columns
	    MOV	    CX,80	    ; reset CX
	    DEC	    DI
	    ADD	    DI,3840	    ; jump to bottom of video memory
	    MOV	    AX,03DBh	    ; AL=ASCII 219, AH=attribute cyan
	    XCHG    AL,AH	    ; swap ascii char and attribute
	  bottom:		    ; fill bottom row from end of row
	    MOV	    ES:[DI],AL	    ; move attribute into position
	    DEC	    DI 
	    MOV	    ES:[DI],AH      ; move character into position
	    DEC	    DI
	    LOOP    bottom
	    INC	    DI 
	    MOV	    CX,24
	  right:
	    SUB	    DI,160	    ; move up a row
	    MOV	    ES:[DI],AH	    ; move char into position
	    INC	    DI
	    MOV     ES:[DI],AL	    ; move attribute into position
	    DEC	    DI
	    LOOP    right
	    MOV	    CX,24	    
	    ADD	    DI,158	    ; move to last char in row
	  left:
	    ADD	    DI,160
	    MOV	    ES:[DI],AH	    ; move character into last column
	    INC	    DI
	    MOV	    ES:[DI],AL	    ; move attribute into position
	    DEC	    DI	
	    LOOP    left

	    MOV	    DI,5406
	    MOV	    AH,05H	    ; set video page
	    MOV	    AL,1h	    ; page 1
	    INT	    10H
	    MOV	    AX,03DBH
	  menu:
	   topMenu:
	    MOV	    word PTR ES:[DI],AX
	    .if     DI<5486
	    ADD	    DI,2
	    JMP	    topMenu
	    .endif
	    MOV al,25
	    call delay
	    MOV	    AH,05H	    ; set video page
	    mov al,0
	    int 10h
	    
	    ; start of game
	    MOV	    DI,240	    ; set to beginning position on screen, middle
	    MOV	    [SnakeXY],240
	    MOV	    X,40	    ; initialize X to position 40
	    MOV	    Y,1		    ; initialize Y to position 1
	    XOR	    BX,BX	    ; zero out Path index
	    MOV	    DX,0DB04H	    ; ASCII219:ATTR04
	    MOV	    direction,80	    ; start game with snake moving down
	    JMP	    genApple
	game:
	printScore:
	    MOV	    AH,02H	    ; int 10H set cursor position
	    MOV	    BH,0	    ; page number
	    MOV	    DX,004eH        ; position 0x79
	    INT	    10H
	    MOV	    AX,Score
	    CALL    PUTDEC$	    ; print score
	    XOR     BX,BX	
	    MOV	    BX,SCORE	    ; MOV score to the array element
	    SHL	    BX,1	    ; multiply score*2, 2 bytes in word
	    ; take input 
	    MOV dl,0ffh
	    MOV	    AH,6h
	    INT	    21H		    ; get input in stream
	    INT	    21H		    ; keep only second value in stream from arrow
	    ; if input is j,k,h, or l
	    .if	    AL==80 || AL==75 || AL==72 || AL==77 ; if input is non zero
	      MOV   direction,AL    ; mov input if it exists
	    .endif		    ; end of input
	    .if	    direction == 80	 ; if down
	      PUSH	    DI		; PUSH leading pixel
	      MOV	    DI,[SnakeXY+BX]  ; MOV TAIL to black out
	      INC	    DI
	      MOV	    AL,BLACKATTR
	      MOV	    ES:[DI],AL	    ; black out previous pixel
	      POP	    DI		    ; pop leading pixel
	    ADD     DI,160	    ; move down one row
	    INC	    Y
	    .endif
	    .if	    direction == 72	; if up
	      PUSH	    DI		; PUSH leading pixel
	      MOV	    DI,[SnakeXY+BX]  ; MOV TAIL to black out
	      INC	    DI
	      MOV	    AL,BLACKATTR
	      MOV	    ES:[DI],AL	    ; black out previous pixel
	      POP	    DI		    ; pop leading pixel
	    SUB	    DI,160		; MOVE up on row
	    DEC	    Y			; MOV up Y
	    .endif
	    .if	    direction == 75	; if left
	      PUSH	    DI		; PUSH leading pixel
	      MOV	    DI,[SnakeXY+BX]  ; MOV TAIL to black out
	      INC	    DI
	      MOV	    AL,BLACKATTR
	      MOV	    ES:[DI],AL	    ; black out previous pixel
	      POP	    DI		    ; pop leading pixel
	    SUB	    DI,2		; MOVE left
	    DEC	    X			; MOV X left
	    .endif
	    .if	    direction == 77	; if right
	      PUSH	    DI		; PUSH leading pixel
	      MOV	    DI,[SnakeXY+BX]  ; MOV TAIL to black out
	      INC	    DI
	      MOV	    AL,BLACKATTR
	      MOV	    ES:[DI],AL	    ; black out previous pixel
	      POP	    DI		    ; pop leading pixel
	    ADD	    DI,2		; MOVE right
	    INC	    X			; MOV X rigit
	    .endif
	    ; white out second pixel
	    .if	    SCORE>0
	    PUSH    DI
	    MOV	    DI,[SnakeXY+0]
	    MOV	    AL,WHITEATTR
	    MOV	    ES:[DI],AL
	    INC	    DI
	    MOV	    ES:[DI],AL
	    POP	    DI	; end of whiteout
	    .endif
	    MOV	    AL,254
	    MOV	    ES:[DI],AL
	    INC	    DI
	    MOV	    AL,REDATTR
	    MOV	    ES:[DI],AL
	    DEC	    DI
	    .if	    Y < 24 && Y > 0 && X > 0 && X < 79	; if in bound
	      XOR   BX,BX
	      MOV   DX,Score
	      SHL   DX,1		; Score*2 = bound for length of snake
	    collision:
	      .if   DI == [SnakeXY+BX]
	      MOV   crashed,1		; set crash flag on
	      JMP   QUIT 
	      .endif
	      ADD   BX,2
	      .if   BX<DX
	      JMP   collision
	      .endif
	      .if     DI == AppleLoc	; if apple is picked up
	      MOV     AppleLoc,0	; remove apple
	      INC     score		; inc score
	      MOV     AX,Score
	      MOV     CL,4
	      DIV     CL
	      .if     AH==0 && Speed>1		; Score MOD 4
	      DEC     Speed		; increase speed
	      .endif 
	      JMP     genApple
	      .endif
	      ; Shift pixel elements
	      MOV   DX,Score
	      SHL   DX,1
	      XOR BX,BX	    ; reset BX to shift all snake elements
	      MOV   AX,[SnakeXY+0]  ; MOV 1st snake pixel
	      ShiftSnakeArr:
		ADD	BX,2	    ; add 2 to array offset
		MOV	CX,[SnakeXY+BX]
		MOV	[SnakeXY+BX],AX
		.if	BX<DX
		XCHG	AX,CX
		JMP	ShiftSnakeArr	; JMP until all elements are processed
		.endif 
		MOV	[SnakeXY+0],DI	; update first pixel with latest position

	    mov al,speed
	    call delay
	    JMP	    game
	    .endif

	    JMP	    QUIT	; jump over genApple
	    genApple:
		PUSH	DI	; SAVE DI
		PUSH	CX
		XOR	BX,BX	; BX=0, SEED with Time
		CALL	RESEED
		PUSH	1	; Lower X boundary
		PUSH    78	; upper X boundary
		CALL	RANDOM	; Generate Random
		SHR	AX,2
		SHL	AX,2	; truncate LSB of result
		ADD	AX,2
		MOV	BX,AX	; MOV result into BX
		PUSH	1
		PUSH    23	; Upper and Lower bound of Y
		CALL	RANDOM	
		MOV	CX,160
		MUL	CX	; Multiply Y by bytes in row of vid memory
		ADD	AX,BX	; Add generated X value
		MOV	DI,AX	; MOV result to DI
		MOV	AL,235	; move apple char into AL
		MOV	ES:[DI],AL 
		INC	DI
		MOV	AL,82H	    ; blinking green ATTR
		MOV	ES:[DI],AL
		DEC	DI
		MOV	AppleLoc,DI	; save the location of the apple
		POP	CX
		POP	DI	    ; restore DI
		XOR BX,BX	    ; reset BX to shift all snake elements
		MOV	DX,Score
		SHL	DX,1
		MOV	AX,[SnakeXY+0]
	      ShiftSnakeArr2:
		ADD	BX,2
		MOV	CX,[SnakeXY+BX]
		MOV	[SnakeXY+BX],AX
		XCHG	CX,AX
		.if	BX<DX
		JMP	ShiftSnakeArr2	; JMP until all elements are processed
		.endif 
		MOV	[SnakeXY+0],DI	; update the first snake element with DI
		; need to check for collision here
		XOR	BX,BX
		MOV	DX,Score
		SHL	DX,1		; multiply score by two
		MOV	AX,AppleLoc
	      CheckColl1:
		.if	[SnakeXY+BX] == AX    ; if AppleLoc falls on any pixel of snake
		JMP	genApple		    ; regenerate apple
		.endif
		ADD	BX,2			    ; Next snake pixel
		.if	BX<DX			    ; loop through all pixels
		JMP	CheckColl1
		.endif
		JMP	game	    ; return to game
	    
	quit:
	    MOV   AL,58h
	    MOV   ES:[DI],AL
	    INC   DI
	    MOV   AL,84H
	    MOV   ES:[DI],AL		; set head to blink red
	    MOV	  AL,32
	    CALL  DELAY			; delay for 2 seconds
	    
	    call getdec$
	    .if	    AX==1
	    JMP main
	    .endif
	    MOV	    AX,4c00H
	    INT	    21H
	END main
