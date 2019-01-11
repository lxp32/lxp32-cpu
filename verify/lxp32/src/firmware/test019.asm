/*
 * This test verifies non-returnable interrupt handling
 * Note: "iret" is never called here
 */

	lc r100, 0x10000000 // test result output pointer
	lcs r101, halt
	lc r102, failure
	lc r103, 0x20000000 // timer: number of pulses (0xFFFFFFFF - infinite)
	lc r104, 0x20000004 // timer: delay between pulses (in cycles)
	lcs r105, success
	
	lcs r32, 0 // counter
	
	lcs iv0, test_loop@1 // set IRF to mark the interrupt as non-returnable
	mov cr, 1 // enable timer interrupt
	sw r104, 100 // delay between interrupts
	sw r103, 100 // generate 100 interrupts
	hlt // wait for a non-returnable interrupt
	
test_loop:
	add r32, r32, 1
	cjmpuge r105, r32, 100 // success
	hlt // wait for a non-returnable interrupt
	
failure:
	sw r100, 2 // should never reach here
	jmp r101 // halt
	
success:
	sw r100, 1 // success
	
halt:
	hlt
	jmp r101 // halt
