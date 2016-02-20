/*
 * Test division (divu, divs, modu, mods)
 */

	lc r100, 0x10000000 // test result output pointer
	lc r101, halt
	lc r102, failure
	lc r103, 0x10000004
	
// Test unsigned division
	
	lc r32, op1
	lc r33, op2
	lc r34, quotient
	lc r35, remainder
	lc r36, cnt_loop
	lc r10, 100 // counter
	
cnt_loop:
	lw r0, r32
	lw r1, r33
	divu r2, r0, r1
	modu r3, r0, r1
	lw r4, r34
	lw r5, r35
	cjmpne r102, r2, r4 // failure
	cjmpne r102, r3, r5 // failure
	mul r6, r2, r1
	add r6, r6, r3
	cjmpne r102, r6, r0 // failure
	add r32, r32, 4
	add r33, r33, 4
	add r34, r34, 4
	add r35, r35, 4
	sub r10, r10, 1
	cjmpug r36, r10, 0 // cnt_loop
	
	sw r103, 1

// Test signed division

	lc r32, op1_signed
	lc r33, op2_signed
	lc r34, quotient_signed
	lc r35, remainder_signed
	lc r36, cnt_loop2
	lc r10, 100 // counter
	
cnt_loop2:
	lw r0, r32
	lw r1, r33
	divs r2, r0, r1
	mods r3, r0, r1
	lw r4, r34
	lw r5, r35
	cjmpne r102, r2, r4 // failure
	cjmpne r102, r3, r5 // failure
	mul r6, r2, r1
	add r6, r6, r3
	cjmpne r102, r6, r0 // failure
	add r32, r32, 4
	add r33, r33, 4
	add r34, r34, 4
	add r35, r35, 4
	sub r10, r10, 1
	cjmpug r36, r10, 0 // cnt_loop2
	
	sw r103, 2
	
// Random division/multiplication test

	mov r64, 1 // initial PRBS value
	lc r65, 1103515245 // PRBS multiplier
	lc r66, 12345 // PRBS addition constant
	lc r67, 32767 // PRBS mask
	lc r68, 16384
	
	lc r10, 1000
	lc r32, rnd_loop
	lc r33, rand
	lc r34, rnd_cont
	
rnd_loop:
	call r33 // rand
	sub r1, r0, r68 // dividend in r1
	call r33 // rand
	sub r2, r0, r68 // divisor in r2
	cjmpne r34, r2, 0 // rnd_cont
	mov r2, 1
	
rnd_cont:
	divs r3, r1, r2
	mods r4, r1, r2
	mul r5, r3, r2
	add r5, r5, r4
	cjmpne r102, r5, r1 // failure
	sub r10, r10, 1
	cjmpug r32, r10, 0 // rnd_loop
	
	sw r103, 3
	
	sw r100, 1
	jmp r101 // halt
	
failure:
	sw r100, 2
	
halt:
	hlt
	jmp r101 // halt

// Linear congruent pseudo-random number generator (as in ISO/IEC 9899:1999)

rand:
	mul r64, r64, r65
	add r64, r64, r66
	sru r0, r64, 16
	and r0, r0, r67
	ret

op1:
	.word 2227053353
	.word 4059122064
	.word 210189531
	.word 1203176988
	.word 2794175299
	.word 1562322232
	.word 219364165
	.word 1352278066
	.word 4130490642
	.word 1156715599
	.word 993179440
	.word 529260957
	.word 1235055289
	.word 2994792917
	.word 348116583
	.word 1475314534
	.word 517066081
	.word 2230328806
	.word 1395407336
	.word 4094467700
	.word 3476389465
	.word 1210945747
	.word 3236243997
	.word 1348406852
	.word 118818171
	.word 1692045936
	.word 1190663529
	.word 1731139289
	.word 1986549712
	.word 2038965422
	.word 1173634277
	.word 1499514357
	.word 3268423030
	.word 136673642
	.word 672245098
	.word 797742983
	.word 3236010945
	.word 1421197958
	.word 948983249
	.word 3780009574
	.word 3802522271
	.word 2303076920
	.word 2976105080
	.word 2531287614
	.word 4049504575
	.word 488644257
	.word 336561159
	.word 753386953
	.word 4270696691
	.word 1966854304
	.word 3201322355
	.word 4203490113
	.word 2503116372
	.word 3405118694
	.word 3103595329
	.word 3553466644
	.word 861103782
	.word 1275325516
	.word 3484264974
	.word 1293196760
	.word 4173438076
	.word 2275850340
	.word 3885575502
	.word 1091087744
	.word 2669208735
	.word 69325132
	.word 2319663187
	.word 2510410703
	.word 2902980138
	.word 845791433
	.word 3327530895
	.word 948013067
	.word 3889190137
	.word 2250058130
	.word 927988252
	.word 1820385269
	.word 135357763
	.word 3770160619
	.word 1650193531
	.word 1250420215
	.word 2982397572
	.word 788754293
	.word 1132578971
	.word 2174830494
	.word 2743197342
	.word 1473236291
	.word 671295260
	.word 1615737929
	.word 722317890
	.word 1373795119
	.word 3187744723
	.word 353993505
	.word 3691968907
	.word 2452722797
	.word 1784599952
	.word 912987979
	.word 2183033578
	.word 2941180254
	.word 3706025245
	.word 2141225307

op2:
	.word 225
	.word 3018582459
	.word 6462
	.word 222
	.word 799
	.word 19412
	.word 3676048009
	.word 16622
	.word 32158
	.word 64
	.word 8865
	.word 2580197594
	.word 3313401900
	.word 1405929962
	.word 214
	.word 24905
	.word 1914084509
	.word 41372239
	.word 203
	.word 213
	.word 50
	.word 3866464211
	.word 247
	.word 2371998720
	.word 528626491
	.word 2243022420
	.word 106
	.word 21608
	.word 250
	.word 635130622
	.word 22739
	.word 61
	.word 3563638217
	.word 97
	.word 2849410241
	.word 241
	.word 2594761086
	.word 191
	.word 40
	.word 48
	.word 6924
	.word 2054783657
	.word 702209830
	.word 968832018
	.word 1826819693
	.word 17099
	.word 25861
	.word 142
	.word 190
	.word 3078
	.word 130
	.word 32560
	.word 170
	.word 2308931006
	.word 26703
	.word 13
	.word 19211
	.word 115
	.word 667594965
	.word 1495759348
	.word 205
	.word 19605
	.word 61
	.word 2772527081
	.word 16917
	.word 147
	.word 175
	.word 206
	.word 16033
	.word 2356
	.word 7643
	.word 97
	.word 2017990513
	.word 41
	.word 13752
	.word 109
	.word 165
	.word 225
	.word 2698
	.word 12859
	.word 12455
	.word 158
	.word 4136249385
	.word 3446419784
	.word 140
	.word 20679
	.word 23935
	.word 48162108
	.word 5302
	.word 126
	.word 80
	.word 741054488
	.word 188
	.word 116
	.word 64
	.word 177
	.word 141
	.word 16378
	.word 3662043152
	.word 19292

quotient:
	.word 9898014
	.word 1
	.word 32527
	.word 5419716
	.word 3497090
	.word 80482
	.word 0
	.word 81354
	.word 128443
	.word 18073681
	.word 112033
	.word 0
	.word 0
	.word 2
	.word 1626713
	.word 59237
	.word 0
	.word 53
	.word 6873927
	.word 19222853
	.word 69527789
	.word 0
	.word 13102202
	.word 0
	.word 0
	.word 0
	.word 11232674
	.word 80115
	.word 7946198
	.word 3
	.word 51613
	.word 24582202
	.word 0
	.word 1409006
	.word 0
	.word 3310136
	.word 1
	.word 7440827
	.word 23724581
	.word 78750199
	.word 549179
	.word 1
	.word 4
	.word 2
	.word 2
	.word 28577
	.word 13014
	.word 5305541
	.word 22477351
	.word 639003
	.word 24625556
	.word 129099
	.word 14724213
	.word 1
	.word 116226
	.word 273343588
	.word 44823
	.word 11089787
	.word 5
	.word 0
	.word 20358234
	.word 116085
	.word 63697959
	.word 0
	.word 157782
	.word 471599
	.word 13255218
	.word 12186459
	.word 181062
	.word 358994
	.word 435369
	.word 9773330
	.word 1
	.word 54879466
	.word 67480
	.word 16700782
	.word 820350
	.word 16756269
	.word 611635
	.word 97240
	.word 239453
	.word 4992115
	.word 0
	.word 0
	.word 19594266
	.word 71243
	.word 28046
	.word 33
	.word 136234
	.word 10903135
	.word 39846809
	.word 0
	.word 19638132
	.word 21144162
	.word 27884374
	.word 5158124
	.word 15482507
	.word 179581
	.word 1
	.word 110990

remainder:
	.word 203
	.word 1040539605
	.word 57
	.word 36
	.word 389
	.word 5648
	.word 219364165
	.word 11878
	.word 20648
	.word 15
	.word 6895
	.word 529260957
	.word 1235055289
	.word 182932993
	.word 1
	.word 17049
	.word 517066081
	.word 37600139
	.word 155
	.word 11
	.word 15
	.word 1210945747
	.word 103
	.word 1348406852
	.word 118818171
	.word 1692045936
	.word 85
	.word 14369
	.word 212
	.word 133573556
	.word 6270
	.word 35
	.word 3268423030
	.word 60
	.word 672245098
	.word 207
	.word 641249859
	.word 1
	.word 9
	.word 22
	.word 6875
	.word 248293263
	.word 167265760
	.word 593623578
	.word 395865189
	.word 6134
	.word 6105
	.word 131
	.word 1
	.word 3070
	.word 75
	.word 26673
	.word 162
	.word 1096187688
	.word 12451
	.word 0
	.word 9129
	.word 11
	.word 146290149
	.word 1293196760
	.word 106
	.word 3915
	.word 3
	.word 1091087744
	.word 10641
	.word 79
	.word 37
	.word 149
	.word 13092
	.word 1569
	.word 5628
	.word 57
	.word 1871199624
	.word 24
	.word 3292
	.word 31
	.word 13
	.word 94
	.word 2301
	.word 11055
	.word 10457
	.word 123
	.word 1132578971
	.word 2174830494
	.word 102
	.word 2294
	.word 14250
	.word 26388365
	.word 5222
	.word 109
	.word 3
	.word 353993505
	.word 91
	.word 5
	.word 16
	.word 31
	.word 91
	.word 2636
	.word 43982093
	.word 6227

op1_signed:
	.word 1173464398
	.word 644568570
	.word 1413618866
	.word 940280095
	.word 1307051796
	.word 69701148
	.word 791353789
	.word -1751134801
	.word -540034563
	.word -664201053
	.word 859052625
	.word 506263265
	.word 1672805452
	.word -940950084
	.word 639564287
	.word -320080770
	.word -194326606
	.word -1401122692
	.word 1361841711
	.word -1572666822
	.word 223085807
	.word -2143536785
	.word -771364638
	.word -392756254
	.word -2075946315
	.word -133598861
	.word 869612982
	.word 727395029
	.word -1173738546
	.word 1865699269
	.word 1001660457
	.word -1435705417
	.word 313397375
	.word 91734875
	.word 55211040
	.word -1298145437
	.word -1587928274
	.word 120185203
	.word 1253220522
	.word 664380448
	.word 659766337
	.word -1867423126
	.word 211715071
	.word 1172375319
	.word 1010876232
	.word 1866163921
	.word 1337698510
	.word -1489886717
	.word -844206754
	.word 1252556476
	.word 1062583479
	.word -2028701144
	.word -925730358
	.word 63629404
	.word 2084388372
	.word 1185701000
	.word 344972780
	.word 1506745295
	.word -1310164994
	.word 785548626
	.word -960828075
	.word -788757195
	.word 1742449807
	.word 1952581789
	.word -1868879050
	.word -727870971
	.word 457544035
	.word -2083100074
	.word 2092326142
	.word 456912800
	.word -1930624925
	.word 1981026677
	.word -641082819
	.word 1259278117
	.word 1481501124
	.word -444342667
	.word 1947675341
	.word -608834426
	.word -906130612
	.word -480045052
	.word 182898482
	.word 1025708506
	.word -363535658
	.word 1180470009
	.word -62562240
	.word 987486196
	.word -531865065
	.word 676720261
	.word 1125242878
	.word -1621168845
	.word 1990517921
	.word -1383494740
	.word -1522980151
	.word 434249114
	.word -129245145
	.word 97983477
	.word 658513595
	.word 1548110625
	.word 1140579073
	.word -1285950881

op2_signed:
	.word 1389891600
	.word 176
	.word -129
	.word -10300
	.word -24713
	.word 36
	.word 539501672
	.word -412262764
	.word -999517400
	.word 27
	.word -185
	.word 632355259
	.word 1914747195
	.word -202
	.word 152
	.word -151
	.word -49343821
	.word 161975794
	.word -172
	.word -3509
	.word 8811
	.word -135
	.word -224114196
	.word 5373
	.word -30158
	.word 735955126
	.word 7320
	.word -1137550910
	.word 413980723
	.word -28499
	.word -1858419248
	.word -31374
	.word 153
	.word -245
	.word -231
	.word 1065580722
	.word 114
	.word 25851
	.word 1113949699
	.word 1883394154
	.word 211
	.word 22075
	.word -143
	.word -1052684430
	.word -197
	.word -28563
	.word -12517
	.word 141
	.word -197
	.word -79
	.word 79
	.word -103
	.word 563090517
	.word -13711
	.word -2
	.word -250
	.word -130626268
	.word -1824933506
	.word 501
	.word 135
	.word -965460037
	.word 90
	.word -24983
	.word -5626
	.word -175
	.word -42
	.word -72
	.word 9948
	.word -29411
	.word 223
	.word 16237
	.word -192
	.word -297352066
	.word 2140975764
	.word -511619965
	.word -7170
	.word -380546211
	.word 1065203866
	.word -81584403
	.word -23445
	.word 213
	.word 31410
	.word -270351532
	.word -8040
	.word -13293
	.word 16010
	.word -223
	.word -60
	.word 9338
	.word -46
	.word 26045
	.word 21525
	.word 1705744137
	.word 1754448529
	.word -1602585578
	.word 1341015177
	.word 1
	.word -72
	.word -156
	.word 1932634409

quotient_signed:
	.word 0
	.word 3662321
	.word -10958285
	.word -91289
	.word -52889
	.word 1936143
	.word 1
	.word 4
	.word 0
	.word -24600039
	.word -4643527
	.word 0
	.word 0
	.word 4658168
	.word 4207659
	.word 2119740
	.word 3
	.word -8
	.word -7917684
	.word 448180
	.word 25319
	.word 15878050
	.word 3
	.word -73098
	.word 68835
	.word 0
	.word 118799
	.word 0
	.word -2
	.word -65465
	.word 0
	.word 45760
	.word 2048348
	.word -374428
	.word -239008
	.word -1
	.word -13929195
	.word 4649
	.word 1
	.word 0
	.word 3126854
	.word -84594
	.word -1480524
	.word -1
	.word -5131351
	.word -65335
	.word -106870
	.word -10566572
	.word 4285313
	.word -15855145
	.word 13450423
	.word 19696127
	.word -1
	.word -4640
	.word -1042194186
	.word -4742804
	.word -2
	.word 0
	.word -2615099
	.word 5818878
	.word 0
	.word -8763968
	.word -69745
	.word -347063
	.word 10679308
	.word 17330261
	.word -6354778
	.word -209398
	.word -71140
	.word 2048936
	.word -118902
	.word -10317847
	.word 2
	.word 0
	.word -2
	.word 61972
	.word -5
	.word 0
	.word 11
	.word 20475
	.word 858678
	.word 32655
	.word 1
	.word -146824
	.word 4706
	.word 61679
	.word 2385045
	.word -11278671
	.word 120501
	.word 35242800
	.word 76426
	.word -64273
	.word 0
	.word 0
	.word 0
	.word 0
	.word 658513595
	.word -21501536
	.word -7311404
	.word 0

remainder_signed:
	.word 1173464398
	.word 74
	.word 101
	.word 3395
	.word 5939
	.word 0
	.word 251852117
	.word -102083745
	.word -540034563
	.word 0
	.word 130
	.word 506263265
	.word 1672805452
	.word -148
	.word 119
	.word -30
	.word -46295143
	.word -105316340
	.word 63
	.word -3202
	.word 98
	.word -35
	.word -99022050
	.word -700
	.word -20385
	.word -133598861
	.word 4302
	.word 727395029
	.word -345777100
	.word 12234
	.word 1001660457
	.word -31177
	.word 131
	.word 15
	.word 192
	.word -232564715
	.word -44
	.word 3904
	.word 139270823
	.word 664380448
	.word 143
	.word -10576
	.word 139
	.word 119690889
	.word 85
	.word 316
	.word 6720
	.word -65
	.word -93
	.word 21
	.word 62
	.word -63
	.word -362639841
	.word 10364
	.word 0
	.word 0
	.word 83720244
	.word 1506745295
	.word -395
	.word 96
	.word -960828075
	.word -75
	.word 10472
	.word 5351
	.word -150
	.word -9
	.word 19
	.word -8770
	.word 27602
	.word 72
	.word -13151
	.word 53
	.word -46378687
	.word 1259278117
	.word 458261194
	.word -3427
	.word 44944286
	.word -608834426
	.word -8702179
	.word -8677
	.word 68
	.word 14956
	.word -93184126
	.word 5049
	.word -5382
	.word 5406
	.word -30
	.word 1
	.word 4540
	.word -45
	.word 2751
	.word -18415
	.word -1522980151
	.word 434249114
	.word -129245145
	.word 97983477
	.word 0
	.word 33
	.word 49
	.word -1285950881
