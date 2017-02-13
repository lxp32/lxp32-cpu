.section .text
.global _start
_start:



la s0, monitor
li a0, -1 // preset a0 with failure

la t1, trap_failure
csrw mtvec,t1 

nop
nop
fence // should do nothing...

la a1, test_op
lw a2,0(a1) // get opcode at label testop

la a1,modify1
sw  a2,0(a1) // Write opcode 
nop // instead of fence...
modify1:
nop 


la t1, trap_success
csrw mtvec,t1 

la a1,modify2
sw  a2,0(a1) // Write opcode 
fence.i
modify2:
nop        

sw a0,0(s0) // write result to monitor result register 
self:
j self



trap_success:
li a0,1   // set a0 to success
csrr t1,mepc
addi t1,t1,4 // increment mepc
csrw mepc,t1
sret

trap_failure:
sw a0,0(s0) // write result to monitor result register 
f0:
j f0

test_op:
ecall  // Test Opcode to use


.align 8
result_area:

