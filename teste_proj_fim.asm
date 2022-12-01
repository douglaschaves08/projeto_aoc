.data
produtos:
	.space 12
	
quantidades:
	.space 12

ids:
	.space 12
	
.text
.globl main

main:
	li $t1, 2
	la $s2, produtos
vetor:
	beq $t0, $t1, printar

	move $a0, $s2
	li $a1, 12
	li $v0, 8
	syscall
	
	#la $a0, ($s2)
	#li $v0, 4
	#syscall
	
	addi $s2, $s2, 12
	addi $t0, $t0, 1
	j vetor
	
printar:
	la $s3, produtos
printar2:
	beq $t5, $t1, exit
	
	move $t3, $s3
	move $a0, $t3

	
	la $a0, ($s3)
	li $v0, 4
	syscall
	
	addi $s3, $s3, 12
	addi $t5, $t5, 1
	j printar2
	
exit: 
	li $v0, 10
	syscall
	
	
		

