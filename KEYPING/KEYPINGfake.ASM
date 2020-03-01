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

MyStack	WORD	200 dup(0)
MySP	LABEL	WORD
myspace	BYTE	0
oldSP	WORD 	?
empty	byte	50 dup(0)
OldDS	WORD	?
OldSS	WORD	?

MyStack1	WORD	200 dup(0)
MySP1		LABEL	WORD
myspace1	BYTE	0
oldSP1		WORD 	?
empty1		byte	50 dup(0)
OldDS1		WORD	?
OldSS1		WORD	?

Check	BYTE	"Keyboard Interupt Handler", 0dh, 0ah, 0


KeyboardHandlerfake Proc
	sti
	pushf
	push	ax
	push	es

	mov	cs:mystr, "H"

	;; Load the keyboard status flag

	mov	ax, DOSDATA
	mov	es, ax

	;; clear the shift right flag

	mov	al, 0feh
	and	es:[KEYFLAG], al

	mov	al, es:[KEYFLAG]	; location of keyboard flag

	test	al, CTRL
	jz	done
	mov	cs:controlPressed, 1
	done:
	pop	es
	pop	ax
	popf
	jmp	DWORD PTR cs:old_key
KeyboardHandlerfake endp






KeyboardHandler Proc
	jmp 	DWORD PTR CS:[old_key]
	;setup
	;cli
	;mov	ax, SS
	;mov	OldSS1, ax

	;mov	ax, DS
	;mov	OldDS1, ax

	;mov	ax, CS
	;mov	SS, ax
	;mov	DS, ax

	;mov	ax, sp
	;mov	oldsp1, ax

	;mov	ax, OFFSET MySP1
	;mov	sp, ax

	;body
	;push	dx
	;mov	dx, offset cs:check
	;Call	PrintString
	;pop	dx

	;return
	;mov	ax, OldSS1
	;mov	SS, ax

	;mov	ax, OldDS1
	;mov	DS, ax

	;mov	ax, oldsp1
	;mov	sp, ax

KeyboardHandler endp


old_key LABEL DWORD
old_keySeg 	WORD  0 ;from ES
old_keyOffset 	WORD  0 ; from BX
x							WORD	0

KeyboardIVT = 36

IKBH Proc  ; Install Keyboard Handler

	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	ES

	mov	ax, 0
	mov	es, ax
	mov	bx, KeyboardIVT * 4

	mov	dx, es:[bx]
	mov	cx, es:[bx+2]


	mov	old_keySeg, dx
	mov	old_keyOffset, cx

	mov	dx, CS
	mov	cx, cs:KeyboardHandler

	mov	es:[bx], dx
	mov	es:[bx+2], cx

	pop	ES
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	pop	bp
	ret
IKBH endp

Clock proc
	pushf
	push	ax
	push	dx
	;mov	dx, GoByte
	;mov	ax, 1

;L1:
	;call	GetTime
	;call	PrintTime
	;call	CheckGO
	;cmp	ax, 1
	;je	L1
	pop	dx
	pop	ax
	popf
	ret
Clock endp


PrintString Proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	mov	bx, dx

print:
	mov	dl, cx:[bx]
	cmp	dl, 0
	je	brk
	mov	ah, 02h
	int	21h	;CITE: BAILEY
	inc	bx
	jmp	print

brk:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf

	ret
PrintString endp

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

	;mov		dx, offset old_key
	;Call	PrintString

	;Call	IKBH

	;mov		dx, offset old_key
	;Call	PrintString

	mov	ax, 4C00h
	int	21h

END entryPoint
