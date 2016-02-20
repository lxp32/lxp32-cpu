/*
 * This test verifies interrupt handling using a simple timer model
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0x20000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x20000004 // timer: delay between pulses (in cycles)
	
	lc iv0, timer_handler0
	lc iv1, timer_handler1
	mov cr, 3 // enable interrupts 0 and 1
	
	lc r32, 2000 // cycle counter
	lc r33, cnt_loop
	mov r34, 0 // interrupt 0 call counter
	mov r35, 0 // interrupt 1 call counter
	
	sw r104, 100
	sw r103, 10
	
cnt_loop:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop
	
	cjmpne r102, r34, 10 // failure
	cjmpne r102, r35, 4 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
	
timer_handler0:
	add r34, r34, 1
	lc r0, 0x10000004
	sw r0, r34
	cjmpne irp, r34, 5 // exit interrupt handler if r34!=5
	mov cr, 1 // disable interrupt 1
	iret

timer_handler1:
	add r35, r35, 1
// Interrupt 1 has lower priority than interrupt 0 and will be called later
	cjmpne r102, r34, r35
	lc r0, 0x10000008
	sw r0, r35
	iret
