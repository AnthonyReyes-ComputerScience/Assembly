TITLE Project5
; Anthony Reyes
; 10 - 7 - 18

include cs240.inc

.8086

.data
Abort		BYTE	"Process Aborted", 0
BSize		word	?
.code

func proc
	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	

	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax	
	popf
	pop	bp
	ret
func endp

;---------------------------------SAFE READ-----------------------------------
;AH = 07h receive keystroke
;21h
;al gets key

;User enters string and it displays to be stored into a buffer
;1. take-key 2. examine key ([1-0, a-z, A-Z, Printable], del, ctl-c, otherkey)
;3. print if printable (del moves cursor back so print del and space)
;   Enter exits safley and ^C exits with an error message
;4. always verify buffer size (error if exceed)

GetKey Proc
	pushf
	mov	al, 0
	mov	ah, 07h
	int	21h
	popf		
	ret
GetKey ENDP

;Stack has ax at bp + 4
;Scan to see what to do and pass it to cx
;cx will hold 1 for a normal character
;key: 1 ascii(32-7eh), 0 for OoB, 2 del, 3 enter.
ScanKey PROC
	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	mov	cx, 0
	jmp	get	

get:
	mov	ax, [bp + 4]
	cmp	ax, 0
	je	done
	cmp	ax, 3
	je	CtrC		; ^C
	cmp	ax, 8
	je	del		; al = Del
	cmp	ax, 0dh
	je	Ent		; al = 0d
	cmp	ax, 32
	jl	OoB		; al < 32
	cmp	ax, 126
	ja	OoB		; al > 7eh
	jmp	norm
OoB: 
; Out of bounds
	mov	cx, 1
	jmp	done
del:
	mov	cx, 3
	jmp	done	
Ent:
	mov	cx, 4
	jmp	done
CtrC:
	push	dx
	call	NewLine
	mov	dx, offset abort
	call	WriteString      ;IMPORT WRITE STRINGGGGGGGGGGGGGG!!!!!!!!!
	pop	dx
	mov	ax, 4C00h
	int	21h ;  Back to dos
	jmp	done
norm:
	mov	cx, 2	

done:
	pop	bx
	pop	ax	
	popf
	pop	bp
	ret
ScanKey endp

SafeRead PROC
;BX = ADDRESS
;DX = SIZE
	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	push	cx
	push	dx

	mov	dx, [bp + 4]
	mov	bx, [bp + 6]
	mov	BSize, dx
	cmp	dx, 1
	jbe	done
	mov	dx, 0
L1:	
	call	body
	cmp	cx, 4
	je	done
	jmp	L1	
	;exit under cond
done:
	pop	dx	
	pop	cx
	pop	bx
	pop	ax
	popf
	pop	bp
	ret
SafeRead ENDP

MemManage PROC
	pushf
	cmp	cx, 1
	je	OoB
	cmp	cx, 2
	je	good
	cmp	cx, 3
	je	del
	cmp	cx, 4
	je	Ent
	
OoB:
	jmp	done

del:
	cmp	dx, 0
	je	done
	;dec size
	dec	dx	

	;manage buffer
	Call	MemRemove
	
	;print del (move back cursor)
	call	PrintChar
	
	;print	" "
	push	ax
	mov	ax, " "
	call	PrintChar
	pop	ax

	;print del again
	call	PrintChar
	
	jmp	done
	
Ent:
	jmp	done
good:
	push	cx
	mov	cx, BSize
	dec	cx
	cmp	dx, cx		;CMP SIZE of BUFFER - 1
	pop	cx
	je	done		;Jump is full and ignore char
	
	Call	PrintChar
	Call	MemMove
	inc	dx
	
done:
	popf
	ret
MemManage ENDP

PrintChar Proc ; AL TAKES CHAR
	pushf
	push	ax
	push	dx
	mov	dx, 0
	mov	dx, ax
	mov	ah, 02h
	int	21h
	pop	dx
	pop	ax
	popf
	ret
PrintChar Endp

MemMove Proc
	push	di
	mov	di, dx
	mov	[bx + di], al
	pop	di
	ret
MemMove Endp

MemRemove Proc
	push	di
	push	dx
	mov	dl, 0
	mov	di, dx
	mov	[bx + di], dl
	pop	dx
	pop	di
	ret
MemRemove Endp

body PROC
;BX = ADDRESS
;DX = SIZE - Running buffer size
	pushf
	Call	GetKey

	mov	ah, 0h
	;al has key

	push	ax
	Call	ScanKey
	add	sp, 2
	
	;cx will hold 1 for a normal character
	;key: 1 ascii(32-7eh), 0 for below, 2 del, 3 enter.
	; cx = 3 just return
	push	cx 
	Call	MemManage
	add	sp, 2
	popf
	ret
body ENDP

;--------------------------------- Delay ------------------------------------
; gets a number of mms from the stack and returns when that amount
; of time (in mms) has elapsed
; AH = 2Ch int 21h get system time -> CH = Hour, CL = min, DH = sec, DL = 1/10s
; check time fast and return

GetNow Proc
	push	ax
	mov	ah, 2Ch
	int	21h
	pop	ax
	ret
GetNow Endp

TimeChange Proc
	pushf
	call	GetNow
	mov	bl, dl
L1:
	call	GetNow
	cmp	bl, dl
	ja	L
	jb	G
	jmp	L1
L:
	add	dl, 100
	sub	dl, bl
	mov	bl, dl	
	jmp	done
G:
	sub	dl, bl
	mov	bl, dl
done:	
	mov	bh, 0
	popf
	ret
TimeChange Endp

Delay PROC
	push	bp
	mov	bp, sp
	pushf
	push	ax
	push	bx
	push	cx
	push	dx
	mov	dx, 0
	mov	bx, 10
	mov	ax, [bp + 4] ; get mms
	div	bx
			;AX has Cent-secs
	mov	bx, 0
	call	GetNow
stall:
	Call	TimeChange
	sub	ax, bx
	jc	done
	jmp	stall
done:
	pop	dx
	pop	cx
	pop	bx
	pop	ax	
	popf
	pop	bp
	ret
Delay ENDP
END
