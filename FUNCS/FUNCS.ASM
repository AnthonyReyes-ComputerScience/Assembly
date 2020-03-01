Title Funcs
;Anthony Reyes
;Project 2
;9-4-18
;cs240

include cs240.inc

.8086

.data
harry	byte	"0123456789ABCDEF", 0

.code

square Proc
;  Takes dx, squares it
;  and puts it back in dx
	pushf
	push ax

	mov	ax, dx
	mul	ax
	mov	dx, ax

	pop	ax
	popf
	ret

square endp

Polynomial Proc
; takes a polynom ax^2 + bx + c
; and takes a, b, c, x in
; the ax, bx, cx, and dx
; registers, respectively.

	pushf
	push	bx
	push	cx
	push	dx

	push	ax      ; use ax last for more room
	push	dx
	mov	ax, dx  ; move in x
	mul	bx      ; ax * bx -> DX:AX
	add	cx, ax  ; add b*x by cx to move total into cx
	pop	dx      ; dx (x) is off the stack now
	call	square  ; dx (x) is squared
	pop	ax      ; ax (a) is off the stack
	mul	dx      ; ax is now ax^2 and cx is bx + c
	add	ax, cx  ; all of the answer is in ax

	pop	dx	; maintain state
	pop	cx
	pop	bx
	popf
	ret		; return

Polynomial endp

Factorial Proc
; passed in ax ret in ax... does a factorial
	push	bx
	push	cx
	push 	dx
	pushf
	push	ax
	mov	cx, ax
	cmp	ax, 0	;case of 0
	je	safe
	jmp	myloop

myloop:

	dec	cx    ; simple factorial
	cmp	cx, 0
	je	safe
	mul	cx
	jo	ovflw
	jg	myloop

ovflw:
	pushf
	pop	ax
	mov 	ax, 0000101000000000b  
			;figured this out at SMASH
	push	ax	;moving flags off of stack and altering 
			;and putting back
	popf

	pop	ax
	pop	dx
	pop	cx
	pop	bx
	ret
safe:
	popf
	pop	dx
	pop	cx
	pop	bx
	ret

Factorial endp

Fibonacci Proc
; find nth fib # from ax

	pushf
	push	bx
	push	cx
	push	dx

	mov	cx, 2
	jmp	cond

start:
	mov	ax, 1
	mov	bx, 1
	mov	dx, 2

myloop:

	push	dx	;dx is my counter
	add	ax, bx	;inch up the fib seq
	mov	dx, ax	;move things for ax to be the smaller
	mov	ax, bx	;moved
	mov	bx, dx	;returned bx as F(+1) from its init state
	pop	dx	;counter
	inc	dx	;dx + 1
	cmp	dx, cx	;dx < cx loop else break
	jl	myloop
	jmp	brk

cond:
	cmp	ax, cx
	jle	firsttwo
	mov	cx, ax
	jmp	start

firsttwo:
	call	dumpregs
	mov	ax, 1

brk:
	mov	ax, bx
	pop	dx
	pop	cx
	pop	bx
	popf
	ret

Fibonacci endp

PrintString Proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	mov	bx, dx

print:
	mov	dl, [bx]
	cmp	dl, 0	
	je	brk
	mov	ah, 02h
	int	21h	;CITE: BAILEY
	inc	bx
	jmp	print

brk:
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf

	ret
PrintString endp

PrintHexDigit proc
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	mov	bx, OFFSET harry
	mov	cl, 4

print:
	shl	dl, cl		;shifting the low reg left 01 = 10
	mov	ax, 0000h	;clearing ax
	mov	al, dl		;moving dl into al that is a clean reg
	shr	ax, cl		;moving the value back 0010 = 0001
	mov	si, ax		;moving the value into a usable reg
				;and indexing the harry string
	mov	dl, [bx + si]	;<-----  for this (afraid si was the cause
	mov	ah, 02h		; of my errors
	int	21h		; print

	pop	dx
	pop	cx
	pop	bx
	pop	ax
	popf
	ret

PrintHexDigit endp
end  
