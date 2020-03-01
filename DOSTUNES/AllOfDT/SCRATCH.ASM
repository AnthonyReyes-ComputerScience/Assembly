Title scratch

;---------------code only for non commercial use ------------------------

.MODEL MEDIUM ;
.STACK 200H ; Set up 512 bytes of stack space
.386

;===========================================================================

.DATA

CR EQU 13
LF EQU 10
X1 dw 30
X2 dw 170
Y1 dw 30
Y2 dw 170
color equ 50h
IncF dw 10h
DeX Dw 0000h
DeY Dw 0000h

.CODE
;--------------------------------------------------------------------

InitializeMCGA PROC

MOV AX, 0A000h
MOV ES, AX ; ES now points to the VGA

MOV AH, 00H ; Set video mode
MOV AL, 13H ; Mode 13h
INT 10H ; We are now in 3201700017056
RET

InitializeMCGA ENDP

TextMode PROC
MOV AH, 00H ; Set video mode
MOV AL, 03H ; Mode 03h
INT 10H ; Enter 801705306 mode

MOV DX, OFFSET AllDone ; DS:DX points to the ending message
MOV AH, 09H
INT 21H ; Display the ending message
RET
TextMode ENDP


;CODE BY PRATIK M TAMBE

;----------------------------------------------------------------------------
; PROCEDURE ADAPTED FROM Adam's Assembler Tutorial SERIES
; MANY THANKS TO HIM!!!  ;---------------------------------------------------------------------------
DRAWLINE2 PROC

mov ax, X2 ; Move X2 into AX ;
sub ax, X1 ; Get the horiz length of the line - X2 - X1 ;
jnc @Dont1 ; Did X2 - X1 yield a negative result? ;
neg ax ; Yes, so make the horiz length positive ;

@Dont1:
mov DeX, ax ; Now, move the horiz length of line into DeX ;
mov ax, Y2 ; Move Y2 into AX ;
sub ax, Y1 ; Subtract Y1 from Y2, giving the vert length ;
jnc @Dont2 ; Was it negative? ;
neg ax ; Yes, so make it positive ;

@Dont2:
mov DeY, ax ; Move the vert length into DeY ;
cmp ax, DeX ; Compare the vert length to horiz length ;
jbe @OtherLine ; If vert was <= horiz length then jump ;

mov ax, Y1 ; Move Y1 into AX ;
cmp ax, Y2 ; Compare Y1 to Y2 ;
jbe @DontSwap1 ; If Y1 <= Y2 then jump, else... ;
mov bx, Y2 ; Put Y2 in BX ;
mov Y1, bx ; Put Y2 in Y1 ;
mov Y2, ax ; Move Y1 into Y2 ;
; So after all that..... ;
; Y1 = Y2 and Y2 = Y1 ;

mov ax, X1 ; Put X1 into AX ;
mov bx, X2 ; Put X2 into BX ;
mov X1, bx ; Put X2 into X1 ;
mov X2, ax ; Put X1 into X2 ;

@DontSwap1:
mov IncF, 1 ; Put 1 in IncF, ie, plot another pixel ;
mov ax, X1 ; Put X1 into AX ;
cmp ax, X2 ; Compare X1 with X2 ;
jbe @SkipNegate1 ; If X1 <= X2 then jump, else... ;
neg IncF ; Negate IncF ;

@SkipNegate1:
mov ax, Y1 ; Move Y1 into AX ;
mov bx, 320 ; Move 320 into BX ;
mul bx ; Multiply 320 by Y1 ;
mov di, ax ; Put the result into DI ;
add di, X1 ; Add X1 to DI, and tada - offset in DI ;
mov bx, DeY ; Put DeY in BX ;
mov cx, bx ; Put DeY in CX ;
mov ax, 0A000h ; Put the segment to plot in, in AX ;
mov es, ax ; ES points to the VGA ;
mov dl, Color ; Put the color to use in DL ;
mov si, DeX ; Point SI to DeX ;

@DrawLoop1:
mov es:[di], dl ; Put the color to plot with, DL, at ES:DI ;
add di, 320 ; Add 320 to DI, ie, next line down ;
sub bx, si ; Subtract DeX from BX, DeY ;
jnc @GoOn1 ; Did it yield a negative result? ;
add bx, DeY ; Yes, so add DeY to BX ;
add di, IncF ; Add the amount to increment by to DI ;

@GoOn1:
loop @DrawLoop1 ; No negative result, so plot another pixel ;
jmp @ExitLine ; We're all done, so outta here! ;

@OtherLine:
mov ax, X1 ; Move X1 into AX ;
cmp ax, X2 ; Compare X1 to X2 ;
jbe @DontSwap2 ; Was X1 <= X2 ? ;
mov bx, X2 ; No, so move X2 into BX ;
mov X1, bx ; Move X2 into X1 ;
mov X2, ax ; Move X1 into X2 ;
mov ax, Y1 ; Move Y1 into AX ;
mov bx, Y2 ; Move Y2 into BX ;
mov Y1, bx ; Move Y2 into Y1 ;
mov Y2, ax ; Move Y1 into Y2 ;

@DontSwap2:
mov IncF, 320 ; Move 320 into IncF, ie, next pixel is on next row ;
mov ax, Y1 ; Move Y1 into AX ;
cmp ax, Y2 ; Compare Y1 to Y2 ;
jbe @SkipNegate2 ; Was Y1 <= Y2 ? ;
neg IncF ; No, so negate IncF

@SkipNegate2:
mov ax, Y1 ; Move Y1 into AX ;
mov bx, 320 ; Move 320 into BX ;
mul bx ; Multiply AX by 320 ;
mov di, ax ; Move the result into DI ;
add di, X1 ; Add X1 to DI, giving us the offset ;
mov bx, DeX ; Move DeX into BX ;
mov cx, bx ; Move BX into CX ;
mov ax, 0A000h ; Move the address of the VGA into AX ;
mov es, ax ; Point ES to the VGA ;
mov dl, Color ; Move the color to plot with in DL ;
mov si, DeY ; Move DeY into SI ;

@DrawLoop2:
mov es:[di], dl ; Put the byte in DL at ES:DI ;
inc di ; Increment DI by one, the next pixel ;
sub bx, si ; Subtract SI from BX ;
jnc @GoOn2 ; Did it yield a negative result? ;
add bx, DeX ; Yes, so add DeX to BX ;
add di, IncF ; Add IncF to DI ;

@GoOn2:
loop @DrawLoop2 ; Keep on plottin' ;

@ExitLine:
; All done! ;
; End;
RET
DRAWLINE2 ENDP

Start:

MOV AX, @DATA
MOV DS, AX ; DS now points to the data segment.

CALL InitializeMCGA ; ENTER MODE 13H

CALL DRAWLINE2 ; CALL PROCEDURE TO DRAW ACTUAL LINE


MOV AH, 00H ; Yes, so get the key
INT 16H

CALL TextMode

MOV AH, 00H ; Yes, so get the key
INT 16H



MOV AH, 4CH
MOV AL, 00H
INT 21H ; Return to DOS/QUIT PROGRAM.
END Start
