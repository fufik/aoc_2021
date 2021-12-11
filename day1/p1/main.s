# Day 1
# GAS on x86_64 Linux
# As per ELF all registers are zero
# in a statically linked programme
.text
	.global _start
_start:
	movabs 	$0x7475706e69, %r8
	push	%r8
	mov 	%rsp, %rdi
	xor	%rsi, %rsi
	add	$0x2, %rax
	syscall
	jmp 	_readline

	# graceful exit
_exit:
	#convert to ascii
	xor	%rbx, %rbx
   	mov	%r12, %rax
   	mov	$0xa, %r14

	mov	$0xa, %bh	# push \n

   1:	xor	%rdx, %rdx
   	div	%r14		# divide by 10
	movb	%dl,  %bl	# push first byte to rbx
	addb	$0x30,%bl	# ascii = 0x30+$
	shl	$0x8, %rbx	
	test	%rax, %rax
	jnz	1b		#loop until rax is empty
	
	pushq 	%rbx
   2:	cmpb	$0x0,(%rsp)	# test if first byte is 0x0
	jnz	3f
	add	$0x1, %rsp
	jmp 	2b

   3:	mov	$0x01, %rax
	mov	$0x01, %rdi
	mov	%rsp,  %rsi
	mov	$0x08, %rdx
	syscall

	mov	$0x3c, %rax	# 60 = 0x3c sys_exit()
	xor	%rdi, %rdi
	syscall

_readline:
	xor	%rax, %rax
	mov 	$0x3, %rdi	# the next fd will be 3 after the standard 0,1,2
	push	%r9   		#push 8 0x0 as a buffer
	mov	%rsp, %rsi
	mov	$0x4, %rdx
	syscall
	test	%rax, %rax	#if return is zero => EOF
	jnz	1f
	jmp	_exit

   1:	pop	%r13		# get the read from the stack
	bswap	%r13d		# is number 3-digit
	cmp	$0xa, %r13b	# cool hack
	jne	.L4d		# if 4 digits long, skip following ops for 3d
	
	shr	$0x8,%r13d	# removes \n	
	jmp	.Loper
.L4d:	
	mov	$0x8, %rax	#4digit, so we need lseek
	mov	$0x3, %rdi	#using read is little fun
	mov	$0x1, %rsi
	mov 	$0x1, %rdx	#[whence: SEEK_CUR]
	syscall	
.Loper:
	test	%ebx, %ebx	# if zero
	jnz	2f		# skip initialization if not zero		
	mov	%r13d, %ebx
   1:	jmp	_readline
   2:	cmp	%ebx, %r13d
	mov	%r13d, %ebx	#new is greater, save it
	jng	1b		#if the same, escape further ops
	inc	%r12
	jmp 	1b

