/*
 * This test calculates a few Fibonacci sequence members
 * end compares them to pre-calculated values.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	
// Calculate Fibonacci sequence members
	mov r16, 0 // current member
	mov r17, 1 // next member
	lc r18, 0 // counter
	lc r19, 0x00008000 // destination pointer
	lc r32, calc_loop
	
calc_loop:
	sw r19, r16
	add r19, r19, 4
	add r18, r18, 1
	add r0, r16, r17
	mov r16, r17
	mov r17, r0
	cjmpul r32, r18, 40
	
// Compare
	lc r16, 0x00008000
	lc r17, expected
	mov r18, 0 // counter
	lc r32, comp_loop
	lc r33, comp_differ
	
comp_loop:
	lw r0, r16
	lw r1, r17
	cjmpne r33, r0, r1
	add r16, r16, 4
	add r17, r17, 4
	add r18, r18, 1
	cjmpul r32, r18, 40
	
// Everything seems to be OK
	sw r100, 1
	
halt:
	hlt
	jmp r101
	
comp_differ:
	sw r100, 2
	jmp r101

// Expected (pre-calculated) values
expected:
	.word 0
	.word 1
	.word 1
	.word 2
	.word 3
	.word 5
	.word 8
	.word 13
	.word 21
	.word 34
	.word 55
	.word 89
	.word 144
	.word 233
	.word 377
	.word 610
	.word 987
	.word 1597
	.word 2584
	.word 4181
	.word 6765
	.word 10946
	.word 17711
	.word 28657
	.word 46368
	.word 75025
	.word 121393
	.word 196418
	.word 317811
	.word 514229
	.word 832040
	.word 1346269
	.word 2178309
	.word 3524578
	.word 5702887
	.word 9227465
	.word 14930352
	.word 24157817
	.word 39088169
	.word 63245986
