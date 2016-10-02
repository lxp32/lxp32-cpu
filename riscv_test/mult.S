.section .text
.global _start
_start:

li t1,1
li t2,5
li t3,11
li gp,0x0100 // memory pointer

loop:
mul t4,t1,t2
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
add t1,t1,1
blt t1,t3,loop // end loop when t1 is 11
li t1,1
add t2,t2,1 

j loop

