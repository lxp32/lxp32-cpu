.section text
.global _start
_start:

addi x1,x0,1
ori x1,x1,8
loop:
addi x1,x1,1
j loop
