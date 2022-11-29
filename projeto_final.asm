.data
produtos:
	.space 12
	
quantidades:
	.space 12

ids:
	.space 12
vetor: 
	.space 12

	#VETOR DE PRODUTOS  	- $t0
	#VETOR DE ID		- $t1
	#VETOR DE QUANTIDADE	- $t2
.text
.globl main
main:
	#ZERAR OS REGISTRADORES NO COMEÇO DO CODIGO
	
	#INTERFACE USUARIO
		# 1 - PRINT ESTOQUE
		# 2 - INSERIR
		# 3 - REMOVER
		# 0 - SAIR
	
	#OPERAÇÃO DE INSERÇÃO
		#INSERIR SEM COMPARAR SE JÁ 
		#ID: [INDEX]+1
	
	#OPERAÇÃO DE REMOÇÃO
		#ID * 4 - 4 
	#PRINT DO ESTOQUE (MOSTRAR O ESTOQUE) 
		# ID - PRODUTO - QTD

