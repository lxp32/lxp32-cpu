/*
 * This test verifies call and ret instructions
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc sp, 0x00010000 // stack pointer
	
	lc r0, 0x00008000
	sw r0, 0
	
// Test simple procedure call
	
	lc r1, testproc
	
	call r1 // testproc
	
	lw r0, r0
	lc r1, 0x11223344
	
	cjmpne r102, r0, r1 // failure
	
// Test jump directly to CALL instruction
	lc r1, jump_to_call
	lc r2, testproc2
	
	jmp r1
	nop
	nop
	nop
	
jump_to_call:
	call r2
	
	lw r0, r0
	lc r1, 0x55667788
	
	cjmpne r102, r0, r1 // failure

// Test recursive calls: calculate 10th Fibonnaci number
// using recursive algorithm
	mov r0, 10 // argument
	mov r16, 0 // how many times test_recursive has been called
	lc r1, test_recursive
	call r1 // test_recursive
	
	lc r1, 0x00008000
	sw r1, r0
	
	add r1, r1, 4
	sw r1, r16
	
	lc r1, 55
	cjmpne r102, r0, r1
	
	lc r1, 177
	cjmpne r102, r16, r1
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
	
testproc:
	lc r0, 0x00008000
	lc r1, 0x11223344
	sw r0, r1
	ret
	
testproc2:
	lc r0, 0x00008000
	lc r1, 0x55667788
	sw r0, r1
	ret

test_recursive:
	add r16, r16, 1 // increment call counter

// If r0 is 0 or 1, just return
	cjmpe rp, r0, 0
	cjmpe rp, r0, 1
	
// Save return address in stack
	sub sp, sp, 4
	sw sp, rp
// Save argument in stack
	sub sp, sp, 4
	sw sp, r0
// Call itself for with (r0-1) and (r0-2) arguments
	sub r0, r0, 1
	lc r1, test_recursive
	call r1
// Restore value from stack, save temporary result
	lw r1, sp
	sw sp, r0
	
	sub r0, r1, 2
	lc r1, test_recursive
	call r1
	
// Restore result from stack
	lw r1, sp
	add sp, sp, 4
	
	add r0, r0, r1
	
// Restore return address
	lw rp, sp
	add sp, sp, 4
	ret
