title

include cs240.inc

.8086

.data
y	WORD	1, 2, 3, 4

x	byte	?
.code

main proc
	mov	ax, @data
	mov	ds, ax

	mov	dx, y
	call	writeuint
	
	mov	dx, x - y
	call	writeuint

	mov	dx, offset x - offset y
	call	writeuint


	mov	ax, 4C00h
	int	21h

main endp
end main
