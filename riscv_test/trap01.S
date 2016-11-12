.section .text
.global _start
_start:


li a2,0x0FA55AA55

la a1, trap_handler
csrw mtvec,a1 


loop:
la gp,result_area  // test result area
mv t4,a2 // Start pattern
jal store
csrr t4,mimpid
jal store

ecall 
mv t4,a2
jal store
ebreak
mv t4,a2
jal store
mulh t4,x0,x0 // not implemented should trap
jal store

j loop




store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret

trap_handler:
csrr t4,mcause
mv t5,t4
jal store
csrr t4,mepc
jal store
addi t5,t5,-2 // check if mcause =2 (illegal opcode
bnez t5,return
addi t4,t4,4 // if yes increment mepc
csrw mepc,t4
return:
sret

.align 8
result_area:

