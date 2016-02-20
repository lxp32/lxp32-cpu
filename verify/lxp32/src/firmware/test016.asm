/*
 * Test for temporarily blocked interrupts
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0x20000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x20000004 // timer: delay between pulses (in cycles)
	
	lc iv0, timer_handler
	lc cr, 0x101 // enable interrupt 0 in temporarily blocked state
	
	lc r32, 0 // interrupt handler call counter
	lc r33, 1000 // loop counter
	lc r34, loop1
	lc r35, loop2
	
	sw r104, 100
	sw r103, 1

loop1:
	sub r33, r33, 1
	cjmpug r34, r33, 0 // loop1
	
	lc r33, 1000
	mov cr, 1 // unblock interrupt 0
	
loop2:
	sub r33, r33, 1
	cjmpug r35, r33, 0 // loop2
	
// r32 should be 1 by this point
	cjmpne r102, r32, 1 // failure
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
	
timer_handler:
	add r32, r32, 1
	iret
