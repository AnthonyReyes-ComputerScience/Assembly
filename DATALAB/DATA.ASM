
Title Data.acc

; Anthony Reyes
; cs240
; 9-2-18
; 28-bytes of data from dumpmem

include cs240.inc

.8086

DE = 4C00h
Dos = 21h

.data

memblock	Label	 Byte

; Unsigned byte max is FFh min is 0h
USI8ByteVar	Byte	0FFh

; Signed byte max is FFh min is 81h
SI8ByteVar	Sbyte	81h

; Unsigned word max is FFFFh min is 0h
W16UIWordVar	Word	0FFFFh

; Signed word max is FFFFh min is 8001h
SW16SIWordVar	SWORD	8001h

; Unsigned Double word max is FFFFFFFFh min is 0h
DW32UIDWordVar	DWORD	0FFFFFFFFh

; Signed Double word max is 0FFFFFFFFh min is 80000001h
DW32SIDWordVar	SDWORD	80000001h

memend		Label Byte
result	WORD	?

.code
main Proc

	mov	ax, @data
	mov	ds, ax

	mov	dx, OFFSET memblock
	mov	cx, memend - memblock
	call	DumpMem
	call	NewLine
	
	mov	ax, DE
	int	Dos

main endp
END main
