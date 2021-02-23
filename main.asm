;
; 230Final.asm
;
; Created: 14/04/2020 10:03:57
; Author : David Ward
; Note: I do not believe this work violates the University of Victoria's academic integrity policy
;
;*****CODE*SEGMENT*****
.cseg
.org 0x0

;main()
;{

.def temp = r16
.def ret_val = r18

;init hardware stack
ldi temp, high(RAMEND)
out SPH, temp
ldi temp, low(RAMEND)
out SPL, temp

;get start from cseg
ldi ZH, high(start<<1)
ldi ZL, low(start<<1)

ldi XH, high(len)
ldi XL, low(len)

lpm temp, Z ;load start to register

;parameters/return value
push temp
push ret_val
call hail
pop ret_val
pop temp

st X, ret_val

done:
	rjmp done

start: .db 26, 0 ;const int
;}

;hail(int n)
hail:
	.def n = r17
	.equ offset = 7
	push n
	push temp
	push YH
	push YL

;Z gets stack pointer
	in YH, SPH
	in YL, SPL

	ldd n, Y+offset+2 ;get argument

	;if (n == 1)
	cpi n, 1
	breq first
	;else if (n % 2 == 0)
	mov temp, n
	andi temp, 1
	cpi temp, 0
	breq second ;0 if even, 1 if odd
	;else
	rjmp third
	
	first: ;return 0
		ldi n, 0
		std Y+offset+1, n ;store result
		rjmp end

	second: ;return 1 + hail(n/2)
		asr n ; n/2
		std Y+offset+1, n ;store result
		push n
		push ret_val
		call hail
		pop n
		pop ret_val
		inc n
		rjmp end

	third: ;return 1 + hail(3*n + 1)
		ldi temp, 3
		mul n, temp ;multiply
		inc n ;add 1
		std Y+offset+1, n ;store result
		push n
		push ret_val
		call hail
		pop n
		pop ret_val
		inc n
		rjmp end
		

	end:
	pop YL
	pop YH
	pop temp
	pop n
	ret

;*****DATA*SEGMENT*****
.dseg
.org 0x0200
len: .byte 1