/*
 * Test wake-up interrupts
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, 0x30000000 // coprocessor input register
	lc r103, 0x30000004 // coprocessor output register
	lc r104, failure

	lcs cr, 0x0404 // enable coprocessor interrupt and mark it as wake-up
	
	sw r102, 33
	
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
