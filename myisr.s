resetISR:
	call resetISRC
	
tickISR:

	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push es
	push ds


	call YKEnterISR

	sti
	call tickISRC
	call YKTickHandler
	cli
	
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)

	call YKExitISR
	
	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	iret

YKRet:	
	pop cx
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	iret

keyboardISR:

	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push es
	push ds


	call YKEnterISR

	sti
	call keyboardISRC
	cli
	
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	

	call YKExitISR

	pop ds
	pop es
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	iret


