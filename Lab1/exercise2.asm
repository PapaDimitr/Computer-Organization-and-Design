.data
    inputPrompt1: .asciiz "Please give N1: "
    inputPrompt2: .asciiz "Please give N2: "
    outputText1: .asciiz "The max final union of ranges is ["
    outputText2: .asciiz ","
    outputText3: .asciiz "].\n"
.text

main:
        add $s0, $0, $0 # $s0 has N1' value
        add $s1, $0, $0 # $s1 has N2' value
        sub $s3, $0, $0 # $s3 is the distance between two numbers
loop:
        li $v0, 4
        la $a0, inputPrompt1
        syscall

        li $v0, 5
        syscall
        blt $v0, $0, quit
        move $t0, $v0

        li $v0, 4
        la $a0, inputPrompt2
        syscall

        li $v0, 5
        syscall
        blt $v0, $0, quit
        move $t1, $v0

        bge $t0, $s0, case1 #Ελέγχουμαι αν Ν1 > Ν1'
        blt $t0, $s0, case2 #Ελέγχουμαι αν Ν2 > Ν2'
        
        # t0 εχει την τιμή του Ν1
        # t1 εχει την τιμή του N2
        # t3 εχει την διαφορα Ν2-Ν1
case1:
        bgt $t0, $s1, subcase1_1 #Ελέγχουμαι αν Ν1 > Ν2'
        bgt $t1, $s1, subcase1_2 #Ελέγχουμαι αν Ν2 > Ν2'
        ble $t1, $s1, subcase1_3 #Ελέγχουμαι αν Ν2 <= Ν2'
subcase1_1:
        sub $t3, $t1, $t0  
        ble $t3, $s3, loop
        move $s0, $t0
        move $s1, $t1       
        move $s3, $t3
        j loop
subcase1_2:
        move $s1, $t1
        j loop
subcase1_3:
        j loop
case2:
	blt $t1, $s0, subcase2_1 #Ελέγχουμαι αν Ν1 < Ν2'
        blt $t1, $s1, subcase2_2 #Ελέγχουμαι αν Ν2 < Ν2'
        bgt $t1, $s1, subcase2_3 #Ελέγχουμαι αν Ν2 > Ν2'
subcase2_1:
	sub $t3, $t1, $t0
        ble $t3, $s3, loop
        move $s0, $t0
        move $s1, $t1  
        move $s3, $t3  
        j loop
subcase2_2:
        move $s0, $t0
        j loop
subcase2_3:
        move $s0, $t0
        move $s1, $t1
        j loop
quit:
        li $v0, 4
        la $a0, outputText1
        syscall
        
        li $v0, 1
        add $a0, $0 ,$s0
        syscall
        
        li $v0, 4
        la $a0, outputText2
        syscall
        
        li $v0, 1
        add $a0, $0 ,$s1
        syscall
        
        li $v0, 4
        la $a0, outputText3
        syscall
        
        li $v0, 10
        syscall
