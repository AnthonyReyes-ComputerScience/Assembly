
Title Woop

Include cs240.inc

.8086

.data

.code

woop Proc
	pushf
	push cx
	push ax
	mov	cx, 0
	mov	ax, 0FFh
myloop:
	;inc	cx
	call 	WriteChar
	push	dx
	mov	dx, 15
	pop	dx
	cmp	cx, ax
	jg	off
	jl	myloop

off:
	pop	ax
	pop	cx
	popf
	ret
woop endp

main Proc
	mov	ax, @data
	mov	ds, ax
	
	call 	ReadInt	

	call	woop

	mov	ax, 4c00h
	int	21h
main endp
end main

