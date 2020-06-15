
[org 0x0100]
jmp start

buffer:       times 960 dw 0	

PrintDiamond:	push bp
				mov bp, sp
				sub sp, 2			; local variable -> [bp-2]
				push es
				push ax
				push di
				push si
				push cx
				push dx

				xor cx, cx
				mov ax, 0xb800
				mov es, ax
				xor di, di
				mov ax, 80
				mov bx, [bp+12]		; row number
				mul bx
				add ax, [bp+10]		; column number
				shl ax, 1			; convert to byte offset
				mov di, ax

				mov ax, word[bp+8]	; dividend ; width
				mov bx, 2			; divisor
				xor dx, dx  	    ; remainder
        		div bx         		; perform division. ; Stores integer result in AL and remainder in DX

				cmp dx, 0			; check if width = [bp+8] is even or odd
				je even
				mov word[bp-2], 1	;it is odd
				jmp Print

				even: 
				mov word[bp-2], 0	;it is even

Print:			mov dl, al			; result of width / 2 is current;y in al, copying it to dl
				mov dh, dl			; dh will be used for printing upper half, dl for lower half
				mov cx, 2
				sub cx, word [bp-2]	; if width is even, 0 will be subtracted, else 1		
				mov ah, byte [bp+4]	; attribute
				mov al, byte [bp+6]	; charachter to fill the diamond
				push cx

upperHalf:		mov [es:di], ax
				add di, 2
				loop upperHalf		; run cx times

				; calculating value of di for the printing of next row and updating cx as well
				; di = 160 - old value of cx - new value of cx
				pop cx
				sub di, cx
				add cx, 2
				push cx
				sub di, cx
				add di, 160
				dec dh
				jne upperHalf

				cmp word[bp-2], 1
				jne initLowerHalf

middleLine:		mov [es:di], ax
				add di, 2
				loop middleLine


initLowerHalf:	pop cx

				cmp word[bp-2], 1
				jne updateCX
				sub di, cx

updateCX:		sub cx, 2
				push cx

				cmp word[bp-2], 1
				jne updatDI
				sub di, cx
				add di, 160
				jmp lowerHalf

updatDI:		add di, 2

lowerHalf:		mov [es:di], ax
				add di, 2
				loop lowerHalf			; run cx times
				
				; calculating value of di for the printing of next row and updating cx as well
				; di = 160 - old value of cx - new value of cx
				pop cx
				sub di, cx
				sub cx, 2
				push cx
				sub di, cx
				add di, 160
				dec dl
				jne lowerHalf
				
				pop cx

				pop dx
				pop cx
				pop di
				pop di
				pop ax
				pop es
				mov sp, bp
				pop bp
				ret 10
				
delay:			push cx
				mov cx, 0xffff
				d0:	loop d0
				mov cx, 0xffff
				d1:	loop d1
				mov cx, 0xffff
				d2:	loop d2
				mov cx, 0xffff
				d3:	loop d3
				mov cx, 0xffff
				d4:	loop d4
				mov cx, 0xffff
				d5:	loop d5
				mov cx, 0xffff
				d6:	loop d6
				mov cx, 0xffff
				d7:	loop d7
				mov cx, 0xffff
				d8:	loop d8
				mov cx, 0xffff
				d9:	loop d9
				pop cx
				ret

swap:			push es
				push ds
				push ax
				push di
				push si
				push cx
				push cs


				;copy 13th-24th rows into buffer
				mov di, buffer
				mov si, 1920
				mov cx, 960
				mov ax, 0xb800
				mov ds, ax
				push cs
				pop es
				cld 
				rep movsw
				

				;move upper 12 rows to lower 12 rows
				mov di, 1920
				mov si, 0
				mov ax, 0xb800
				mov ds, ax
				mov es, ax
				mov cx, 960
				cld
				rep movsw


				;paste buffer in first 12 rows
				xor di, di
				mov si, buffer
				mov cx, 960
				mov ax, 0xb800
				mov es, ax
				push cs
				pop ds
				cld 
				rep movsw

				pop cs
				pop cx
				pop di
				pop di
				pop ax
				pop ds
				pop es
				ret

start:	push 13							; row number
		push 37							; column number
		push 11							; width
		push '>'						; charachter to fill the diamond
		push 0x1a						; attribute ; blue background with green foreground (intensity bit on)
		call PrintDiamond

		push 18							; row number
		push 7							; column number
		push 6							; width
		push '^'						; charachter to fill the diamond
		push 0x0b						; attribute ; green+blue foreground (intensity bit on)
		call PrintDiamond

		push 15							; row number
		push 67							; column number
		push 16							; width
		push '?'						; charachter to fill the diamond
		push 0x8c						; attribute ; blinking bit on with red foreground (intensity bit on)
		call PrintDiamond

		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay
		call delay

		call swap

		mov ax, 0x4c00					; terminate program
		int 0x21