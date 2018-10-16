/*
 * Test the new "lc21" instruction
 */

	lc r100, 0x10000000 // test result output pointer
	lc21 r101, halt
	lc21 r102, failure

	lc r0, 1000000
	lc r1, -1000011
	lc21 r10, 1000000
	lc21 r11, -1000011
	
	cjmpne r102, r0, r10 // failure
	cjmpne r102, r1, r11 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
