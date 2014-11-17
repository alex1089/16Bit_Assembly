;===============================================
; 
; Aleksey Leshchuk
; CISP310
; Bubble sort assignment
;
;===============================================

    .286
    .MODEL SMALL 
    .STACK 256

    EXTRN   PUTDEC$:FAR
    EXTRN   GETDEC$:FAR
    EXTRN   NEWLINE:FAR
    EXTRN   RANDOM:FAR
    EXTRN   RESEED:FAR
    

;==============================================
;
;   DATA segment
;
;=============================================

    .DATA
	arr1	    DB  100 DUP(?)
	arr2	    DB  100 DUP(?)
	arr3	    DB  100 DUP(?)
	BottUns	    DB  ?
	TopUns	    DB  ?
	methd1Stat  DW  0,0,0	    ; Compare, Swap, Passes
	methd2Stat  DW	0,0,0
	methd3Stat  DW  0,0,0
	unsortMSG   DB  'Unsorted Array:$'
	sortedMSG   DB  10,13,'Sorted Array:$'
	RESLTMSG    DB	'Results of sorts:$'
	METH1MSG    DB	10,13,'Method 1:',10,13,'  COMP  SWAPS  PASS',10,13,'$'
	METH2MSG    DB	10,13,'Method 2:',10,13,'  COMP  SWAPS  PASS',10,13,'$'
	METH3MSG    DB	10,13,'Method 3:',10,13,'  COMP  SWAPS  PASS',10,13,'$'
	CONT	    DB	10,13,'Press ENTER to continue',10,13,'$'
	PAUSE	    DB  10,13,'Programmed by Aleksey Leshchuk, PRESS ENTER TO CONTINUE$'
	

    .CODE   
	ASSUME	DS:DGROUP

	    main:   MOV	    AX,DGROUP
		    MOV	    DS,AX
		    XOR	    BX,BX	; zero out ARR index 
		    MOV	    BX,1	; SEED RAND with number in AX
		    MOV	    AX,5555H	; 
		    CALL    RESEED	; CALL RESEED with 5555H
		    XOR	    BX,BX	; zero out ARR index 
	    populate:
		    PUSH    1		; push starting range of 1
		    PUSH    100		; push end of range of 100
		    CALL    RANDOM	; call rand
		    
		    MOV	    [arr1+BX],AL
		    MOV	    [arr2+BX],AL
		    MOV	    [arr3+BX],AL    ; populate all 3 arrays with the same values
		    INC	    BX		    ; increment BX array index
		    .if	    BX<100
		    JMP	    populate	    ; while BX is less than 100 JMP
		    .endif
		    LEA	    DX,unsortMSG 
		    MOV	    AH,09h	    ; display unsortMSG string
		    INT	    21h		    
		    XOR	    BX,BX	    ; zero out BX for printing
		    JMP	    print	    ; print unsorted array
		    XOR	    BX,BX	    ; zero index counter
		    XOR	    DX,DX	    ; SWAP counter, terminate when 0
	    method1:
		    MOV	    AL,[arr1+BX]    ; mov element BX into AL
		    INC	    BX		    ; compare BX+1 with BX
		    INC	    methd1Stat      ; inc methd1Stat[0], compare counter
		    .if	    AL>[arr1+BX]
		    MOV	    CL,[arr1+BX]    ; MOV element BX into temp
		    MOV	    [arr1+BX],AL    ; mov element BX-1 into BX
		    DEC	    BX		    
		    MOV	    [arr1+BX],CL    ; mov temp into BX-1
		    INC	    BX
		    PUSH    BX		    ; PUSH away array index
		    MOV	    BX,2	    ; methd1Stat[2]++ swap counter
		    INC	    [methd1Stat+BX]
		    INC	    DX		    ; INC DX with every swap
		    POP	    BX		    ; restore BX
		    .endif
		    .if	    BX<99	    ; if array index is less than SIZE-1
		    JMP	    method1
		    .endif
		    ; end of pass
		    PUSH    BX		    ; push BX
		    MOV	    BX,4	    ; method1Stat[Passes]++
		    INC	    [methd1Stat+BX]
		    POP	    BX		    ; restore BX
		    .if	    DX > 0
		    XOR	    DX,DX	    ; SWAP counter, terminate when 0
		    XOR	    BX,BX	    ; zero index counter
		    JMP	    method1
		    .endif
		    XOR	    BX,BX

		    MOV	    DX,99	    ; sizeOfArray2, terminate sort when DX==0
		method2:
		    MOV	    AL,[arr2+BX]    ; mov element BX into AL
		    INC	    BX		    ; compare BX+1 with BX
		    INC	    methd2Stat      ; inc methd2Stat[CompareCounter]
		    .if	    AL>[arr2+BX]
		    ; swap
		    MOV	    CL,[arr2+BX]    ; MOV element BX into temp
		    MOV	    [arr2+BX],AL    ; mov element BX-1 into BX
		    DEC	    BX		    
		    MOV	    [arr2+BX],CL    ; mov temp into BX-1
		    INC	    BX
		    PUSH    BX		    ; PUSH away array index
		    MOV	    BX,2	    ; methd2Stat[2]++ swap counter
		    INC	    [methd2Stat+BX]
		    POP	    BX		    ; restore BX
		    .endif
		    
		    .if	    BX<DX	    ; if array index is less than SIZE-1
		    JMP	    method2
		    .endif
		    ; full pass completed
		    PUSH    BX		    ; push BX
		    MOV	    BX,4	    ; method2Stat[Passes]++
		    INC	    [methd2Stat+BX]
		    POP	    BX		    ; restore BX

		    .if	    DX > 1	    ; if # of unsorted elements>1
		    DEC	    DX		    ; DEC number of unsorted elements
		    XOR	    BX,BX	    ; zero index counter
		    JMP	    method2
		    .endif

		    XOR	    CH,CH	    ; zero out lowest unsorted element
		    XOR	    BX,BX	    ; ZERO out iterator
		    XOR	    DX,DX
		    MOV	    DX,99	    ; set highest unsorted element
		method3:
		MoveDown:
		    ; move down the arr
		    MOV	    AL,[arr3+BX]    ; MOV lowest unsorted elem into AL
		    INC	    BX
		    INC	    methd3Stat	    ; increment compare counter
		    .if	    AL>[arr3+BX]    ; if BX-1 > BX
		    ; swap
		    MOV	    CL,[arr3+BX]    ; MOV element BX into temp
		    MOV	    [arr3+BX],AL    ; mov element BX-1 into BX
		    DEC	    BX		    
		    MOV	    [arr3+BX],CL    ; mov temp into BX-1
		    INC	    BX
		    PUSH    BX		    ; PUSH away array index
		    MOV	    BX,2	    ; methd3Stat[2]++ swap counter
		    INC	    [methd3Stat+BX]
		    POP	    BX		    ; restore BX
		    .endif
		    .if	    BX<DX	    ; if high unsorted element isnt reached 
		    JMP     MoveDown
		    .endif
		    PUSH    BX		    ; SAVE value in BX
		    MOV	    BX,4	    ; methd3Stat[PassesCounter]++
		    INC	    [methd3Stat+BX] 
		    POP	    BX
		    DEC	    DX		    ; DEC highest unsorted element
		    DEC	    BX
		    ; move up the array
		MoveUp:
		    MOV	    AL,[arr3+BX]
		    DEC	    BX
		    INC	    methd3Stat	    ; inc compare counter
		    .if	    AL<[arr3+BX]    ; if BX + 1 < BX
		    ;swap
		    MOV	    CL,[arr3+BX]    ; MOV element BX into temp
		    MOV	    [arr3+BX],AL    ; mov element BX+1 into BX
		    INC	    BX		    
		    MOV	    [arr3+BX],CL    ; mov temp into BX+1
		    DEC	    BX
		    PUSH    BX		    ; PUSH away array index
		    MOV	    BX,2	    ; methd3Stat[2]++ swap counter
		    INC	    [methd3Stat+BX]
		    POP	    BX		    ; restore BX
		    .endif ;end swap
		    .if	    BL>CH	    ; if iterator is > lowest unsorted array, loop
		    JMP	    MoveUp
		    .endif
		    PUSH    BX		    ; SAVE value in BX
		    MOV	    BX,4	    ; methd3Stat[PassesCounter]++
		    INC	    [methd3Stat+BX] 
		    POP	    BX
		    INC	    CH		    ; INC the lowest unsorted element
		    MOV	    BL,CH	    ; set array iterator to the lowest unsorted element
		    .if	    BL<48 && CL>0   ; continue until lowest sorted is the middle, or until no swaps occured
		    XOR	    CL,CL 
		    JMP	    method3
		    .endif
		    XOR	    BX,BX   ; zero out BX for print 

		    LEA	    DX,sortedMSG
		    MOV	    AH,09H	    ; print sortedMSG string
		    INT	    21H
	    print:
		    XOR	    DX,DX	    ; zero out DX for division
		    MOV	    AX,BX
		    MOV	    CX,10
		    DIV	    CX		    ; AX/CX
		    .if	    DX==0	    ; AX MOD 10 == 0, newline every 10 numbers
		    CALL    NEWLINE
		    .endif
		    XOR	    AX,AX
		    MOV	    AL,[arr2+BX]
		    PUSH    BX
		    MOV	    BX,0100H
		    call    PUTDEC$
		    pop	    bx
		    inc	    BX
		    .if	    BX<100
		    JMP	    print
		    .endif
		    .if	    methd1Stat==0   ; if arrays arent processed, JMP to method1 to begin
		    LEA	    DX,CONT 
		    MOV	    AX,0900H	    ; display continue message
		    INT	    21h
		    CALL    GETDEC$
		    JMP	    method1
		    .endif
		    MOV	    BH,1
		    LEA	    DX,METH1MSG
		    MOV	    AX,0900H
		    INT	    21H
		    MOV	    AX,methd1Stat
		    CALL    PUTDEC$
		    MOV	    AX,[methd1Stat+2]
		    CALL    PUTDEC$
		    MOV	    AX,[methd1Stat+4]
		    CALL    PUTDEC$
		    
		    LEA	    DX,METH2MSG
		    MOV	    AX,0900H
		    INT	    21H
		    MOV	    AX,methd2Stat
		    CALL    PUTDEC$
		    MOV	    AX,[methd2Stat+2]
		    CALL    PUTDEC$
		    MOV	    AX,[methd2Stat+4]
		    CALL    PUTDEC$

		    LEA	    DX,METH3MSG
		    MOV	    AX,0900H
		    INT	    21H
		    MOV	    AX,methd3Stat
		    CALL    PUTDEC$
		    MOV	    AX,[methd3Stat+2]
		    CALL    PUTDEC$
		    MOV	    AX,[methd3Stat+4]
		    CALL    PUTDEC$
		
	    quit:
		    LEA	    DX,PAUSE
		    MOV	    AX,0900H
		    INT	    21H
		    CALL    GETDEC$
		    MOV	    AX,4C00H
		    INT	    21H
	    END main

