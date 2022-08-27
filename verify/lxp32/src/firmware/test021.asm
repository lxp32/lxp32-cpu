/*
 * Test the new "cont_i" input port that makes the CPU continue execution when it is halted
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, 0x40000000 // coprocessor2 input register
	lc r103, 0x40000004 // coprocessor2 output register
	lc r104, failure
	
	mov r10, 2
	lc r0, 33
	sw r102, r0
	
	hlt

	lw r1, r103
	cjmpne r104, r1, 99

	sw r100, 1 // success

halt:
	hlt
	jmp r101 // halt

failure:
	sw r100, 2
	jmp r101 // halt
