.section .text
.global _start
.extern monitor
_start:

li a0,10
la s0, monitor

loop:
addi a0,a0,-1
bnez a0, loop

sw a0,0(s0) // write  to monitor result register 
f0:
j f0 
