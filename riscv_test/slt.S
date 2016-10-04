.section .text
.global _start
_start:


li gp,0x0100 // memory pointer



// Test loop with the "1*1" from 2 to 10 
loop:
mv s1,gp // save pointer

li a1, -5
li a2, 2
mul t4,a1,a2 // Pipeline test
mulh t5,a1,a2 
nop
slt t4,a1,a2 // true
sltu x0,a1,a2 // Pipeline  test
nop 
jal store
slt t4,a2,a1 // false
jal store

sltu t4,a1,a2 // false
jal store
sltu t4,a2,a1 // true
jal store

slti a4,a1,-5 // false
jal store
slti a4,a2,3 // true
jal store

mv gp,s1 // restore pointer 
j loop

store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret

