/*
 * This test verifies bytewise DBUS access
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure

	lc r16, 0x10000004 // output pointer
	lc r17, data // input pointer
	
// Check for bytewise read
	lc r18, 0xbc
	lc r19, 0x9a
	lc r20, 0x78
	lc r21, 0x56
	lc r22, 0xffffffbc
	lc r23, 0xffffff9a
	lc r24, 0x78
	lc r25, 0x56
	
	lub r0, r17
	sw r16, r0
	cjmpne r102, r0, r18
	add r17, r17, 1
	lub r0, r17
	sw r16, r0
	cjmpne r102, r0, r19
	add r17, r17, 1
	lub r0, r17
	sw r16, r0
	cjmpne r102, r0, r20
	add r17, r17, 1
	lub r0, r17
	sw r16, r0
	cjmpne r102, r0, r21
	sub r17, r17, 3
	lsb r0, r17
	sw r16, r0
	cjmpne r102, r0, r22
	add r17, r17, 1
	lsb r0, r17
	sw r16, r0
	cjmpne r102, r0, r23
	add r17, r17, 1
	lsb r0, r17
	sw r16, r0
	cjmpne r102, r0, r24
	add r17, r17, 1
	lsb r0, r17
	sw r16, r0
	cjmpne r102, r0, r25
	
// Check for bytewise write
	lc r17, 0x00008004
	sb r17, 0x12
	add r17, r17, 1
	sb r17, 0x34
	add r17, r17, 1
	sb r17, 0x56
	add r17, r17, 1
	sb r17, 0x78

// Read the whole word and compare	
	sub r17, r17, 3
	lw r0, r17
	lc r18, 0x78563412
	cjmpne r102, r0, r18
	
	sw r100, 1
	jmp r101
	
failure:
	sw r100, 2

halt:
	hlt
	jmp r101
	
data:
	.word 0x56789ABC
