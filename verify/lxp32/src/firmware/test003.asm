/*
 * This test verifies that basic logical operations
 * (and, xor, or, not) work.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure

	lc r0, 0xD54B65C0
	lc r1, 0xCE8870A8
	lc r16, 0x10000004 // destination pointer
	
	and r2, r0, r1
	sw r16, r2
	lc r3, 0xC4086080
	cjmpne r102, r2, r3
	
	or r2, r0, r1
	sw r16, r2
	lc r3, 0xDFCB75E8
	cjmpne r102, r2, r3
	
	xor r2, r0, r1
	sw r16, r2
	lc r3, 0x1BC31568
	cjmpne r102, r2, r3
	
// Note: "not dst, src" is just an alias for "xor dst, src, -1"
	not r2, r0
	sw r16, r2
	lc r3, 0x2AB49A3F
	cjmpne r102, r2, r3
	
	sw r100, 1
	jmp r101
	
failure:
	sw r100, 2

halt:
	hlt
	jmp r101
