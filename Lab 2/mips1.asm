.macro read_int
	li $v0, 5
	syscall
.end_macro

.macro print_int(%x)
	li $v0, 4
	la $a0, space
	syscall

	li $v0, 1
	move $a0, %x
	syscall
.end_macro

.data
	space: .asciiz " "
.text
.globl main
main:
    read_in1:
	read_int
	move $s4, $v0 #Read size in1
	blez $s4, read_in2 #Check if size is less than or equal to zero
	
	move $s1, $sp
	addi $s1, $s1, -4 # s1 has pointer t0 in1
			  #(This is done due to function read_array way of working)
	move $a0,$s4 #Passing size of array
	move $a1, $sp #Use pointer pointing at a position above the starting point of the
		      #array.
	jal read_array 

	move $s2, $v1 #Store the returning value
	move $sp, $v1 #Update $sp pointer
    read_in2:
	read_int
	move $s5, $v0
	blez $s5, end  #Check if size is less than or equal to zero

	move $a0,$s5   #Same as read_in1
	move $a1,$s2
	
	jal read_array
	move $sp, $v1
	
	addi $s2, $s2, -4 # s2 has pointer to in2
    
    end:
	addi $sp, $sp ,-4
	sw $sp, ($sp)
	addi $s6, $sp, 0

	move $a0,$s1 #Passing in1 pointer to a0
	move $a1,$s4 #Passing size of in1 (N) to a1
	move $a2,$s2 #Passing in2 pointer t0 a2
	move $a3,$s5 #Passing size of in2 (M) to a3
	jal merge
	
	add $s7, $s4, $s5 # $s7 has the out position
	beqz $s7, quit #Check if out is a NULL table
	move $a1, $s7
	move $a2, $s6
	
	jal print_array
    quit:	
	li $v0, 10
	syscall
	
print_array:
	lw $t9, ($a2)  
	print_int($t9)
	addi $t8, $t8, 1
	addi $a2, $a2, -4
	bne $t8, $a1, print_array
	jr $ra
read_array:
	#This function receives a pointer and a size
	#And starts to placing numbers one by one starting at (pointer - 4) position
	read_int
	addi $a1, $a1, -4
	sw $v0, ($a1)
	subi $a0, $a0 ,1
	bgt $a0, $0, read_array
	move $v1, $a1 #Function returns pointer to the last array element
	jr $ra
merge:
	add $t5, $a1, $a3
	lw $s3, ($sp)
	move $t0, $s3
	create_empty_array:
		addi $t0, $t0,-4
		addi $t5, $t5, -1
		bgtz $t5, create_empty_array
		move $sp, $t0
	loop1:
		beq $t2, $a1, loop2
		beq $t3, $a3, loop3
		lw $t0, ($a0)
		lw $t1, ($a2)
		ble $t0, $t1, case1
		#Both cases store the smaller number into the array and move
		#to the next number in their respective arrays while moving the pointer
		#from out function
		case2: 
			sw $t1, ($s3)
			addi $a2, $a2, -4
			addi $s3, $s3, -4
			addi $t3, $t3 ,1
			j loop1
		case1:
			sw $t0, ($s3)
			addi $a0, $a0, -4
			addi $s3, $s3, -4
			addi $t2, $t2 ,1
			j loop1
	#Those loops fills the rest of the "out" array
	#With the remaining numbers from the bigger array
	loop2:
		beqz $a3, exit_func #Check if table is NULL
		lw $t1, ($a2)
		sw $t1, ($s3)
		addi $s3, $s3, -4
		addi $a2, $a2, -4
		addi $t3, $t3, 1
		bne $t3, $a3, loop2
		j exit_func
	loop3:
		beqz $a1, exit_func
		lw $t0, ($a0)
		sw $t0, ($s3)
		addi $s3, $s3, -4
		addi $a0, $a0, -4
		addi $t2, $t2, 1
		bne $t2, $a1, loop3
		j exit_func
	exit_func:
		jr $ra
