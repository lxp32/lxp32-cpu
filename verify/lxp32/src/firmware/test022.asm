/*
 * This test verifies the xcall instruction, which, unlike call,
 * stores the address of the next instruction to an arbitrary
 * register, not necessary rp.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0

	lcs r0, func_r200
	xcall r200, r0

	lcs r0, func_r201
	xcall r201, r0

	cjmpne r102, r103, 3 // failure

	sw r100, 1
	jmp r101 // halt

failure:
	sw r100, 2

halt:
	hlt
	jmp r101 // halt

func_r200:
	add r103, r103, 1
	jmp r200

func_r201:
	add r103, r103, 2
	jmp r201
