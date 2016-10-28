.section .text
.global _start
_start:

li a1,0x100 // store area
li a2,0x0FA55AA55


loop:
li gp,0x200  // test result area

csrw mscratch,a2 // write a2 with mscratch
jal store // t4 should be 0 ...
csrr t4,mscratch// read mscratch
jal store // should be FA55AA55

j loop

store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret
