.section .text
.global _start
_start:

li x2,0x100
li x1,25
sw x1,0(x2)

li x1,0x0555
slli x1,x1,1
sw x1,4(x2) // should contain 0xAAA
lb x3,4(x2) // x3 should by sign extended AA -> 0x0ffffffAA
sw x3,12(x2) // store it 

srli x1,x1,1
sw x1,12(x2) // should contain 0x555
srli x4,x3,4  // x4 should contain 0x0fffffffA
sw x4,16(x2)  // store it
li x5,4 
sra x6,x3,x5 // same as above
sw x6,20(x2) 


li x3,1
loop:
lw x1,0(x2)
add x1,x1,x3
sw x1, 0(x2)
j loop

