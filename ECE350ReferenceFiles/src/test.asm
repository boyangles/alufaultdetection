.text
main:
add $r0,$r0,$r0
addi $r1,$r0,3
addi $r3,$r0,4
addi $r4,$r0,5
sw $r3,1($r0)
addi $r18,$r0,32767
addi $r12,$r0,32767
mul $r11,$r12,$r18
mul $r11,$r11,$r12
bex 3
addi $r1,$r3,5000
addi $r2,$r0,65
addi $r15,$r2,300
lw $r17,1($r0)
add $r4,$r0,$r17
div $r17,$r3,$r1
div $r12,$r3,$r0
bex 2
add $r1,$r1,$r1
add $r1,$r1,$r1
add $r1,$r1,$r1
add $r1,$r1,$r1
add $r1,$r1,$r1
j quit
quit:
halt
.data
wow: .word 0x0000B504
mystring: .string ASDASDASDASDASDASD
var: .char Z
label: .char A
heapsize: .word 0x00000000
myheap: .word 0x00000000