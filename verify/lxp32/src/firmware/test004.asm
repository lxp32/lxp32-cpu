/*
 * This test verifies that nop instruction does not change
 * register values.
 */

	lc r0, failure
	nop
	mov r1, 1
	nop
	mov r2, 2
	mov r3, 3
	nop
	mov r4, 4
	mov r5, 5
	mov r6, 6
	nop
	nop
	mov r7, 7
	mov r8, 8
	mov r9, 9
	nop
	mov r10, 10
	mov r11, 11
	mov r12, 12
	mov r13, 13
	mov r14, 14
	mov r15, 15
	mov r16, 16
	mov r17, 17
	mov r18, 18
	mov r19, 19
	mov r20, 20
	mov r21, 21
	mov r22, 22
	mov r23, 23
	mov r24, 24
	mov r25, 25
	mov r26, 26
	mov r27, 27
	mov r28, 28
	mov r29, 29
	mov r30, 30
	mov r31, 31
	mov r32, 32
	mov r33, 33
	mov r34, 34
	mov r35, 35
	mov r36, 36
	mov r37, 37
	mov r38, 38
	mov r39, 39
	mov r40, 40
	mov r41, 41
	mov r42, 42
	mov r43, 43
	mov r44, 44
	mov r45, 45
	mov r46, 46
	mov r47, 47
	mov r48, 48
	mov r49, 49
	mov r50, 50
	mov r51, 51
	mov r52, 52
	mov r53, 53
	mov r54, 54
	mov r55, 55
	mov r56, 56
	mov r57, 57
	mov r58, 58
	mov r59, 59
	mov r60, 60
	mov r61, 61
	mov r62, 62
	mov r63, 63
	mov r64, 64
	mov r65, 65
	mov r66, 66
	mov r67, 67
	mov r68, 68
	mov r69, 69
	mov r70, 70
	mov r71, 71
	mov r72, 72
	mov r73, 73
	mov r74, 74
	mov r75, 75
	mov r76, 76
	mov r77, 77
	mov r78, 78
	mov r79, 79
	mov r80, 80
	mov r81, 81
	mov r82, 82
	mov r83, 83
	mov r84, 84
	mov r85, 85
	mov r86, 86
	mov r87, 87
	mov r88, 88
	mov r89, 89
	mov r90, 90
	mov r91, 91
	mov r92, 92
	mov r93, 93
	mov r94, 94
	mov r95, 95
	mov r96, 96
	mov r97, 97
	mov r98, 98
	mov r99, 99
	mov r100, 0
	mov r101, 1
	mov r102, 2
	mov r103, 3
	mov r104, 4
	mov r105, 5
	mov r106, 6
	mov r107, 7
	mov r108, 8
	mov r109, 9
	mov r110, 10
	mov r111, 11
	mov r112, 12
	mov r113, 13
	mov r114, 14
	mov r115, 15
	mov r116, 16
	mov r117, 17
	mov r118, 18
	mov r119, 19
	mov r120, 20
	mov r121, 21
	mov r122, 22
	mov r123, 23
	mov r124, 24
	mov r125, 25
	mov r126, 26
	mov r127, 27
	mov r128, 28
	mov r129, 29
	mov r130, 30
	mov r131, 31
	mov r132, 32
	mov r133, 33
	mov r134, 34
	mov r135, 35
	mov r136, 36
	mov r137, 37
	mov r138, 38
	mov r139, 39
	mov r140, 40
	mov r141, 41
	mov r142, 42
	mov r143, 43
	mov r144, 44
	mov r145, 45
	mov r146, 46
	mov r147, 47
	mov r148, 48
	mov r149, 49
	mov r150, 50
	mov r151, 51
	mov r152, 52
	mov r153, 53
	mov r154, 54
	mov r155, 55
	mov r156, 56
	mov r157, 57
	mov r158, 58
	mov r159, 59
	mov r160, 60
	mov r161, 61
	mov r162, 62
	mov r163, 63
	mov r164, 64
	mov r165, 65
	mov r166, 66
	mov r167, 67
	mov r168, 68
	mov r169, 69
	mov r170, 70
	mov r171, 71
	mov r172, 72
	mov r173, 73
	mov r174, 74
	mov r175, 75
	mov r176, 76
	mov r177, 77
	mov r178, 78
	mov r179, 79
	mov r180, 80
	mov r181, 81
	mov r182, 82
	mov r183, 83
	mov r184, 84
	mov r185, 85
	mov r186, 86
	mov r187, 87
	mov r188, 88
	mov r189, 89
	mov r190, 90
	mov r191, 91
	mov r192, 92
	mov r193, 93
	mov r194, 94
	mov r195, 95
	mov r196, 96
	mov r197, 97
	mov r198, 98
	mov r199, 99
	mov r200, 0
	mov r201, 1
	mov r202, 2
	mov r203, 3
	mov r204, 4
	mov r205, 5
	mov r206, 6
	mov r207, 7
	mov r208, 8
	mov r209, 9
	mov r210, 10
	mov r211, 11
	mov r212, 12
	mov r213, 13
	mov r214, 14
	mov r215, 15
	mov r216, 16
	mov r217, 17
	mov r218, 18
	mov r219, 19
	mov r220, 20
	mov r221, 21
	mov r222, 22
	mov r223, 23
	mov r224, 24
	mov r225, 25
	mov r226, 26
	mov r227, 27
	mov r228, 28
	mov r229, 29
	mov r230, 30
	mov r231, 31
	mov r232, 32
	mov r233, 33
	mov r234, 34
	mov r235, 35
	mov r236, 36
	mov r237, 37
	mov r238, 38
	mov r239, 39
	mov r240, 40
	mov r241, 41
	mov r242, 42
	mov r243, 43
	mov r244, 44
	mov r245, 45
	mov r246, 46
	mov r247, 47
	mov r248, 48
	mov r249, 49
	mov r250, 50
	mov r251, 51
	mov r252, 52
	mov r253, 53
	mov r254, 54
	mov r255, 55
	
	nop
	nop
	nop
	
	cjmpne r0, r1, 1
	nop
	cjmpne r0, r2, 2
	nop
	nop
	cjmpne r0, r3, 3
	cjmpne r0, r4, 4
	cjmpne r0, r5, 5
	nop
	cjmpne r0, r6, 6
	cjmpne r0, r7, 7
	cjmpne r0, r8, 8
	cjmpne r0, r9, 9
	cjmpne r0, r10, 10
	cjmpne r0, r11, 11
	nop
	nop
	nop
	cjmpne r0, r12, 12
	cjmpne r0, r13, 13
	cjmpne r0, r14, 14
	cjmpne r0, r15, 15
	cjmpne r0, r16, 16
	cjmpne r0, r17, 17
	cjmpne r0, r18, 18
	cjmpne r0, r19, 19
	cjmpne r0, r20, 20
	cjmpne r0, r21, 21
	cjmpne r0, r22, 22
	cjmpne r0, r23, 23
	cjmpne r0, r24, 24
	cjmpne r0, r25, 25
	cjmpne r0, r26, 26
	cjmpne r0, r27, 27
	cjmpne r0, r28, 28
	cjmpne r0, r29, 29
	cjmpne r0, r30, 30
	cjmpne r0, r31, 31
	cjmpne r0, r32, 32
	cjmpne r0, r33, 33
	cjmpne r0, r34, 34
	cjmpne r0, r35, 35
	cjmpne r0, r36, 36
	cjmpne r0, r37, 37
	cjmpne r0, r38, 38
	cjmpne r0, r39, 39
	cjmpne r0, r40, 40
	cjmpne r0, r41, 41
	cjmpne r0, r42, 42
	cjmpne r0, r43, 43
	cjmpne r0, r44, 44
	cjmpne r0, r45, 45
	cjmpne r0, r46, 46
	cjmpne r0, r47, 47
	cjmpne r0, r48, 48
	cjmpne r0, r49, 49
	cjmpne r0, r50, 50
	cjmpne r0, r51, 51
	cjmpne r0, r52, 52
	cjmpne r0, r53, 53
	cjmpne r0, r54, 54
	cjmpne r0, r55, 55
	cjmpne r0, r56, 56
	cjmpne r0, r57, 57
	cjmpne r0, r58, 58
	cjmpne r0, r59, 59
	cjmpne r0, r60, 60
	cjmpne r0, r61, 61
	cjmpne r0, r62, 62
	cjmpne r0, r63, 63
	cjmpne r0, r64, 64
	cjmpne r0, r65, 65
	cjmpne r0, r66, 66
	cjmpne r0, r67, 67
	cjmpne r0, r68, 68
	cjmpne r0, r69, 69
	cjmpne r0, r70, 70
	cjmpne r0, r71, 71
	cjmpne r0, r72, 72
	cjmpne r0, r73, 73
	cjmpne r0, r74, 74
	cjmpne r0, r75, 75
	cjmpne r0, r76, 76
	cjmpne r0, r77, 77
	cjmpne r0, r78, 78
	cjmpne r0, r79, 79
	cjmpne r0, r80, 80
	cjmpne r0, r81, 81
	cjmpne r0, r82, 82
	cjmpne r0, r83, 83
	cjmpne r0, r84, 84
	cjmpne r0, r85, 85
	cjmpne r0, r86, 86
	cjmpne r0, r87, 87
	cjmpne r0, r88, 88
	cjmpne r0, r89, 89
	cjmpne r0, r90, 90
	cjmpne r0, r91, 91
	cjmpne r0, r92, 92
	cjmpne r0, r93, 93
	cjmpne r0, r94, 94
	cjmpne r0, r95, 95
	cjmpne r0, r96, 96
	cjmpne r0, r97, 97
	cjmpne r0, r98, 98
	cjmpne r0, r99, 99
	cjmpne r0, r100, 0
	cjmpne r0, r101, 1
	cjmpne r0, r102, 2
	cjmpne r0, r103, 3
	cjmpne r0, r104, 4
	cjmpne r0, r105, 5
	cjmpne r0, r106, 6
	cjmpne r0, r107, 7
	cjmpne r0, r108, 8
	cjmpne r0, r109, 9
	cjmpne r0, r110, 10
	cjmpne r0, r111, 11
	cjmpne r0, r112, 12
	cjmpne r0, r113, 13
	cjmpne r0, r114, 14
	cjmpne r0, r115, 15
	cjmpne r0, r116, 16
	cjmpne r0, r117, 17
	cjmpne r0, r118, 18
	cjmpne r0, r119, 19
	cjmpne r0, r120, 20
	cjmpne r0, r121, 21
	cjmpne r0, r122, 22
	cjmpne r0, r123, 23
	cjmpne r0, r124, 24
	cjmpne r0, r125, 25
	cjmpne r0, r126, 26
	cjmpne r0, r127, 27
	cjmpne r0, r128, 28
	cjmpne r0, r129, 29
	cjmpne r0, r130, 30
	cjmpne r0, r131, 31
	cjmpne r0, r132, 32
	cjmpne r0, r133, 33
	cjmpne r0, r134, 34
	cjmpne r0, r135, 35
	cjmpne r0, r136, 36
	cjmpne r0, r137, 37
	cjmpne r0, r138, 38
	cjmpne r0, r139, 39
	cjmpne r0, r140, 40
	cjmpne r0, r141, 41
	cjmpne r0, r142, 42
	cjmpne r0, r143, 43
	cjmpne r0, r144, 44
	cjmpne r0, r145, 45
	cjmpne r0, r146, 46
	cjmpne r0, r147, 47
	cjmpne r0, r148, 48
	cjmpne r0, r149, 49
	cjmpne r0, r150, 50
	cjmpne r0, r151, 51
	cjmpne r0, r152, 52
	cjmpne r0, r153, 53
	cjmpne r0, r154, 54
	cjmpne r0, r155, 55
	cjmpne r0, r156, 56
	cjmpne r0, r157, 57
	cjmpne r0, r158, 58
	cjmpne r0, r159, 59
	cjmpne r0, r160, 60
	cjmpne r0, r161, 61
	cjmpne r0, r162, 62
	cjmpne r0, r163, 63
	cjmpne r0, r164, 64
	cjmpne r0, r165, 65
	cjmpne r0, r166, 66
	cjmpne r0, r167, 67
	cjmpne r0, r168, 68
	cjmpne r0, r169, 69
	cjmpne r0, r170, 70
	cjmpne r0, r171, 71
	cjmpne r0, r172, 72
	cjmpne r0, r173, 73
	cjmpne r0, r174, 74
	cjmpne r0, r175, 75
	cjmpne r0, r176, 76
	cjmpne r0, r177, 77
	cjmpne r0, r178, 78
	cjmpne r0, r179, 79
	cjmpne r0, r180, 80
	cjmpne r0, r181, 81
	cjmpne r0, r182, 82
	cjmpne r0, r183, 83
	cjmpne r0, r184, 84
	cjmpne r0, r185, 85
	cjmpne r0, r186, 86
	cjmpne r0, r187, 87
	cjmpne r0, r188, 88
	cjmpne r0, r189, 89
	cjmpne r0, r190, 90
	cjmpne r0, r191, 91
	cjmpne r0, r192, 92
	cjmpne r0, r193, 93
	cjmpne r0, r194, 94
	cjmpne r0, r195, 95
	cjmpne r0, r196, 96
	cjmpne r0, r197, 97
	cjmpne r0, r198, 98
	cjmpne r0, r199, 99
	cjmpne r0, r200, 0
	cjmpne r0, r201, 1
	cjmpne r0, r202, 2
	cjmpne r0, r203, 3
	cjmpne r0, r204, 4
	cjmpne r0, r205, 5
	cjmpne r0, r206, 6
	cjmpne r0, r207, 7
	cjmpne r0, r208, 8
	cjmpne r0, r209, 9
	cjmpne r0, r210, 10
	cjmpne r0, r211, 11
	cjmpne r0, r212, 12
	cjmpne r0, r213, 13
	cjmpne r0, r214, 14
	cjmpne r0, r215, 15
	cjmpne r0, r216, 16
	cjmpne r0, r217, 17
	cjmpne r0, r218, 18
	cjmpne r0, r219, 19
	cjmpne r0, r220, 20
	cjmpne r0, r221, 21
	cjmpne r0, r222, 22
	cjmpne r0, r223, 23
	cjmpne r0, r224, 24
	cjmpne r0, r225, 25
	cjmpne r0, r226, 26
	cjmpne r0, r227, 27
	cjmpne r0, r228, 28
	cjmpne r0, r229, 29
	cjmpne r0, r230, 30
	cjmpne r0, r231, 31
	cjmpne r0, r232, 32
	cjmpne r0, r233, 33
	cjmpne r0, r234, 34
	cjmpne r0, r235, 35
	cjmpne r0, r236, 36
	cjmpne r0, r237, 37
	cjmpne r0, r238, 38
	cjmpne r0, r239, 39
	cjmpne r0, r240, 40
	cjmpne r0, r241, 41
	cjmpne r0, r242, 42
	cjmpne r0, r243, 43
	cjmpne r0, r244, 44
	cjmpne r0, r245, 45
	cjmpne r0, r246, 46
	cjmpne r0, r247, 47
	cjmpne r0, r248, 48
	cjmpne r0, r249, 49
	cjmpne r0, r250, 50
	cjmpne r0, r251, 51
	cjmpne r0, r252, 52
	cjmpne r0, r253, 53
	cjmpne r0, r254, 54
	cjmpne r0, r255, 55
	
	lc r100, 0x10000000
	lc r101, halt
	sw r100, 1
	jmp r101
	
failure:
	lc r100, 0x10000000
	lc r101, halt
	sw r100, 2
	
halt:
	hlt
	jmp r101
