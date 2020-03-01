Title DosTunes

.model huge

.386
.stack 100h
.data
.code

DOSEXIT=4C00h
DOS = 21h
BIOS = 10h

.data
Af	word 	52, 103, 208, 415, 830, 1661, 3322
notes 	label 	word
A	word 	55, 110, 220, 440, 880, 1760, 3520
As_Bf	word 	58, 116, 233, 466, 932, 1865, 3729
B	word 	61, 123, 247, 493, 988, 1975, 3951
none	word 	61, 123, 247, 493, 988, 1975, 3951
C1 	word 	32, 65,  130, 262, 523, 1046, 2093
Cs_Df	word 	34, 69,  138, 277, 554, 1108, 2217
D	word 	36, 73,  147, 293, 587, 1174, 2349
Ds_Ef	word 	39, 77,  155, 311, 622, 1244, 2489
E	word 	41, 82,  165, 329, 659, 1318, 2637
none2	word 	61, 123, 247, 493, 988, 1975, 3951
F	word 	43, 87,  175, 349, 698, 1397, 2794
Fs_Gf	word 	46, 92,  185, 370, 740, 1480, 2960
G	word 	49, 97,  196, 392, 784, 1568, 3136
Gs_Af	word 	52, 103, 208, 415, 830, 1661, 3322
safe 	word 	50 dup("ø")


raw		BYTE	100 dup(0)
filename	BYTE	100 dup(0)
buffer		BYTE	0, 0
space		BYTE	100 dup(0)
filehandle	WORD	?
fee		BYTE	"YO, YOUR FILE DON'T OPEN", 0
noteTime 	Word 	?


.code

;;;;;;;-----------------FILE STUFF BELOW ----------------------------
;;;;;;;-----------------FILE STUFF BELOW ----------------------------
;;;;;;;-----------------FILE STUFF BELOW ----------------------------


;MODIFIED ONLY 7e >  ASCIIZ > 32
PrintString Proc ; takes offset in DX and prints string
	pushf
	push	ax
	push	bx
	push	dx

	mov	bx, dx
	jmp	print
dot:
	mov	dl, "."
	mov	ah, 02h
	int	21h
	inc	bx
	jmp	print
print:
	mov	dl, [bx]
	cmp	dl, 0h
	je	brk

	cmp	dl, 126
	jg	dot

	cmp	dl, 32
	jl	dot
	mov	ah, 02h
	int	21h
	inc	bx
	jmp	print
brk:
	pop	dx
	pop	bx
	pop	ax
	popf
	ret
PrintString endP

FileIn proc
	push 	ax
	push	bx
	push	cx
	push	dx
	jmp 	go
exit:
	mov	ax, OGMode
	call	SetVideoMode
	mov 	ax, 4C00h
	int 	21h

go:
	mov	bx, filehandle
	mov	cx, 1h
	mov	dx, offset buffer
	mov	eax, 0

	mov	ah, 3Fh; read
	int	21h

	cmp 	ax, 0
	je 	exit

brk:

	pop	dx
	pop	cx
	pop	bx
	pop 	ax
	ret
FileIn endp

SegCopy proc
; SegCopy:takes di and copies into DS:filename (DS:[bx + si]) from EX:[di++]
; return in BX of file address (OFFSET filename)
	pushf
	push	dx
	push	di
	push	si
	push	cx

	mov	si, 0
	mov	bx, OFFSET raw

	mov	ch, 0
	mov	cl, ES:[di]

	inc	di

L1:
	cmp	cx, 0
	je	brk
	mov	dl, ES:[di]

	mov	DS:[bx + si], dl

	inc	di
	inc	si
	dec	cx
	jmp	L1

brk:
	pop	cx
	pop	si
	pop	di
	pop	dx
	popf
	ret
SegCopy endP

openFile proc
	push	dx

	mov	dx, bx
	mov	al, 0

	mov	ah, 3dh ; ax takes file handle for reading
	int	21h
	pop	dx
	ret
openFile endp

closeFile proc
	pusha

	mov	bx, ax
	mov	ah, 3eh
	int	21

	popa
closeFile endp

getFileName Proc
; return in bx location of file name in DS (DS:[bx])
; SegCopy: takes di and copies into DS:filename (DS:[bx + si]) from EX:[di++]
	pushf
	push	ax
	push	di
	push	ES

	mov	ah, 62h
	int	21h     ;put PSP in bx

	mov	ES, bx
	mov	di, 80h

	call	segCopy  ;file name @ in bx

	pop	ES
	pop	di
	pop	ax
	popf
	ret
getFileName endP

cleanname proc
	pusha
	mov	bx, offset raw
	mov	bp, offset filename
	mov	si, 0
L1:
	mov	dl, [bx + si]
	cmp	dl, 20h
	je	BR
L2:
	cmp	si, 100
	je	done
	mov	DS:[bp], dl
	inc	bp
	inc	si
	mov	dl, [bx + si]
	cmp	dl, 20h
	je	done
	cmp	dl, 0
	je	done
	jmp	L2

BR:
	inc	si
	mov	dl, [bx + si]
	cmp	dl, 20h
	je	br
	jne	L2
done:
	popa
	mov	bx, offset filename
	ret
cleanname endp

;;;;;;;-----------------FILE STUFF ABOVE ------------------------------
;;;;;;;-----------------FILE STUFF ABOVE ------------------------------
;;;;;;;-----------------FILE STUFF ABOVE ------------------------------

;; Returns:
;; 	AL - Video Mode
;; 	AH - Number of character columns
;; 	BH - Active Page
GetVideoMode PROC
	push	cx
	push	ax

	mov	ah, 0fh
	int	BIOS
	mov	cl, al

	pop	ax
	mov	al, cl
	pop	cx
	ret
GetVideoMode ENDP

;; AL - Video mode

SetVideoMode PROC
	push	ax

	mov	ah, 00
	int	BIOS

	pop	ax
	ret
SetVideoMode ENDP

;; BH - Page number
;; CX - X
;; DX - Y
;;
;; Returns:
;;
;; AL - Color

ReadPixel PROC
	push	ax

	mov	ah, 0dh
	int	BIOS

	pop	ax
	ret
ReadPixel ENDP

;; AL - Color
;; BH - Page
;; CX - X
;; DX - Y
WritePixel PROC
	push	ax

	mov	ah, 0fch
	int	BIOS

	pop	ax
	ret
WritePixel ENDP

;; BL - Palette id

SetPalette PROC
	push	ax
	push	bx

	mov	ah, 0bh
	mov	bh, 01h
	int	BIOS

	pop	bx
	pop	ax
	ret
SetPalette ENDP


;; AL - Pallete Index
;; AH - Red
;; CX - Blue:Green

SetPalleteColor PROC
	push	ax
	push	dx

	mov	dx, 3c8h	; Video pallete port
	out	dx, al		; Write the color out

	mov	dx, 3c9h	; Color selection port

	mov	al, ah		; Red
	out	dx, al
	mov	al, cl		; Green
	out	dx, al
	mov	al, ch		; Blue
	out	dx, al

	pop	dx
	pop	ax
	ret
SetPalleteColor ENDP

;; BX - Color Index
;; CX - X
;; DX - Y
DrawPixel PROC
;; Screen resolution is 320x200

	push	ax
	push	dx
	push	di
	push	es

	mov	ax, 320
	mul	dx		; AX = 320 * Y
	add	ax, cx		; AX = 320 * Y + X

	mov	di, ax		; Set di to the offset

	push	0A000h		; Set ES to the video segment
	pop	es

	mov	BYTE PTR es:[di], bl ; Set the pixel to the given color

	pop	es
	pop	di
	pop	dx
	pop	ax
	ret
DrawPixel ENDP

;--------------------------------- Delay ------------------------------------
; gets a number of mms from the stack and returns when that amount
; of time (in mms) has elapsed
; AH = 2Ch int 21h get system time -> CH = Hour, CL = min, DH = sec, DL = 1/10s
; check time fast and return

GetNow Proc
	push	ax
	mov	ah, 2Ch
	int	21h
	pop	ax
	ret
GetNow Endp

TimeChange Proc
	pushf
	call	GetNow
	mov	bl, dl
L1:
	call	GetNow
	cmp	bl, dl
	ja	L2
	jb	G1
	jmp	L1
L2:
	add	dl, 100
	sub	dl, bl
	mov	bl, dl
	jmp	done
G1:
	sub	dl, bl
	mov	bl, dl
done:
	mov	bh, 0
	popf
	ret
TimeChange Endp

Delay PROC
	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, 0
	mov	bx, 10
	mov	ax, noteTime ; get mms
	div	bx
			;AX has Cent-secs
	mov	bx, 0
	call	GetNow
stall:
	Call	TimeChange
	sub	ax, bx
	jc	done
	jmp	stall
done:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	pop	bp
	ret
Delay ENDP

READY_TIMER		= 0B6h
TIMER_DATA_PORT		= 42h
TIMER_CONTROL_PORT	= 43h
SPEAKER_PORT		= 61h

.data
MUTED 	BYTE 	0
.code

SpeakerOn PROC
	pushf
	push	ax

	cmp	MUTED, 1
	je	done

	in	al, SPEAKER_PORT		; Read the speaker register
	or	al, 03h				; Set the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register

	done:
	pop	ax
	popf
	ret
SpeakerOn ENDP

SpeakerOff PROC

	pushf
	push	ax

	in	al, SPEAKER_PORT		; Read the speaker register
	and	al, 0FCh			; Clear the two low bits high
	out	SPEAKER_PORT, al		; Write the speaker register

	pop	ax
	popf
	ret
SpeakerOff ENDP
.data
FREQUENCY 	DWORD 	1193180d
.code
FreqToCount PROC
	pushf
	push 	ax
	push 	ecx
	mov 	ecx, 0
	mov 	cx, dx
	mov 	eax, FREQUENCY
	mov 	dx, 0
	div 	ecx
	mov	edx, 0
	mov 	dx, ax

	pop 	ecx
	pop 	ax
	popf
	ret
FreqToCount ENDP

PlayFrequency PROC
;; Frequency is found in DX

	pushf
	push	ax

	call	FreqToCount

	mov	al, READY_TIMER			; Get the timer ready
	out	TIMER_CONTROL_PORT, al

	mov	al, dl
	out	TIMER_DATA_PORT, al		; Send the count low byte

	mov	al, dh
	out	TIMER_DATA_PORT, al		; Send the count high byte

	pop	ax
	popf
	ret
PlayFrequency ENDP

liner PROC
	pushf
	push 	ax
	push 	cx
	push 	dx
	push 	es
horiz:
	mov 	di, 0a000h
	mov 	es, di
	mov 	edi, 7000
	add 	edi, 75
	mov 	al,bl
	mov 	cx, 160
hplot:
	mov 	es:[edi],al
	inc 	edi
	loop	hplot
horiz2:
	mov 	edi, 32000
	add 	edi, 15
	mov 	al,bl
	mov 	cx, 160
hplot2:
	mov 	es:[edi],al
	inc 	edi
	loop	hplot2
vert:
	mov 	edi, 16000
	add 	edi, 160
	mov 	cx, 100
vplot:
	mov 	es:[edi],al
	add 	edi, 90
	loop	vplot

vert2:
	mov 	edi, 6000
	add 	edi, 20
	mov 	cx, 100
vplot2:
	mov 	es:[edi],al
	add 	edi, 320
	loop	vplot2

done:
	inc bx
	pop 	es
	pop 	dx
	pop 	cx
	pop 	ax
	popf
	ret
liner endP

GetNote PROC
	push 	cx
	push 	dx

	mov 	al, BUFFER
	sub 	al, "a"

	mov 	dx, 0
	mov 	cx, ax
	mov 	ax, 2
	mul 	cx

	pop 	dx
	pop 	cx
	ret
GetNote ENDP

.DATA
scoreErr 	byte 	"Your score isn't in the right format.", 0, 0dh, 0ah

.code

GetAccidental PROC
	push 	cx
	push 	dx
	mov 	cx, 0

	call 	FileIn
	mov 	cl, BUFFER
	cmp	cx, "#"
	je 	sharp

	cmp	cx, "b"
	je 	fl

	cmp 	cx, " "
	je 	done
	jne 	err

sharp:
	inc 	ax
	jmp 	done
fl:
	dec 	ax
	jmp 	done
err:
	mov	ax, OGMode
	call	SetVideoMode
	mov 	dx, offset scoreErr
	call 	printString
	mov 	ax, 4C00h
	int 	21h
done:

	pop 	dx
	pop 	cx
	ret
GetAccidental ENDP

GetOctave PROC

	call 	FileIn
	; call 	testing
	mov 	bx, 0

	mov 	bl, BUFFER

	sub 	bx, "0"

	sub 	bx, 1

	add 	ax, bx
	add 	ax, bx

	ret
GetOctave ENDP

convert PROC
	push 	ax
	push 	cx
	push 	dx


	mov 	ax, 0
	jmp 	go

go:
	call 	GetNote
	;handle sharps and flats
	call 	GetAccidental

	mov 	dx, 0
	mov 	cx, ax
	mov 	ax, 14
	mul 	cx

	;handle sharps and flats

	call 	GetOctave

	mov 	bx, offset notes
	add 	bx, ax

	pop 	ax
	pop 	cx
	pop 	dx
	ret
convert ENDP

getDur PROC
	push 	cx
	mov 	cx, 0

	call 	FileIn
	; call 	testing
	mov 	cl, BUFFER
	cmp	cx, "Q"
	je 	qu

	cmp	cx, "E"
	je 	eight

	cmp 	cx, "H"
	je 	half

	cmp 	cx, "W"
	je 	whole

	cmp 	cx, "D"
	je 	dotQ

	cmp 	cx, "T"
	je 	trip

	cmp 	cx, "S"
	je 	sixt
	jne 	err

sixt:
	mov  	noteTime, 250
	jmp 	done

trip:
	mov  	noteTime, 333
	jmp 	done

eight:
	mov  	noteTime, 500
	jmp 	done
qu:
	mov  	noteTime, 1000
	jmp 	done

dotQ:
	mov  	noteTime, 1500
	jmp 	done

half:
	mov  	noteTime, 2000
	jmp 	done
whole:
	mov  	noteTime, 4000
	jmp 	done

err:
	mov	ax, OGMode
	call	SetVideoMode
	mov 	dx, offset scoreErr
	call 	printString
	mov 	ax, 4C00h
	int 	21h
done:

	pop 	cx
	ret

	ret
getDur ENDP


PlayNote Proc
 	pushf
	push 	ax
	push	dx
	push 	bx
	push 	di
	jmp 	go
rest:
	pop 	ax
	call 	GetAccidental
	call 	GetOctave
	call 	getDur
	call	Delay
	jmp 	done

go:

	push	ax
	call 	FileIn
	; call 	testing
	mov 	al, BUFFER
	cmp 	al, "0"
	je 	rest
	pop 	ax

	call 	convert

	mov 	dx, [bx]
	call 	PlayFrequency
	call 	getDur
	call 	SpeakerOn
	call	Delay
	call 	SpeakerOff
done:
	pop 	di
	pop 	bx
	pop 	dx
	pop 	ax
	popf
	ret
PlayNote Endp

OGMode 	word 	?

main PROC
	mov 	ax, @data
	mov 	ds, ax
	jmp	strt
Fe:
	mov	dx, offset fee
	call	PrintString
	jmp	ExitDOS

strt:
	call	getFileName 	;file @ in bx
	call	cleanname

	pushf
	call	openFile
	jc	Fe

	popf
	;ax has file handle

	mov	filehandle, ax
	;FILE READY TO BE READ

	call	GetVideoMode
	mov	OGMode, ax
	mov	al, 13h		; 320x200 x 256 colors
	call	SetVideoMode


	mov	al, 0
	mov	ah, 0ffh		; AH: Red
	mov	cx, 0ffddh	; CH: Blue, CL: Green
	call	SetPalleteColor	; Set background (pallete 0) to blue

	mov	al, 1		; Set pallete color 1
	mov	ah, 0ffh	; Red
	mov	cx, 00000h	; CH: Blue, CL: Green
	call	SetPalleteColor

	mov	bx, 1		; Pallete
	mov	cx, 160		; X
	mov	dx, 100		; Y
	mov 	di, 44
	push 	di
 	jmp	loopcond
top:
	call	DrawPixel	;; BX - Color Index
				;; CX - X
				;; DX - Y
	call 	liner	  	; takes CX and DX
	call 	PlayNote
loopcond:
	jmp	top

	pop 	di
	mov	ax, OGMode
	call	SetVideoMode

ExitDOS:
	call	closeFile

	mov	ax, 4C00h	; Set up DOS function 4C: exit program
	int	21h
main ENDP

END main
