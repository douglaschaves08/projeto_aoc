.data
produtos:
	.space 12
	
quantidades:
	.space 12

ids:
	.space 12
vetor: 
	.space 12

# oi

	#VETOR DE PRODUTOS  	- $t0
	#VETOR DE ID		- $t1
	#VETOR DE QUANTIDADE	- $t2
.text
.globl main
main:
	#ZERAR OS REGISTRADORES NO COME�O DO CODIGO
	
	#INTERFACE USUARIO
		# 1 - PRINT ESTOQUE
		# 2 - INSERIR
		# 3 - REMOVER
		# 0 - SAIR
	
	#OPERA��O DE INSER��O
		#INSERIR SEM COMPARAR SE J� 
		#ID: [INDEX]+1
	
	#OPERA��O DE REMO��O
		#ID * 4 - 4 
	#PRINT DO ESTOQUE (MOSTRAR O ESTOQUE) 
		# ID - PRODUTO - QTD

