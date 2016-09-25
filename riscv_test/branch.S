// Test Branches
.section .text
.global _start
_start:

li gp,0x100
li a1,1 // true
li a2,0 // false

//  eq
li t1, 5
li t2, 5
beq t1,t2, label1
sb a2,0(gp) // not ok...
label1:
sb a1,0(gp) // ok
bne t1,t2, label2
sb a1,1(gp) // ok
label2:
sb a2,2(gp) // not ok
addi t2,t2,1 // t2 now 6 
blt t1,t2,label3
sb a2,3(gp) // not ok
label3:
sb a1,3(gp) // ok
bge t1,t2,label4
sb a1,4(gp)
label4:
sb a2,4(gp)
bge t2,t1, label6
sb a2,5(gp) // not ok
label6:
sb a1,5(gp) // ok

li t1, -5
blt t1,t2,label7 // -5 < 6 should be true
sb a2,6(gp) // not ok
label7:
sb a1,6(gp) //  ok
bltu t1,t2, label8 // when t1,t2 considered inigned t1 < t2 is false
sb a1,7(gp)
label8:
sb a2,7(gp)


endless:
j endless

