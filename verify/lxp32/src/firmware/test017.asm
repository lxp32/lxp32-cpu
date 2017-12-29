/*
 * Test the new "lc18" instruction
 */

	lc r100, 0x10000000 // test result output pointer
	lc18 r101, halt
	lc18 r102, failure

	lc r0, 100000
	lc r1, -111111
	lc18 r10, 100000
	lc18 r11, -111111
	
	cjmpne r102, r0, r10 // failure
	cjmpne r102, r1, r11 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
