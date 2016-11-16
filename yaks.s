dispatcher:	

	;Save context of registers (exept for sp)
	cli
	pushf
	push cs


	mov [returnToLocation], bp
	mov bp, sp
	push word[bp + 4] ;Save return address	

	mov bp, [returnToLocation]

	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	push ds
	push bp

	;Save sp in TCB
	mov bx, word[runningTCB]
	mov word[bx + 2], sp 
 


	;set bx to TCB to restore
	mov bx, word[nextTCB]

	;Get new stack 
	mov sp, word[bx + 2]

	;Restore registers
	pop bp
	pop ds
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	push bx
	mov bx, word[nextTCB]
	mov word[runningTCB], bx
	pop bx

	;The next thing on the stack is now the return address

	iret

dispatchHelperFirst:
	;Don't save anything, just dispatch nextTCB
	;Saving context would save the context from main and that's bad
	mov bx, word[nextTCB]
	
	;Get the task's stack
	mov sp, word[bx + 2]
	mov bp, sp
	
	;Push the return address, we'll use flags and cs from main for now
	pushf
	push cs
	push word[bx]
	
	iret
	

initializeStack:
	push bp
	push bx
	mov bp, sp

	mov bx, word[runningTCB]
	mov sp, word[bx + 2]

	;pushf
	push word[0x200]

	push cs

	;Push starting address
	push word[bx]

	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	push ds
	push bp
	
	mov bx, word[runningTCB]
	mov word[bx + 2], sp
	
	mov sp, bp
	pop bx	
	pop bp
	ret


YKEnterMutex:
	cli
	ret
YKReturn:
	pop cx
	ret
	

YKExitMutexIDLE:
	sti
	ret

YKExitMutex:
	push cx	
	mov cx, [isRunning]
	cmp cx, 0
	jp YKReturn
	pop cx
	sti
	ret
