;;ARREXMPL.asm
;;               Written by Bruce Douglass 10/24/11 for CISP310
;;Array processing example program
;;  ML arrexmpl.asm util.lib

INCLUDE PCMAC.INC
        .MODEL  SMALL
        .586
        .STACK  100h
        .DATA
Message DB  'Enter the month number $'
endmsg  DB  'Enter a value to exit  $'
arr     db 31,28,31,30,31,30,31,31,30,31,30,31
month   db 'JAN$FEB$MAR$APR$MAY$JUN$JUL$AUG$SEP$OCT$NOV$DEC$'
        .CODE
        EXTRN   PutDec : NEAR,getdec:near
ARREX   PROC
        _Begin
        _PutStr Message
        call getdec          ;get month number
        dec ax               ;adjust for element 0
        push ax              ;save ax for later
        mov di,ax       
        mov al,[arr+di]      ;retrieve data from array using register
        call    PutDec
        _PutCh  13, 10
        pop ax               ;get old value of ax
        mov bl,4             ;mult by size of elements
        imul bl              ;ax now contains location in array
        add ax,offset month  ;retrieve string data from array
        _putstr ax
        _PutCh  13, 10
	_putstr endmsg
	call getdec
        _Exit   0
ARREX   ENDP
        END     ARREX

