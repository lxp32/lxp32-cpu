/*
 * Test "hlt" instruction
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r103, 0x20000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x20000004 // timer: delay between pulses (in cycles)
	
	lc iv0, timer_handler
	mov r10, 2
	mov cr, 1 // enable interrupt 0
	lc r0, 1000
	sw r104, r0
	sw r103, 1
	
	hlt
	
	sw r100, r10 // r10 will be 2 if interrupt hasn't been called, which is a failure code
	
halt:
	hlt
	jmp r101 // halt
	
timer_handler:
	mov r10, 1
	iret
