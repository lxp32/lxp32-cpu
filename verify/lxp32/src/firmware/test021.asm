/*
 * This test verifies various interrupt trigger modes
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0x40000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x40000004 // timer: delay between pulses (in cycles)
	lc r105, 0x40000008 // timer: trigger mode
	lc r106, 0x4000000C // timer: clear interrupt

// Rising edge trigger
	mov cr, 0
	lc iv3, timer_handler_edge
	sw r105, 0
	lc cr, 0x00000008 // enable interrupt
	
	lc r32, 1000 // cycle counter
	lc r33, cnt_loop1
	mov r34, 0 // interrupt call counter
	
	sw r104, 100
	sw r103, 3
	
cnt_loop1:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop
	
	cjmpne r102, r34, 3 // failure

// Falling edge trigger
	mov cr, 0
	lc iv3, timer_handler_edge
	sw r105, 2
	lc cr, 0x08000008 // enable interrupt

	lc r32, 1000 // cycle counter
	lc r33, cnt_loop2
	mov r34, 0 // interrupt call counter

	sw r104, 100
	sw r103, 4

cnt_loop2:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop

	cjmpne r102, r34, 4 // failure

// High level trigger
	mov cr, 0
	lc iv3, timer_handler_level
	sw r105, 1
	lc cr, 0x00080008 // enable interrupt

	lc r32, 1000 // cycle counter
	lc r33, cnt_loop3
	mov r34, 0 // interrupt call counter

	sw r104, 100
	sw r103, 5

cnt_loop3:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop

	cjmpne r102, r34, 5 // failure

// Low level trigger
	mov cr, 0
	lc iv3, timer_handler_level
	sw r105, 3
	lc cr, 0x08080008 // enable interrupt

	lc r32, 1000 // cycle counter
	lc r33, cnt_loop4
	mov r34, 0 // interrupt call counter

	sw r104, 100
	sw r103, 6

cnt_loop4:
	sub r32, r32, 1
	cjmpug r33, r32, 0 // cnt_loop

	cjmpne r102, r34, 6 // failure

	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt
	
timer_handler_edge:
	add r34, r34, 1
	lc r0, 0x10000004
	sw r0, r34
	iret

timer_handler_level:
	add r34, r34, 1
	sw r106, 1
	lc r0, 0x10000004
	sw r0, r34
	iret
