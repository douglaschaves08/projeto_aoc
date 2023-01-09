.data
escolhaOperacao: .asciiz "Qual operacao deseja fazer?\nPara insercao digite 1\nPara remocao digite 2\nPara visualizacao digite 3\nPara encerrar a consulta digite 4\n"
insercaoTipo: .asciiz "Que tipo de produto sera inserido?\nNovo produto digite 1\nProduto ja existente digite 2\n"
mensagemInsercao1: .asciiz "Insira o nome do produto: "
mensagemInsercao2: .asciiz "Insira a quantidade do produto: "
pulaLinha: .asciiz "\n"
produtos:
	.space 12
quantidades:
	.space 12
ids:
	.space 12
	
# oi

	#VETOR DE PRODUTOS  	- $t0
	#VETOR DE ID		- $t1
	#VETOR DE QUANTIDADE	- $t2
	
.text
.globl main
main:

operacao:
	li $t0, 1 
	li $t1, 2
	li $t2, 3
	li $t3, 4

	la $a0, escolhaOperacao #mostra as opcoes de operacoes a serem feitas: insercao, remocao ou visualizacao do estoque
	li $v0, 4
	syscall
	
	li $v0, 5 #escolhe a operacao
	syscall
	move $t4, $v0
	
	beq $t4, $t0, insercao #desvia para a operacao escolhida
	beq $t4, $t1, remocao
	beq $t4, $t2, visualizacao
	beq $t4, $t3, fim
	
	#ZERAR OS REGISTRADORES NO COMECO DO CODIGO
	
	#INTERFACE USUARIO
		# 1 - PRINT ESTOQUE
		# 2 - INSERIR
		# 3 - REMOVER
		# 0 - SAIR
	
	#OPERACAO DE INSERCAO
		#INSERIR SEM COMPARAR SE J� 
		#ID: [INDEX]+1
		
insercao:
	li $t0, 1
	li $t1, 2
	
	la $a0, insercaoTipo #mostra as opcoes de insercoes a serem feitas: novo ou ja existente
	li $v0, 4
	syscall
	
	li $v0, 5 #escolhe a insercao
	syscall
	move $t4, $v0
	
	beq $t4, $t0, novo #desvia para o tipo escolhido
	beq $t4, $t1, existente
	
novo:
	la $a0, mensagemInsercao1 #pede o nome do produto
	li $v0, 4
	syscall
	
	la $s2, produtos 
	move $t2, $s2
	move $a0, $t2
	
	li $a1, 12 #nome do produto
	li $v0, 8
	syscall
	
	la $a0, mensagemInsercao2 #pede a quantidade de produto
	li $v0, 4
	syscall
	
	la $s3, quantidades
	move $t3, $s3
	move $a0, $t3
	
	li $v0, 5 #quantidade do produto
	syscall
	move $t3, $v0
	
	li $v0, 4 #teste de impressao do nome do produto
	la $a0, produtos
	syscall
	
	lw $t7, quantidades($zero)
	
	li $v0, 1 #teste de impressao da quantidade do produto
	move $a0, $t7
	syscall
	 
	li $v0, 4
	la $a0, pulaLinha
	syscall
	
	j operacao #retorna para mais uma operacao

existente: 
	la $a0, mensagemInsercao1 #pede o nome do produto
	li $v0, 4
	syscall
	
	li $a1, 12 #nome do produto
	li $v0, 8
	syscall

	la $a0, mensagemInsercao2 #pede a quantidade de produto
	li $v0, 4
	syscall
	
	li $v0, 5 #quantidade do produto
	syscall
	move $t3, $v0
	
	#addi $s2, $s2, 12 --------TESTES PARA PRINT-----------
	#move $t3, $s2
	#move $a0, $t3
	#li $a1, 12
	#li $v0, 8
	#syscall
	
	#li $v0, 4
	#syscall
	
	#OPERACAO DE REMOCAO
		#ID * 4 - 4 
		
remocao:

	#PRINT DO ESTOQUE (MOSTRAR O ESTOQUE) 
visualizacao:
		# ID - PRODUTO - QTD
		
fim: 
	li $v0, 10
	syscall

