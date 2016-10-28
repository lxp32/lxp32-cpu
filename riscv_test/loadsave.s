# 1 "loadsave.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "loadsave.S"
.section .text
.global _start
_start:

li a1,0x100
li a2,0x0FA55AA55


loop:
li gp,0x200
sw a2, 0(a1)
lw t4, 0(a1)
jal store
sb a2, 8(a1)
sb a2, 9(a1)
lw t4,8(a1)
jal store
lbu t4, 1(a1)
jal store
lb t4,1(a1)
jal store
lbu t4,0(a1)
jal store
lb t4,0(a1)
jal store
sh a2,12(a1)
srli t1,a2,16
sh t1,14(a1)

lw t4,12(a1)
jal store

lhu t4,14(a1)
jal store
lh t4,14(a1)
jal store
lhu t4,12(a1)
jal store
lh t4,12(a1)
jal store

sh t1,17(a1)
lw t4,16(a1)
jal store
lhu t4,1(a1)
jal store

j loop

store:
sw t4,0(gp)
add gp,gp,4
ret
