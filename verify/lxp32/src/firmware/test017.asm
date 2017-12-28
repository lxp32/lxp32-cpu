/*
 * Test the new "lc16" instruction
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure

	lc r0, 25000
	lc r1, -20000
	.word 0x0C0A61A8 // lc16 r10, 25000
	.word 0x0C0BB1E0 // lc16 r11, -20000
	
	cjmpne r102, r0, r10 // failure
	cjmpne r102, r1, r11 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
