/*
 * Test the new "lcs" instruction
 */

	lc r100, 0x10000000 // test result output pointer
	lcs r101, halt
	lcs r102, failure

	lc r0, 1000000
	lc r1, -1000011
	lcs r10, 1000000
	lcs r11, -1000011
	
	cjmpne r102, r0, r10 // failure
	cjmpne r102, r1, r11 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
