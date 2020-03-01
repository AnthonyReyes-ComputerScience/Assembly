Title Funks
;Anthony Reyes
;Project 2
;cs240

include cs240.inc

.8086

Polynomial Proto
Factorial Proto
Fibonacci Proto
PrintString Proto
PrintHexDigit Proto

.data
eb	WORD	2017h
OOF	BYTE	"You frinkin did it you cool kid, you", 0
harry	byte	"0123456789ABCDEF", 0

.code

main Proc

	mov	ax, @data
	mov	ds, ax

	;test for polynom guuud
	;mov	ax, -2
	;mov	bx, 2
	;mov	cx, 2
	;mov	dx, 2
	;call	Polynomial ; answer in ax
	;mov 	dx, ax
	;call	writeint

	;test for fact
	mov	ax, 5
	call	Factorial
	mov	dx, ax
	call	writeint
	call	dumpregs

	;test for fib  guuud
	;call	readint
	;mov	ax, dx
	;call	Fibonacci
	;mov	dx, ax
	;call	writeint

	;test for printstring

	;mov	dx, OFFSET OOF
	;call	PrintString

	;test for printhexdigit
	;mov	dx, 0236h
	;call	PrintHexDigit

	mov	ax, 4C00h
	int	21h
	ret
main endp
end main
