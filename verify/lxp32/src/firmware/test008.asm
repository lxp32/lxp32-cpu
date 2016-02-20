/*
 * This test calculates a CRC-32 checksum of a small byte array
 * CRC32("123456789")=0xCBF43926
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	
	lc r16, 0x10000004 // output pointer
	lc r17, 0xFFFFFFFF // initial CRC value
	lc r18, 0xEDB88320 // polynom
	lc r19, data // input pointer
	
	lc r32, byte_loop
	lc r33, bit_loop
	lc r34, dont_xor
	
	mov r20, 0 // byte counter
	
byte_loop:
	lub r0, r19
	mov r21, 0 // bit counter
	
bit_loop:
	and r1, r0, 1
	and r2, r17, 1
	sru r17, r17, 1
	xor r3, r1, r2
	cjmpe r34, r3, 0
	xor r17, r17, r18
	
dont_xor:
	sru r0, r0, 1
	add r21, r21, 1
	cjmpul r33, r21, 8
	
	add r19, r19, 1
	add r20, r20, 1
	cjmpul r32, r20, 9
	
	not r17, r17
	sw r16, r17
	
	lc r0, 0xCBF43926
	cjmpne r102, r0, r17
	
	sw r100, 1
	jmp r101
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101
	
data:
	.byte "123456789"
