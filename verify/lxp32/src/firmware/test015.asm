/*
 * Test unconventional interrupt handlers
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, 0x30000000 // coprocessor input register
	lc r103, 0x30000004 // coprocessor output register
	lc r104, failure

// Initialize interrupt handlers
	lc iv2, coprocessor_handler
	mov cr, 4 // enable interrupts from the coprocessor
	lc r110, interrupt_exit@1 // '1' in the LSB is an interrupt exit flag
	
// Initialize random generator
	mov r64, 1 // initial PRBS value
	lc r65, 1103515245 // PRBS multiplier
	lc r66, 12345 // PRBS addition constant
	lc r67, 32767 // PRBS mask
	
// Main loop
	lc r32, loop
	lc r33, rand
	lc r34, 2000
	
loop:
	call r33
	cjmpe r32, r0, 0 // if(r==0) continue;
	sw r102, r0
	hlt
	
interrupt_exit:
	lw r1, r103
	mul r0, r0, 3
	cjmpne r104, r0, r1 // failure
	
	sub r34, r34, 1
	cjmpug r32, r34, 0 // loop
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt

rand:
	mul r64, r64, r65
	add r64, r64, r66
	sru r0, r64, 16
	and r0, r0, r67
	ret
	
coprocessor_handler:
	jmp r110 // exit to a given point, ignore irp
