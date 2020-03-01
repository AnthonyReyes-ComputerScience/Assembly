Title Keyping

;Anthony Reyes
;keyping.asm
;

.model tiny
.386
.code

	org	100h
entryPoint:
	jmp 	setup


TERMINATE	= 4C00h		; DOS code for terminating a program
DOS		= 21h		; DOS interrupt code

DOSDATA = 40h

KEYFLAG = 17h
CTRL = 4
ALT = 8
RIGHTSHIFT = 1
LEFTSHIFT = 2

MyStack		WORD	200 dup(0)
MySP		LABEL	WORD
myspace		BYTE	0
oldSP		WORD 	?
empty		byte	50 dup(0)
OldDS		WORD	?
OldSS		WORD	?

MyStack1		WORD	200 dup(0)
MySP1		LABEL	WORD
myspace1		BYTE	0
oldSP1		WORD 	?
empty1		byte	50 dup(0)
OldDS1		WORD	?
OldSS1		WORD	?

MyStack2		WORD	200 dup(0)
MySP2		LABEL	WORD
myspace2		BYTE	0
oldSP2		WORD 	?
empty2		byte	50 dup(0)
OldDS2		WORD	?
OldSS2		WORD	?

ControlPressed	BYTE 0

harry	BYTE "0123456789ABCDEF", 0

;---------------------Keyboard Handler-----------------------------

old_key 	LABEL 	DWORD
old_keySeg 	WORD  	0
old_keyOffset 	WORD  	0

KeyboardIVT = 9h

;int 10h
	;AH = 09h
	;AL = character to display
	;BH = page number (00h to number of pages - 1) (see #00010)
	;background color in 256-color graphics modes (ET4000)
	;BL = attribute (text mode) or color (graphics mode)
	;if bit 7 set in <256-color graphics mode, character is XOR'ed
	;onto screen
	;CX = number of times to write character

KeyboardHandler Proc
	mov	ax, SS		;SS
	mov	OldSS1, ax	;SS

	mov	ax, DS		;DS
	mov	OldDS1, ax	;DS

	mov	ax, CS		;CS
	mov	SS, ax
	mov	DS, ax

	mov	ax, sp		;SP
	mov	oldsp1, ax

	mov	ax, OFFSET cs:MySP1
	mov	sp, ax
	;
	pushf
	push	ax
	push	es

	;; Load the keyboard status flag

	mov	ax, DOSDATA
	mov	es, ax

	;; clear the shift right flag
	mov 	ah, 12h
	int 	16h		;ax has keyflags
	cli
	test	al, CTRL
	jz	shift
	test	al, alt
	jz	shift
	call 	WaitOnControl
	sti
	call 	RestoreText
	call 	RestoreCursor

shift:
	test	al, RIGHTSHIFT
	jz	done
shift2:
	test 	al, LEFTSHIFT
	jz 	done
	sti
	cmp	clockon, 0
	jne 	clockoff
	call 	getCursor
	mov	clockon, 1
	jmp 	done
clockoff:
	mov	clockon, 0
	mov 	textsaved, 1
	call 	RestoreText
	call 	RestoreCursor
done:
	sti
	pop	es
	pop	ax
	popf

	mov	ax, OldSS1	;SS
	mov	SS, ax		;SS

	mov	ax, OldDS1	;DS
	mov	DS, ax		;DS

	mov	ax, oldsp1
	mov	sp, ax		;SP

	jmp	DWORD PTR cs:old_key
KeyboardHandler endp


RestoreKBH Proc  	; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	cx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, KeyboardIVT * 4

	mov	ax, old_keySeg
	mov	cx, old_keyOffset

	mov	es:[bx], ax
	mov	es:[bx+2], cx

	pop	ES
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
RestoreKBH endp


InstallKBH Proc  ; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, KeyboardIVT * 4

	mov	es:[bx], KeyboardHandler
	mov	es:[bx+2], cs

	pop	ES
	pop	bx
	pop	ax
	popf
	ret
InstallKBH endp

SaveKBH Proc  ; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	cx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, KeyboardIVT * 4

	mov	ax, es:[bx]
	mov	cx, es:[bx+2]

	mov	old_keySeg, ax
	mov	old_keyOffset, cx

	pop	ES
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
SaveKBH endp

;------------------------------------------------------------------

;---------------------Clock Handler-----------------------------

old_clock 	LABEL 	DWORD
old_clockOffset 	WORD  	0
old_clockSeg 		WORD  	0

clockon		byte 	0
textsaved 	byte	0

ClockIVT = 8h

ClockHandler Proc
	mov	ax, SS		;SS
	mov	OldSS2, ax	;SS

	mov	ax, DS		;DS
	mov	OldDS2, ax	;DS

	mov	ax, CS		;CS
	mov	SS, ax
	mov	DS, ax

	mov	ax, sp		;SP
	mov	oldsp2, ax

	mov	ax, OFFSET cs:MySP2
	mov	sp, ax

	cmp 	clockon, 1
	jne 	handle
	call 	clock ;Replacing str in KBH
handle:



	mov	ax, OldSS2	;SS
	mov	SS, ax		;SS

	mov	ax, OldDS2	;DS
	mov	DS, ax		;DS

	mov	ax, oldsp2
	mov	sp, ax		;SP

	jmp	DWORD PTR cs:old_clock
ClockHandler endp


RestoreCH Proc  ; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	cx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, ClockIVT * 4

	mov	ax, old_clockOffset
	mov	cx, old_clockSeg

	mov	es:[bx], ax
	mov	es:[bx+2], cx

	pop	ES
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
RestoreCH endp


;------------------------------------------------------------------

oldCursor	LABEL	BYTE
OCrow		byte 	0
OCcol		BYTE	0
OCpgnum 	byte 	0
NCrow		byte 	0
NCcol		BYTE	72



; http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm

;INT 10h / AH = 03h - get cursor position and size.
;input:
;BH = page number.
;return:
;DH = row.
;DL = column.
;CH = cursor start line.
;CL = cursor bottom line.


clock PROC
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	es
	call 	getCursor
	cmp 	textsaved, 1
	je 	go
	call	getStr
	mov 	textsaved, 1

go:
	mov 	al, NCrow
	mov	bl, NCcol
	push 	ax
	push  	bx
	call 	SetCursor
	add 	sp, 4
	call 	getTime
	call 	FormatTime
	call 	PrintTime

	call 	RestoreCursor
	pop 	es
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	ret
clock endp


OldStr	LABEL	BYTE
oldChrs BYTE	8 dup("0")

getStr PROC ;gets and saves strings in memory
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	di
	mov 	di, 0

	mov 	cx, 7
grab:

	mov 	al, NCrow
	mov	dl, NCcol
	add 	dl, cl
	push  	dx
	push 	ax
	call 	SetCursor
	add 	sp, 4

	call 	readAt	;AH = character's attribute (text mode only) (see #00014)
			;AL = character
	mov 	di, cx
	mov 	bx, offset oldChrs
	mov 	cs:[bx + di], al
	dec	cx
	cmp 	cx, -1
	jne 	grab
	jmp 	done

done:

	call 	RestoreCursor

	pop 	di
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	ret
getStr endp

readAt PROC		;ret:	AH = character's attribute (text mode only) (see #00014)
			;	AL = character
	pushf
	push 	bx

	mov 	bx, 0
	mov	ah, 08h
	int 	10h

	pop 	bx
	popf
	ret
readAt endp

RestoreText PROC  ;; PRINT STRING OF TIME IN MEM
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	bp
	push 	es

	push 	cs
	pop 	es

	mov  	bp, offset oldChrs
	mov 	cx, 8

	mov  	al, 0
	mov 	bl, 111b   ;Color is red
	mov  	bh, 0     ;Display page
	mov  	dl, NCcol ;col
	mov	dh, NCrow ;row
	mov  	ah, 13h   ;print str

	int  10h

	pop 	es
 	pop 	bp
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	ret
RestoreText endp


; int 1Ah
;AH = 02h
;CF clear to avoid bug (see below)

;Return:
;CF clear if successful
;CH = hour (BCD)
;CL = minutes (BCD)
;DH = seconds (BCD)
;DL = daylight savings flag (00h standard time, 01h daylight time)
;CF set on error (i.e. clock not running or in middle of update)

CurTime Label	BYTE
H 	byte 	0, 0
colon 	byte 	":"
M 	byte 	0, 0
colon2 	byte 	":"
S 	byte 	0, 0

FormatTime proc
	push 	bx
	mov 	bx, offset H
	push 	bx
	call 	FT
	add 	sp, 2

	mov 	bx, offset M
	push 	bx
	call 	FT
	add 	sp, 2

	mov 	bx, offset S
	push 	bx
	call 	FT
	add 	sp, 2
	pop 	bx
FormatTime endp

FT PROC
	push 	bp
	mov 	bp, sp
	pushf
	push	bx
	push	cx
	push	dx
	push	ax

	mov 	ax, 0
	mov 	cx, 0
	mov 	dx, 0

	mov 	bx, SS:[bp + 4]
	mov 	al, cs:[bx]
	mov	dl, al
	mov 	cl, 4

make:
	;bcd decoder UGHGHHGHGHGHHHG
	pushf
	shr	al, cl
	popf
	add 	al, "0"
	mov 	cs:[bx], al
	and 	dl, 0fh
	add 	dl, "0"
	mov 	cs:[bx + 1], dl
rt:
	pop	ax
	pop	dx
	pop	cx
	pop	bx
	popf
	pop 	bp
	ret
FT ENDP

getTime PROC
 	pushf
	push 	cx
	push 	dx
get:
 	mov 	ah, 02
	int 	1Ah

	mov 	H, ch
	mov 	M, cl
	mov 	S, dh

	jc	get

	pop 	dx
	pop 	cx
 	popf
	ret
getTime endp

;NCrow		byte 	0
;NCcol		BYTE	72

;INT 10h / AH = 13h - write string.

;input:
;AL = write mode:
;    bit 0: update cursor after writing;
;    bit 1: string contains attributes.
;BH = page number.
;BL = attribute if string contains only characters (bit 1 of AL is zero).
;CX = number of characters in string (attributes are not counted).
;DL,DH = column, row at which to start writing.
;ES:BP points to string to be printed.

PrintTime PROC  ;; PRINT STRING OF TIME IN MEM
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	bp
	push 	es

	push 	cs
	pop 	es

	mov  	bp, offset CurTime
	mov 	cx, 8

	mov  	al, 0
	mov 	bl, 0Dh   ;Color is red
	mov  	bh, 0     ;Display page
	mov  	dl, NCcol ;col
	mov	dh, NCrow ;row
	mov  	ah, 13h   ;print str

	int  10h

	pop 	es
 	pop 	bp
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	ret
PrintTime endp

getCursor PROC ; Gets cursor and saves in mem as ocrow and occol
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx

	mov 	ah, 03h
	mov 	bh, 0
	int 	10h   	; get cursor

	mov 	OCrow, dh ; old row
	mov 	OCcol, dl ; old col

	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	ret
getCursor endp

SetCursor PROC
	push 	bp
	mov 	bp, sp
	pushf
	push 	ax
	push 	bx
	push 	cx
	push 	dx

	mov	cx, [bp + 4]
	mov	dx, [bp + 6]	;col
	mov  	dh, cl  ;	;Row
	mov  	bh, 0    	;Display page
	mov  	ah, 02h  	;SetCursorPosition
	int  	10h

	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax
	popf
	pop 	bp
	ret
SetCursor endp

RestoreCursor PROC
	pushf
	push 	ax
	push 	bx
	push 	dx

	mov  dl, OCcol   ;Column
	mov  dh, OCrow   ;Row
	mov  bh, 0       ;Display page
	mov  ah, 02h     ;SetCursorPosition
	int  10h

	pop 	dx
	pop 	bx
	pop 	ax
	popf
	ret
RestoreCursor endp

WaitOnControl PROC
	pushf
check:
	cmp	ControlPressed, 0
	je	check

	call 	RestoreKBH
	call	RestoreCH

	popf
	ret
WaitOnControl ENDP

;------------------------------------- nonTSR under here ----------
CUT	LABEL 	BYTE

InstallCH Proc  ; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, ClockIVT * 4

	mov	es:[bx], ClockHandler
	mov	es:[bx+2], cs

	pop	ES
	pop	bx
	pop	ax
	popf
	ret
InstallCH endp

SaveCH Proc  ; Install Keyboard Handler
	pushf
	push	ax
	push	bx
	push	cx
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, ClockIVT * 4

	mov	ax, es:[bx]
	mov	cx, es:[bx+2]

	mov	old_ClockOffset, ax
	mov	old_ClockSeg, cx

	pop	ES
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
SaveCH endp

mystr	byte	"a", 0

setup:
	mov	ax, SS		;SS
	mov	OldSS, ax	;SS

	mov	ax, DS		;DS
	mov	OldDS, ax	;DS

	mov	ax, CS		;CS
	mov	SS, ax
	mov	DS, ax

	mov	ax, sp		;SP
	mov	oldsp, ax

	mov	ax, OFFSET cs:MySP
	mov	sp, ax
	; END OF SEG SETUP

	call	SaveKBH
	call	InstallKBH

	call	SaveCH
	call	InstallCH

	call 	WaitOnControl

	;mov 	ax, 0
	;mov 	ah, 31h
	;mov 	cx, cs
	;mov 	es, cx
	;lea 	dx, CUT

	mov 	ax, 4c00h
	int 	21h

END entryPoint
