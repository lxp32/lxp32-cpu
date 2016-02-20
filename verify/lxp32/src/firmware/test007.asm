/*
 * This test verifies bitwise shift operations.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	
	lc r16, 0x10000004 // output pointer
	
// Test left shifts (by comparison with self-addition)

	lc r0, 0x12345678
	mov r3, r0 // for comparison
	lc r32, sl_loop
	mov r1, 0 // counter
	
sl_loop:
	sl r2, r0, r1
	sw r16, r2
	cjmpne r102, r2, r3
	add r1, r1, 1
	add r3, r3, r3
	cjmpul r32, r1, 32
	
// Test unsigned right shifts (by comparison with pre-calculated values)

	lc r32, sru_loop
	lc r17, sru_expected_data
	mov r1, 0 // counter
	
sru_loop:
	sru r2, r0, r1
	sw r16, r2
	lw r3, r17
	cjmpne r102, r2, r3
	add r1, r1, 1
	add r17, r17, 4
	cjmpul r32, r1, 32
	
// Test signed right shifts (by comparison with pre-calculated values)

	lc r0, 0x87654321
	lc r32, srs_loop
	lc r17, srs_expected_data
	mov r1, 0 // counter
	
srs_loop:
	srs r2, r0, r1
	sw r16, r2
	lw r3, r17
	cjmpne r102, r2, r3
	add r1, r1, 1
	add r17, r17, 4
	cjmpul r32, r1, 32
	
// Report success
	sw r100, 1
	jmp r101
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101

sru_expected_data:
	.word 0x12345678
	.word 0x091A2B3C
	.word 0x048D159E
	.word 0x02468ACF
	.word 0x01234567
	.word 0x0091A2B3
	.word 0x0048D159
	.word 0x002468AC
	.word 0x00123456
	.word 0x00091A2B
	.word 0x00048D15
	.word 0x0002468A
	.word 0x00012345
	.word 0x000091A2
	.word 0x000048D1
	.word 0x00002468
	.word 0x00001234
	.word 0x0000091A
	.word 0x0000048D
	.word 0x00000246
	.word 0x00000123
	.word 0x00000091
	.word 0x00000048
	.word 0x00000024
	.word 0x00000012
	.word 0x00000009
	.word 0x00000004
	.word 0x00000002
	.word 0x00000001
	.word 0x00000000
	.word 0x00000000
	.word 0x00000000

srs_expected_data:
	.word 0x87654321
	.word 0xC3B2A190
	.word 0xE1D950C8
	.word 0xF0ECA864
	.word 0xF8765432
	.word 0xFC3B2A19
	.word 0xFE1D950C
	.word 0xFF0ECA86
	.word 0xFF876543
	.word 0xFFC3B2A1
	.word 0xFFE1D950
	.word 0xFFF0ECA8
	.word 0xFFF87654
	.word 0xFFFC3B2A
	.word 0xFFFE1D95
	.word 0xFFFF0ECA
	.word 0xFFFF8765
	.word 0xFFFFC3B2
	.word 0xFFFFE1D9
	.word 0xFFFFF0EC
	.word 0xFFFFF876
	.word 0xFFFFFC3B
	.word 0xFFFFFE1D
	.word 0xFFFFFF0E
	.word 0xFFFFFF87
	.word 0xFFFFFFC3
	.word 0xFFFFFFE1
	.word 0xFFFFFFF0
	.word 0xFFFFFFF8
	.word 0xFFFFFFFC
	.word 0xFFFFFFFE
	.word 0xFFFFFFFF
