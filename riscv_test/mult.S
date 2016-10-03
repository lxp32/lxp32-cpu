.section .text
.global _start
_start:


li gp,0x0100 // memory pointer

// High Multiplication


// Multiply 5.000.000 * 5.000.000
// result is 16bc c41e9000
li a1, 5000000  // unsgined maxint 
mul t4,a1,a1 // c41e9000
jal store 
mulh t4,a1,a1 // 16bc
jal store 

// First test div operation

li a1,35
li a2,5
divu t4,a1,a2 // 35 div 5
jal store

remu t4,a1,a2 // 35 mod 5
jal store

li a2,3
remu t4,a1,a2 // 35 mod 3
jal store

li a1, -35
li a2, 5
div t4,a1,a2 // -35 div 5
jal store
divu t4,a1,a2 // should be something different...
jal store

li a2,-3
rem t4,a1,a2 // -35 mod -3 = -2 
jal store
remu t4,a1,a2
jal store

mv s1,gp // save memory ptr
li a1,1
li a2,2
li a3,11

// Test loop with the "1*1" from 2 to 10 
loop:
mul t4,a1,a2
jal store
add a1,a1,1
blt a1,a3,loop // end loop when t1 is 11
li a1,1
add a2,a2,1 
blt a2,a3,loop 
li a2,2
mv gp,s1 // restore pointer 
j loop

store: // store t4 to mem and increment
sw t4,0(gp) // save result
add gp,gp,4 // increment pointer
ret


