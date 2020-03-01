Title Hexdump
;Anthony Reyes
;Project 4
;CS 240


;MY ERROR SECTION/ WHAT NEEDS TO HAPPEN
;TEST
;clean filename function
; STAR IMPLEMENTAION

include cs240.inc

.386

.data
bytecount	DWORD	0h
raw		BYTE	100 dup(0)
filename	BYTE	100 dup(0)
buffer		BYTE	17 dup(0)
alumbo		BYTE	17 dup(0)
filehandle	WORD	?
harry		BYTE	"0123456789abcdef"
fee		BYTE	"YO, YOUR FILE DON'T OPEN", 0

.code

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
	cmp	dl, 0
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

openFile proc
	push	dx

	mov	dx, bx
	mov	al, 0

	mov	ah, 3dh ; ax takes file handle for reading
	int	21h
	pop	dx
	ret
openFile endp

inccount proc ; TAKES EAX PARAM TO INC 	

	sub	ecx, ecx
	add	ecx, bytecount
	add	ecx, eax
	mov	bytecount, ecx
	
	ret	
inccount endp

loadBuffer proc ; ret amount of bytes read in ax check for carry

	push	bx
	push	cx
	push	dx
	jmp	go
spec:
	mov	buffer, 0
	jmp	brk
go:
	mov	bx, filehandle
	mov	cx, 10h
	mov	dx, offset buffer
	mov	eax, 0

	mov	ah, 3Fh; read
	int	21h

	cmp	ax, 0
	je	spec
brk:

	pop	dx
	pop	cx
	pop	bx
	ret
loadBuffer endp   ; ax = amount of bytes read

counterout proc
	push	edx	
	mov	edx, bytecount 
	mov	cx, 8
	jmp	L1

L1:
	cmp	cx, 0
	je	done
	rol	edx, 4	
	call	PHD
	dec	cx
	jmp	L1
done:
	pop	edx
	ret
counterout endp

fill proc
	push	ax
	push	bx
	mov	bx, 10h
	sub	bx, ax
	mov	ax, bx
	cmp	ax, 8
	jle	L1
	call	space
L1:
	cmp	ax, 0
	je	done
	call	space
	call	space
	call	space
	dec	ax
	jmp	L1	
done:
	pop	bx
	pop	ax
	ret
fill endp

compare proc      ;CX rets 0 if same and 1 if not (alumbo == buffer) 
	push	ax
	push	bx
	push	dx
	push	bp
	push	si
	mov	bx, offset buffer
	mov	bp, offset alumbo ; bp must use DS:[bp + si]
	mov	cl, 0
	mov	ax, 0
	mov	dx, 0
	mov	si, 0
L1:
	cmp	si, 10h
	je	done
	mov	al, [bx + si]
	mov	dl, DS:[bp + si]
	inc	si
	cmp	ax, dx
	je	L1
	jne	diff

diff:	
	mov	cl, 1
		
done:
	pop	si
	pop	bp
	pop	dx
	pop	bx
	pop	ax
	ret
compare endp

copyB proc	;COPY BUFFER TO ALUMBO (alumbo = buffer)
	push	ax
	push	bx
	push	bp
	push	si
	mov	si, 0
	mov	bx, offset buffer
	mov	bp, offset alumbo ; bp must use DS:[bp + si]
	mov	ax, 0
L1:
	cmp	si, 10h
	je	done
	mov	al, [bx + si]
	mov	DS:[bp + si], al
	inc	si
	jmp	L1
	
done:
	pop	si
	pop	bp
	pop	bx
	pop	ax
	ret	
copyB endp

body proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	mov	ax, 10h
	mov	dx, 0
	jmp	L1

star:   ; si is 1 if start already was happening
	cmp	si, 0
	je	s2
	jmp	L1
s2:
	call	starPrint
	call	NL
	mov	si, 1
	jmp	L1		
L1:
	call	loadbuffer
	cmp	ax, 0
	je	done	
	
	call	inccount	
	; DX CONSIDERS FIRST RUN 0 is first 1 is not
	cmp	dx, 0
	je      first

	call	compare ; cx 0 if same and 1 if not (in terms of prev buffer)
	cmp	cx, 0
	je	star
first:
	call	counterout
	call	copyB
	mov	si, 0
	call	space
	call	space	

	mov	bx, offset buffer
	mov	cx, ax ; for hexout and printbuffer
	call	Hexout
	
	cmp	ax, 10h
	jl	shortline
		

	call	space
	call	bar
	
	call	PrintBuffer
	
	call	bar
	
	call	NL
	mov	dx, 1
	mov	ax, 0
	jmp	L1

shortline:
	call	fill
	call	space
	call	bar
 	mov	dx, offset buffer
	call	PrintBuffer
	call	bar
	call	NL


done:
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
body endp



; Hexdump is well functioning hexdump
; Cons:
; - Weak error support
; - Couldn't figure out diff in unix so the exact output
;    matching might not work
; - Doesn't open empty file (there was a bug with my empty file reading)

; Pros:
; Works like normal hexdump:
; 1) Extract file name and place into memory cleanly (without leading or
;    trailing spaces
; 2) reads file in groups of 16 while keeping the offset of the file on the 
;    left in hex displays a byte by byte hex representaion of the file along
;    with the original text with pipes surrounding
; 3) represents ditto groups of 16 as one * ( correction it stoped working 
; 4) displays the total amount of bytes at the bottom left
Hexdump Proc
	mov	ax, @data
	mov	ds, ax
	jmp	strt
Fe:
	mov	dx, offset fee
	call	PrintString
	jmp	done

strt:
	call	getFileName 	;file @ in bx
	call	cleanname	

	pushf
	call	openFile
	jc	Fe
	popf
	;ax has file handle

	mov	filehandle, ax

	call	body
	;16 print hex 16 print ascii after "  |~~~~~~|"
	call	counterout
done:
	call	close
	mov	ax, 4C00h
	int	21h
Hexdump endp

close proc
	pusha
	
	mov	bx, ax	
	mov	ah, 3eh
	int	21
	
	popa
close endp

;PRINTHEXDIGIT from P2
PHD proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	si

	mov	bx, OFFSET harry
	mov	cl, 4

	shl	dl, cl
	mov	ax, 0000h
	mov	al, dl
	shr	ax, cl
	mov	si, ax

	mov	dl, [bx + si]
	mov	ah, 02h
	int	21h

	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
PHD endp

; BX is the address of an array of bytes and CX is the len
; write each byte of the array followed by a space
; MODIFIED: Every 8the byte in the list has a double space after
; made a secion for DSpace and moved some loops
HexOut proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	si

	mov	ax, cx
	mov	di, OFFSET harry
	mov	cl, 4 ;byte sft
	mov	si, 0
	jmp	L1
DSpace:
	push	ax
	mov	dl, " "		; space
	mov	ah, 02h
	int	21h
	pop	ax
	jmp 	incre		

L1:
;------------------ one byte-------------
	cmp	si, ax     ;; first digit
	jae	done
	mov	dl, [bx + si]
	push	dx
	shr	dl, cl	   ;; 10h -> 01h
	call	PHD

	pop	dx		;2nd digit
	call	PHD
;---------------------------------
	push	ax
	mov	dl, " "		; space
	mov	ah, 02h
	int	21h
	pop	ax
	
	cmp	si, 7
	je	DSpace
incre:

	inc	si
	jmp	L1

done:
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
HexOut endp

; OG HEXOUT NO SPACES
HO proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	si

	mov	ax, cx
	mov	di, OFFSET harry
	mov	cl, 4 ;byte sft
	mov	si, 0
	jmp	L1

L1:
;------------------ one byte-------------
	cmp	si, ax     ;; first digit
	jae	done
	mov	dl, [bx + si]
	push	dx
	shr	dl, cl	   ;; 10h -> 01h
	call	PHD

	pop	dx		;2nd digit
	call	PHD
;---------------------------------	
	inc	si
	jmp	L1

done:
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret
HO endp

NL proc
	pushf
	push	dx
	push	ax

	mov	dl, 0dh		; CR
	mov	ah, 02h
	int	21h
	
	mov	dl, 0ah		; NL
	mov	ah, 02h
	int	21h
	
	pop	ax
	pop	dx
	popf
	ret
NL endp


;MODIFIED ONLY 7e >  ASCIIZ > 32
PrintBuffer Proc ; takes offset in DX and buffer len in CX and prints string
	pushf
	push	ax
	push	bx
	push	dx
	push	cx
	
	mov	bx, offset buffer
	jmp	print
dot:
	mov	dl, "."
	mov	ah, 02h
	int	21h
	inc	bx
	dec	cx
	jmp	print
print:
	mov	dl, [bx]
	cmp	cx, 0
	je	brk

	cmp	dl, 126
	jg	dot

	cmp	dl, 32
	jl	dot
	mov	ah, 02h
	int	21h
	inc	bx
	dec	cx
	jmp	print
brk:
	pop	cx
	pop	dx
	pop	bx
	pop	ax
	popf
	ret
PrintBuffer endP

bar proc
	push	dx		
	push	ax
	mov	dl, "|"		; bar
	mov	ah, 02h
	int	21h
	pop	ax
	pop	dx
	ret
bar endp


starPrint proc
	push	dx		
	push	ax
	mov	dl, "*"		; space
	mov	ah, 02h
	int	21h
	pop	ax
	pop	dx
	ret
starPrint endp


space proc
	push	dx		
	push	ax
	mov	dl, " "		; space
	mov	ah, 02h
	int	21h
	pop	ax
	pop	dx
	ret
space endp

end Hexdump
