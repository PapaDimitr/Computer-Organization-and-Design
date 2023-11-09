.macro read_int 
	li $v0, 5
	syscall
.end_macro
.macro print_int(%x)
	li $v0, 1
	move $a0, %x
	syscall
.end_macro
.macro read_32bits
	#We read 32bits byte by byte to avoid memory alignment errors from 
	#the assembler by loading them as a word into a register
	lbu $t0, ($s6) #Collect 1 byte and shift it to the furthest upper position 
	sll $t0, $t0, 24 
	lbu $t1, 1($s6)
	sll $t1, $t1, 16 #Repeat step 1 but for another position
	lbu $t2, 2($s6)
	sll $t2, $t2, 8
	lbu $t3, 3($s6)
	or $t4, $t1, $t0 #Add up all the bits in a 32 bit register by logical-or
	or $t5, $t2, $t3
	or $t6, $t5, $t4
	move $s4, $t6 # $s4 will hold the 32 bits 
.end_macro
.data
	array: .byte 0x70,0x8C,0xF3,0x82,0x1B,0x9D,0x52,0x3C,0x46
.text
.globl main
main:
	read_int
	move $s0,$v0 # s0 has pointer
	
	read_int
	move $s1,$v0 # s1 has offset
	
	read_int
	move $s2,$v0 # s2 has nbits
	
	move $a0,$s0 # $a0 holds the pointer
	move $a1,$s1# $a1 holds the offset
	move $a2,$s2# $a2 holds the nbits
	
	jal bits_read
	
	move $s3, $v1
	
	addi $t0, $0, 0x80000000 #Set mask
	addi $t1, $0, 0 #Numbers of shifts
	addi $t2, $0, 31
print:
	#Implementing a mask to isolate and print the designated bits
	beq $t1, 32, quit
	and $t4, $s3, $t0 
	sub $t3, $t2, $t1
	srlv $t4, $t4, $t3  # Shift result to least valued-bit
	print_int($t4)
	srl $t0, $t0, 1 #Shift mask
	addi $t1, $t1, 1
	j print
quit:
	li $v0, 10
	syscall
bits_read:
	#Reading bytes from array and selecting the correct case 
	la $s6, array 
	add $s6, $s6, $a0
	beqz $s2, print
	read_32bits
	add $t0, $a1, $a2 # $t0 has the sum of offset an nbits
	ble $t0, 32, case1
	bgt $t0, 32, case2
	jr $ra
case1:
	addi $t3, $0, 32  
	sub $t1, $t3, $t0 
	sllv $s4, $s4, $a1 #Shift $s4 left by offset bytes to eliminate unwanted bytes
	srlv $s4, $s4, $a1 #Shift back right by offset 
	srlv $s4, $s4, $t1 #Shift again right by [32-nbits] to the correct position
	move $v1,$s4
	jr $ra
case2:
	lbu $s5, 4($s6) #s5 contains bits out of the 32-bit collection area
	addi $t3, $0, 32
	addi $t4, $0, 8
	sub $t1, $t0, $t3 
	sub $t1, $t4, $t1 #t1 has the number of shifts for the outside bits
	sub $t2, $t3, $a2 #t2 has the space between existing bits and t1 bits that will be inserted in the register
	srlv $s5, $s5, $t1 #Shift $s5 by [8-(offset+nbits-32)] = [40 - offset - nbits] = $t1
	sllv $s4, $s4, $a1 #Shift $s4 by offset
	srlv $s4, $s4, $t2 #Shift $s4 by [32-nbits]
	or $s4, $s4, $s5
	move $v1,$s4
	jr $ra