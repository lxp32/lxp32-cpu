/*
 * Check that there are no pipeline hazards
 */

	lc r100, 0x10000000 // test result output pointer
	lcs r101, halt
	lcs r102, failure
	lcs r103, success
	
	add r0, 100, 50 // r0:=150
	add r1, r0, 3 // r1:=153, potential RAW hazard
	mul r2, r1, 109 // r2:=16677, potential RAW hazard
	mul r3, r2, r0 // r3:=2501550, potential RAW hazard
	sub r4, r3, 15 // r4:=2501535, potential RAW hazard
	
	mul r5, 50, 117 // r2:=5850
	sub r5, 100, 9 // r2:=91, overwrites previous result, potential WAW hazard
	
	lc r6, 1800
	mul r7, r6, 49 // r7:=88200, potential RAW hazard
	mov r6, 1 // r6:=1, potential WAR hazard
	
	lc r0, 2501535
	cjmpne r102, r4, r0 // failure
	cjmpne r102, r5, 91 // failure
	lcs r0, 88200
	cjmpne r102, r7, r0 // failure
	jmp r103 // success
	
failure:
	sw r100, 2
	jmp r101 // halt
	
success:
	sw r100, 1 // success
	
halt:
	hlt
	jmp r101 // halt
