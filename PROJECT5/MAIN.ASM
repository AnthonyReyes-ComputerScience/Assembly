TITLE Main

include cs240.inc

.386

SafeRead	PROTO
Delay		PROTO


.data

Prompt		BYTE	"Enter Buffer to be saved:", 0dh, 0ah, 0

x		BYTE	"hello, world", 0
y		BYTE	0h
.code

main PROC
	mov	ax, @data
	mov	ds, ax

	; mov	dx, OFFSET Prompt
	; call	WriteString
	;
	; mov	dx, OFFSET x
	; push	dx
	; mov	dx, OFFSET y - OFFSET x
	; push	dx
	; call	SafeRead
	; add	sp, 4
	;
	; call	NewLine
	; mov	dx, offset x
	; call	writestring
	; mov	dx, OFFSET Prompt
	mov	dx, 300
	push	dx
	call	Delay
	add	sp, 2

	mov	ax, 4c00h
	int	21h
main ENDP
END main
