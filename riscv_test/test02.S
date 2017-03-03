.section .text
.global _start
_start:

li x2,0x100
li x1,25
sw x1,0(x2)

loop:
lw x1,0(x2)
addi x1,x1,1
sw x1, 0(x2)
sw x1, 4(x2)
j loop

