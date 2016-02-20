/*
 * This test verifies that basic instructions
 * (data transfers, addition/subtraction, jumps) work.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, bad_jump
	
// All registers should be zero-initialized after reset
	lc r0, jump0
	add r1, r1, 1
	cjmpe r0, r1, 1
	
	sw r100, 2 // failure: r1 not initialized
	jmp r101
	
// Test different jump conditions
jump0:
	lc r0, jump1
	jmp r0
	sw r100, 3 // failure: this instruction should not be reachable
	jmp r101
	
jump1:
	lc r0, jump2
	mov r1, 100
	cjmpne r0, r1, 101
	sw r100, 4 // failure: required jump is not taken
	jmp r101
	
jump2:
	lc r0, jump3
	cjmpe r0, r1, 100
	sw r100, 5 // failure: required jump is not taken
	jmp r101
	
jump3:
	lc r0, jump4
	cjmpuge r0, r1, 99
	sw r100, 6 // failure: required jump is not taken
	jmp r101
	
jump4:
	lc r0, jump5
	cjmpuge r0, r1, 100
	sw r100, 7 // failure: required jump is not taken
	jmp r101
	
jump5:
	lc r0, jump6
	cjmpug r0, r1, 99
	sw r100, 8 // failure: required jump is not taken
	jmp r101
	
jump6:
	lc r0, jump7
	cjmpsge r0, r1, -128
	sw r100, 9 // failure: required jump is not taken
	jmp r101
	
jump7:
	lc r0, jump8
	cjmpsge r0, r1, 100
	sw r100, 10 // failure: required jump is not taken
	jmp r101
	
jump8:
	lc r0, jump9
	cjmpsg r0, r1, 99
	sw r100, 11 // failure: required jump is not taken
	jmp r101
	
jump9:
	lc r0, 2227053353
	lc r1, 2933288161
	cjmpug r102, r0, r1

	lc r0, 3957963761
	lc r1, 4048130130
	cjmpug r102, r0, r1

	lc r0, 1021028019
	lc r1, 2570980487
	cjmpug r102, r0, r1

	lc r0, 470638116
	lc r1, 3729241862
	cjmpug r102, r0, r1

	lc r0, 2794175299
	lc r1, 3360494259
	cjmpug r102, r0, r1

	lc r0, 522532873
	lc r1, 2103051039
	cjmpug r102, r0, r1

	lc r0, 994440598
	lc r1, 4241216605
	cjmpug r102, r0, r1

	lc r0, 176753939
	lc r1, 850320156
	cjmpug r102, r0, r1

	lc r0, 3998259744
	lc r1, 4248205376
	cjmpug r102, r0, r1

	lc r0, 3695803806
	lc r1, 4130490642
	cjmpug r102, r0, r1

	lc r0, -798605244
	lc r1, -233549907
	cjmpsg r102, r0, r1

	lc r0, -1221540757
	lc r1, 580991794
	cjmpsg r102, r0, r1

	lc r0, -1651432714
	lc r1, -635466783
	cjmpsg r102, r0, r1

	lc r0, 43633328
	lc r1, 1235055289
	cjmpsg r102, r0, r1

	lc r0, -2132159079
	lc r1, -981565396
	cjmpsg r102, r0, r1

	lc r0, -859182414
	lc r1, -697843885
	cjmpsg r102, r0, r1

	lc r0, 1720638509
	lc r1, 2127959231
	cjmpsg r102, r0, r1

	lc r0, -1888878751
	lc r1, 1230499715
	cjmpsg r102, r0, r1

	lc r0, 517066081
	lc r1, 1914084509
	cjmpsg r102, r0, r1

	lc r0, -266475918
	lc r1, 2001358724
	cjmpsg r102, r0, r1

	mov r1, 100
	cjmpe r102, r1, 101
	cjmpne r102, r1, 100
	cjmpuge r102, r1, 101
	cjmpug r102, r1, 100
	cjmpug r102, r1, 101
	cjmpsge r102, r1, 101
	cjmpsg r102, r1, 101
	cjmpsg r102, r1, 100
	cjmpsg r102, -128, r1
	lc r0, jump10
	jmp r0
	
bad_jump:
	sw r100, 12 // failure: jump should not be taken
	jmp r101
	
jump10:

// Copy itself to another portion of memory
	mov r0, 0 // source pointer
	lc r1, 0x00008000 // destination pointer
	lc r2, end // size of block to copy, in bytes
	lc r32, copy_loop
	
copy_loop:
	lw r3, r0
	sw r1, r3
	add r0, r0, 4
	add r1, r1, 4
	cjmpul r32, r0, r2

// Calculate sum of program body in a post-condition loop
	mov r0, 0 // pointer
	mov r16, 0 // sum
	lc r32, sum_loop
	
sum_loop:
	lw r1, r0
	add r16, r16, r1
	add r0, r0, 4
	cjmpul r32, r0, r2

// Calculate sum of copied program body with negative sign, in a pre-condition loop
	lc r0, 0x00008000 // pointer
	add r2, r0, r2 // end pointer
	mov r17, 0 // sum
	lc r32, sum2_loop
	lc r33, sum2_end
	
sum2_loop:
	cjmpuge r33, r0, r2
	lw r1, r0
	sub r17, r17, r1
	add r0, r0, 4
	jmp r32
	sw r100, 13 // failure: this instruction should not be reachable
	jmp r101

sum2_end:

// Check that sums are equal (but with opposite signs)
	add r0, r16, r17 // r0 should be zero now
	lc r32, success
	cjmpe r32, r0, 0
	sw r100, 14 // failure: results do not match
	jmp r101
	
success:
	sw r100, 1
	
halt:
	hlt
	jmp r101

end:
