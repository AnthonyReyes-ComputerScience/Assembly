Title DosTunes
include cs240.inc

.386

.data
;bytecount	DWORD	0h
raw		BYTE	100 dup(0)
filename	BYTE	100 dup(0)
buffer		BYTE	50 dup(0ffh)
;alumbo		BYTE	17 dup(0)
filehandle	WORD	?
;harry		BYTE	"0123456789abcdef"
fee		BYTE	"YO, YOUR FILE DON'T OPEN", 0

.code

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
	cmp	dl, 0ffh
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

	push	bx
	push	cx
	push	dx

go:
	mov	bx, filehandle
	mov	cx, 1h
	mov	dx, offset buffer
	mov	eax, 0

	mov	ah, 3Fh; read
	int	21h

brk:

	pop	dx
	pop	cx
	pop	bx
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


main PROC
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
	mov 	ax, 40
	call 	FileIn
	mov 	dx, offset BUFFER
	call 	PrintString

done:
	call	closeFile
	mov	ax, 4C00h
	int	21h
main ENDP

end main
