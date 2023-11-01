.data
	outputText1: .asciiz "Number "
	outputText2: .asciiz " has "
	outputText3: .asciiz " leading zeros\n"
.text
.globl main

main:
	li $v0, 5
	syscall
	move $t1, $v0 # $t1 contains the actual number
	addi $t0, $zero, 0  #Number of shifts right
	addi $t2, $t1, 0  #Temporary storage for shifted number
	
	beq $t1,$zero, printOutput
loop:
	srl $t2, $t2, 1
	addi $t0, $t0, 1
	bnez $t2, loop
	j printOutput
printOutput:	
	li $v0, 4
	la $a0, outputText1
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, outputText2
	syscall
	
	addi $t4, $zero, 32 #t4 has number 32
	sub $t5, $t4, $t0  #t5 has the number of leading zeros
	
	li $v0, 1 
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, outputText3
	syscall
	
	li $v0, 10
	syscall
	
	
