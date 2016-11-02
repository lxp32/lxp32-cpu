.section .text
.global _start
_start:


li a2,0x0FA55AA55

la a1, trap_handler
csrw mtvec,a1 


loop:
li gp,0x200  // test result area
mv t4,a2
jal store
ecall 
mv t4,a2
jal store
ebreak
mv t4,a2
jal store

j loop




store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret

trap_handler:
csrr t4,mcause
jal store
csrr t4,mepc
jal store
sret
