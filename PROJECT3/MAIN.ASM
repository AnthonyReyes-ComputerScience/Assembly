
Title BOFA
; Anthony Reyes	
; test for me
; MAIN

include cs240.inc

ArraySum	Proto
Fact		Proto
HexOut		Proto
PrintInt	Proto

.8086

.data

arry	WORD	-4, 5, -1, -1
oof	byte	?
harry	byte	0C0h, 0FFh, 0EEh, 12h, 34h, 56h, 78h, 90h, 0BAh, 0BEh
len	byte	?
.code

main proc
	mov	ax, @data
	mov	ds, ax
	
;	call	dumpregs
;	
;	mov	dl, 2
;	mov	bx, OFFSET arry
;	mov	cx, OFFSET oof - OFFSET arry
;	call	ArraySum
	
	call	dumpregs	

;	mov	ax, 9
;	call	fact
;	mov	dx, ax
;	call 	writeuint
;	call	newline
;	call	dumpregs	

	mov	bx, OFFSET harry
	mov	cx, offset len - offset harry
	
;	mov	dx, cx
;	call	writeint
;	call	newline
;	
	call	HexOut	

;	mov	ax, 0E168h
;	call	printint

;	mov	dl, 04h
;	call	phd

	mov	ax, 4C00h
	int	21h
main endp

end main
