TITLE minimal 

INCLUDE CS240.inc

.8086

.data

.code

main PROC
	mov	ax, @data 
	mov	ds, ax
	
	call	dumpregs
	mov	ax, 4c00h
	int	21h
	ret
main ENDP

END main
