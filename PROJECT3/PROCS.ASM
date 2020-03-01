TITLE procs
; Anthony Reyes
; Project 3
; cs240

include cs240.inc

.8086

.data
harry	BYTE "0123456789ABCDEF", 0
darry	BYTE "0123456789", 0

.code

; BX = Address of array, Dl = size per element (1, 2 bytes), CX = ArrayLen
; Return sum in AX
ArraySum proc
	pushf
	push	bx
	push	cx
	push	dx
	push	di
	mov	dh, 0
	mov	ax, 0
	jmp	cond
	
L0:	
	sub	cx, dx
	mov	di, cx
	add	ax, [bx + di]
	cmp	cx, 0
	je	rt
	jmp	L0
cond:
	cmp	cx, 0
	jg	L0
rt:	
	pop	di
	pop	dx
	pop	cx
	pop	bx
	popf				
	ret
ArraySum endp

; takes ax as unsigned word and computes its factorial recursively
; Return in ax
Fact proc	
	push	bx
	push	dx
	pushf
	cmp	ax, 9  ; hard coded :(
	jge 	overf
	cmp	ax, 0
	jg	L1
	
	mov	ax, 1
	jmp	rt
L1:
	push 	ax
	dec	ax	
	call	Fact
L2:	
	pop	bx
	mul	bx
	jmp 	rt
overf:
	pop	dx
	or	dx, 100000000000b	;Mask
	push	dx
	popf
	pop	dx
	pop	bx
	ret
rt:	
	popf
	pop	dx	
	pop	bx
	ret
Fact endp

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

L1:
	cmp	si, ax     ;; first digit
	jae	done		
	mov	dl, [bx + si]
	push	dx	
	shr	dl, cl	   ;; 10h -> 01h
	call	PHD
	
	pop	dx		;2nd digit
	call	PHD
	
	push	ax
	mov	dl, " "		; space
	mov	ah, 02h
	int	21h
	pop	ax
	
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

; AX is a singed int, write it signed
; ex. if AX is E168h out should be -7832
PrintInt proc
	pushf	
	push	bx
	push	cx
	push	dx
	push	ax
	
	cmp	ax, 0
	je	rt
	cmp	ax, 8000h
	jb	L1
	jae	Negative

Negative:
	push	ax	
	mov	dl, "-"
	mov	ah, 02h
	int	21h
	pop	ax
	neg	ax
	jmp	L1			

L1:
	mov	cx, 10d		; div by 10
	mov	dx, 0		;
	div	cx		;
	push 	dx		; grab remainder
	call	printint	; recurse
	call	PHD		; print dx post return
	pop	dx		; pop for good measure
rt:	
	pop	ax
	pop	dx	
	pop	cx
	pop	bx
	popf
	ret
PrintInt endp

end



