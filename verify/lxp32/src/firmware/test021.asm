/*
 * This test verifies level-sensitive interrupt handling
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0x40000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x40000004 // timer: delay between pulses (in cycles)
	lc r105, 0x40000008 // timer: clear interrupt
	
	lc iv3, timer_handler
	lc cr, 0x08080008 // enable intertups 3, mark as level-sensitive and inverted
	
	lc r32, 1000 // cycle counter
	lc r33, cnt_loop
	mov r34, 0 // interrupt call counter
	
	sw r104, 100
	sw r103, 5
	
cnt_loop:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop
	
	cjmpne r102, r34, 5 // failure
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
	
timer_handler:
	add r34, r34, 1
	sw r105, 1
	lc r0, 0x10000004
	sw r0, r34
	iret
