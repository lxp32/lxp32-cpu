/*
 * This test verifies that basic instructions
 * (data transfers, addition/subtraction, jumps) work.
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, bad_jump
	lc r103, reg_is_nonzero
	
// Check that all registers are zero-initialized after reset
// Ignore r100-r103 which are already used
	cjmpne r103, r0, 0
	cjmpne r103, r1, 0
	cjmpne r103, r2, 0
	cjmpne r103, r3, 0
	cjmpne r103, r4, 0
	cjmpne r103, r5, 0
	cjmpne r103, r6, 0
	cjmpne r103, r7, 0
	cjmpne r103, r8, 0
	cjmpne r103, r9, 0
	cjmpne r103, r10, 0
	cjmpne r103, r11, 0
	cjmpne r103, r12, 0
	cjmpne r103, r13, 0
	cjmpne r103, r14, 0
	cjmpne r103, r15, 0
	cjmpne r103, r16, 0
	cjmpne r103, r17, 0
	cjmpne r103, r18, 0
	cjmpne r103, r19, 0
	cjmpne r103, r20, 0
	cjmpne r103, r21, 0
	cjmpne r103, r22, 0
	cjmpne r103, r23, 0
	cjmpne r103, r24, 0
	cjmpne r103, r25, 0
	cjmpne r103, r26, 0
	cjmpne r103, r27, 0
	cjmpne r103, r28, 0
	cjmpne r103, r29, 0
	cjmpne r103, r30, 0
	cjmpne r103, r31, 0
	cjmpne r103, r32, 0
	cjmpne r103, r33, 0
	cjmpne r103, r34, 0
	cjmpne r103, r35, 0
	cjmpne r103, r36, 0
	cjmpne r103, r37, 0
	cjmpne r103, r38, 0
	cjmpne r103, r39, 0
	cjmpne r103, r40, 0
	cjmpne r103, r41, 0
	cjmpne r103, r42, 0
	cjmpne r103, r43, 0
	cjmpne r103, r44, 0
	cjmpne r103, r45, 0
	cjmpne r103, r46, 0
	cjmpne r103, r47, 0
	cjmpne r103, r48, 0
	cjmpne r103, r49, 0
	cjmpne r103, r50, 0
	cjmpne r103, r51, 0
	cjmpne r103, r52, 0
	cjmpne r103, r53, 0
	cjmpne r103, r54, 0
	cjmpne r103, r55, 0
	cjmpne r103, r56, 0
	cjmpne r103, r57, 0
	cjmpne r103, r58, 0
	cjmpne r103, r59, 0
	cjmpne r103, r60, 0
	cjmpne r103, r61, 0
	cjmpne r103, r62, 0
	cjmpne r103, r63, 0
	cjmpne r103, r64, 0
	cjmpne r103, r65, 0
	cjmpne r103, r66, 0
	cjmpne r103, r67, 0
	cjmpne r103, r68, 0
	cjmpne r103, r69, 0
	cjmpne r103, r70, 0
	cjmpne r103, r71, 0
	cjmpne r103, r72, 0
	cjmpne r103, r73, 0
	cjmpne r103, r74, 0
	cjmpne r103, r75, 0
	cjmpne r103, r76, 0
	cjmpne r103, r77, 0
	cjmpne r103, r78, 0
	cjmpne r103, r79, 0
	cjmpne r103, r80, 0
	cjmpne r103, r81, 0
	cjmpne r103, r82, 0
	cjmpne r103, r83, 0
	cjmpne r103, r84, 0
	cjmpne r103, r85, 0
	cjmpne r103, r86, 0
	cjmpne r103, r87, 0
	cjmpne r103, r88, 0
	cjmpne r103, r89, 0
	cjmpne r103, r90, 0
	cjmpne r103, r91, 0
	cjmpne r103, r92, 0
	cjmpne r103, r93, 0
	cjmpne r103, r94, 0
	cjmpne r103, r95, 0
	cjmpne r103, r96, 0
	cjmpne r103, r97, 0
	cjmpne r103, r98, 0
	cjmpne r103, r99, 0
	cjmpne r103, r104, 0
	cjmpne r103, r105, 0
	cjmpne r103, r106, 0
	cjmpne r103, r107, 0
	cjmpne r103, r108, 0
	cjmpne r103, r109, 0
	cjmpne r103, r110, 0
	cjmpne r103, r111, 0
	cjmpne r103, r112, 0
	cjmpne r103, r113, 0
	cjmpne r103, r114, 0
	cjmpne r103, r115, 0
	cjmpne r103, r116, 0
	cjmpne r103, r117, 0
	cjmpne r103, r118, 0
	cjmpne r103, r119, 0
	cjmpne r103, r120, 0
	cjmpne r103, r121, 0
	cjmpne r103, r122, 0
	cjmpne r103, r123, 0
	cjmpne r103, r124, 0
	cjmpne r103, r125, 0
	cjmpne r103, r126, 0
	cjmpne r103, r127, 0
	cjmpne r103, r128, 0
	cjmpne r103, r129, 0
	cjmpne r103, r130, 0
	cjmpne r103, r131, 0
	cjmpne r103, r132, 0
	cjmpne r103, r133, 0
	cjmpne r103, r134, 0
	cjmpne r103, r135, 0
	cjmpne r103, r136, 0
	cjmpne r103, r137, 0
	cjmpne r103, r138, 0
	cjmpne r103, r139, 0
	cjmpne r103, r140, 0
	cjmpne r103, r141, 0
	cjmpne r103, r142, 0
	cjmpne r103, r143, 0
	cjmpne r103, r144, 0
	cjmpne r103, r145, 0
	cjmpne r103, r146, 0
	cjmpne r103, r147, 0
	cjmpne r103, r148, 0
	cjmpne r103, r149, 0
	cjmpne r103, r150, 0
	cjmpne r103, r151, 0
	cjmpne r103, r152, 0
	cjmpne r103, r153, 0
	cjmpne r103, r154, 0
	cjmpne r103, r155, 0
	cjmpne r103, r156, 0
	cjmpne r103, r157, 0
	cjmpne r103, r158, 0
	cjmpne r103, r159, 0
	cjmpne r103, r160, 0
	cjmpne r103, r161, 0
	cjmpne r103, r162, 0
	cjmpne r103, r163, 0
	cjmpne r103, r164, 0
	cjmpne r103, r165, 0
	cjmpne r103, r166, 0
	cjmpne r103, r167, 0
	cjmpne r103, r168, 0
	cjmpne r103, r169, 0
	cjmpne r103, r170, 0
	cjmpne r103, r171, 0
	cjmpne r103, r172, 0
	cjmpne r103, r173, 0
	cjmpne r103, r174, 0
	cjmpne r103, r175, 0
	cjmpne r103, r176, 0
	cjmpne r103, r177, 0
	cjmpne r103, r178, 0
	cjmpne r103, r179, 0
	cjmpne r103, r180, 0
	cjmpne r103, r181, 0
	cjmpne r103, r182, 0
	cjmpne r103, r183, 0
	cjmpne r103, r184, 0
	cjmpne r103, r185, 0
	cjmpne r103, r186, 0
	cjmpne r103, r187, 0
	cjmpne r103, r188, 0
	cjmpne r103, r189, 0
	cjmpne r103, r190, 0
	cjmpne r103, r191, 0
	cjmpne r103, r192, 0
	cjmpne r103, r193, 0
	cjmpne r103, r194, 0
	cjmpne r103, r195, 0
	cjmpne r103, r196, 0
	cjmpne r103, r197, 0
	cjmpne r103, r198, 0
	cjmpne r103, r199, 0
	cjmpne r103, r200, 0
	cjmpne r103, r201, 0
	cjmpne r103, r202, 0
	cjmpne r103, r203, 0
	cjmpne r103, r204, 0
	cjmpne r103, r205, 0
	cjmpne r103, r206, 0
	cjmpne r103, r207, 0
	cjmpne r103, r208, 0
	cjmpne r103, r209, 0
	cjmpne r103, r210, 0
	cjmpne r103, r211, 0
	cjmpne r103, r212, 0
	cjmpne r103, r213, 0
	cjmpne r103, r214, 0
	cjmpne r103, r215, 0
	cjmpne r103, r216, 0
	cjmpne r103, r217, 0
	cjmpne r103, r218, 0
	cjmpne r103, r219, 0
	cjmpne r103, r220, 0
	cjmpne r103, r221, 0
	cjmpne r103, r222, 0
	cjmpne r103, r223, 0
	cjmpne r103, r224, 0
	cjmpne r103, r225, 0
	cjmpne r103, r226, 0
	cjmpne r103, r227, 0
	cjmpne r103, r228, 0
	cjmpne r103, r229, 0
	cjmpne r103, r230, 0
	cjmpne r103, r231, 0
	cjmpne r103, r232, 0
	cjmpne r103, r233, 0
	cjmpne r103, r234, 0
	cjmpne r103, r235, 0
	cjmpne r103, r236, 0
	cjmpne r103, r237, 0
	cjmpne r103, r238, 0
	cjmpne r103, r239, 0
	cjmpne r103, r240, 0
	cjmpne r103, r241, 0
	cjmpne r103, r242, 0
	cjmpne r103, r243, 0
	cjmpne r103, r244, 0
	cjmpne r103, r245, 0
	cjmpne r103, r246, 0
	cjmpne r103, r247, 0
	cjmpne r103, r248, 0
	cjmpne r103, r249, 0
	cjmpne r103, r250, 0
	cjmpne r103, r251, 0
	cjmpne r103, r252, 0
	cjmpne r103, r253, 0
	cjmpne r103, r254, 0
	cjmpne r103, r255, 0
	lc r0, jump0
	jmp r0
	
reg_is_nonzero:
	sw r100, 2 // failure: register is not initialized
	jmp r101
	
// Test different jump conditions
jump0:
	lc r0, jump1
	jmp r0
	sw r100, 3 // failure: this instruction should not be reachable
	jmp r101
	
jump1:
	lc r0, jump2
	mov r1, 100
	cjmpne r0, r1, 101
	sw r100, 4 // failure: required jump is not taken
	jmp r101
	
jump2:
	lc r0, jump3
	cjmpe r0, r1, 100
	sw r100, 5 // failure: required jump is not taken
	jmp r101
	
jump3:
	lc r0, jump4
	cjmpuge r0, r1, 99
	sw r100, 6 // failure: required jump is not taken
	jmp r101
	
jump4:
	lc r0, jump5
	cjmpuge r0, r1, 100
	sw r100, 7 // failure: required jump is not taken
	jmp r101
	
jump5:
	lc r0, jump6
	cjmpug r0, r1, 99
	sw r100, 8 // failure: required jump is not taken
	jmp r101
	
jump6:
	lc r0, jump7
	cjmpsge r0, r1, -128
	sw r100, 9 // failure: required jump is not taken
	jmp r101
	
jump7:
	lc r0, jump8
	cjmpsge r0, r1, 100
	sw r100, 10 // failure: required jump is not taken
	jmp r101
	
jump8:
	lc r0, jump9
	cjmpsg r0, r1, 99
	sw r100, 11 // failure: required jump is not taken
	jmp r101
	
jump9:
	lc r0, 2227053353
	lc r1, 2933288161
	cjmpug r102, r0, r1

	lc r0, 3957963761
	lc r1, 4048130130
	cjmpug r102, r0, r1

	lc r0, 1021028019
	lc r1, 2570980487
	cjmpug r102, r0, r1

	lc r0, 470638116
	lc r1, 3729241862
	cjmpug r102, r0, r1

	lc r0, 2794175299
	lc r1, 3360494259
	cjmpug r102, r0, r1

	lc r0, 522532873
	lc r1, 2103051039
	cjmpug r102, r0, r1

	lc r0, 994440598
	lc r1, 4241216605
	cjmpug r102, r0, r1

	lc r0, 176753939
	lc r1, 850320156
	cjmpug r102, r0, r1

	lc r0, 3998259744
	lc r1, 4248205376
	cjmpug r102, r0, r1

	lc r0, 3695803806
	lc r1, 4130490642
	cjmpug r102, r0, r1

	lc r0, -798605244
	lc r1, -233549907
	cjmpsg r102, r0, r1

	lc r0, -1221540757
	lc r1, 580991794
	cjmpsg r102, r0, r1

	lc r0, -1651432714
	lc r1, -635466783
	cjmpsg r102, r0, r1

	lc r0, 43633328
	lc r1, 1235055289
	cjmpsg r102, r0, r1

	lc r0, -2132159079
	lc r1, -981565396
	cjmpsg r102, r0, r1

	lc r0, -859182414
	lc r1, -697843885
	cjmpsg r102, r0, r1

	lc r0, 1720638509
	lc r1, 2127959231
	cjmpsg r102, r0, r1

	lc r0, -1888878751
	lc r1, 1230499715
	cjmpsg r102, r0, r1

	lc r0, 517066081
	lc r1, 1914084509
	cjmpsg r102, r0, r1

	lc r0, -266475918
	lc r1, 2001358724
	cjmpsg r102, r0, r1

	mov r1, 100
	cjmpe r102, r1, 101
	cjmpne r102, r1, 100
	cjmpuge r102, r1, 101
	cjmpug r102, r1, 100
	cjmpug r102, r1, 101
	cjmpsge r102, r1, 101
	cjmpsg r102, r1, 101
	cjmpsg r102, r1, 100
	cjmpsg r102, -128, r1
	lc r0, jump10
	jmp r0
	
bad_jump:
	sw r100, 12 // failure: jump should not be taken
	jmp r101
	
jump10:

// Copy itself to another portion of memory
	mov r0, 0 // source pointer
	lc r1, 0x00008000 // destination pointer
	lc r2, halt@2 // size of block to copy, in bytes
	lc r32, copy_loop
	
copy_loop:
	lw r3, r0
	sw r1, r3
	add r0, r0, 4
	add r1, r1, 4
	cjmpul r32, r0, r2

// Calculate sum of program body in a post-condition loop
	mov r0, 0 // pointer
	mov r16, 0 // sum
	lc r32, sum_loop
	
sum_loop:
	lw r1, r0
	add r16, r16, r1
	add r0, r0, 4
	cjmpul r32, r0, r2

// Calculate sum of copied program body with negative sign, in a pre-condition loop
	lc r0, 0x00008000 // pointer
	add r2, r0, r2 // end pointer
	mov r17, 0 // sum
	lc r32, sum2_loop
	lc r33, sum2_end
	
sum2_loop:
	cjmpuge r33, r0, r2
	lw r1, r0
	sub r17, r17, r1
	add r0, r0, 4
	jmp r32
	sw r100, 13 // failure: this instruction should not be reachable
	jmp r101

sum2_end:

// Check that sums are equal (but with opposite signs)
	add r0, r16, r17 // r0 should be zero now
	lc r32, success
	cjmpe r32, r0, 0
	sw r100, 14 // failure: results do not match
	jmp r101
	
success:
	sw r100, 1
	
halt:
	hlt
	jmp r101
