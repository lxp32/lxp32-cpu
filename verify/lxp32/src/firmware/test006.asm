/*
 * This test checks for a bug with jump destination register
 * being wrongly overwritten when jump instruction follows "lw"
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure

	lc r16, 0x10000004
	lc r17, 0x12345678
	lc r18, 0x12345678
	
	sw r16, 123
	lw r0, r16
	cjmpne r17, 0, 0 // r17 used to be wrongly overwritten by the value of r16 here
	
	sw r16, r17
	
	nop
	nop
	
	cjmpne r102, r17, r18
	
	sw r100, 1
	jmp r101

failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101
