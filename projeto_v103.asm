.data
lf:	.asciiz	"\n"
msgBusca:	.asciiz	"Digite o nome do produto buscado:  "
msgQtd:	.asciiz	"QUANTIDADE: "
msgEscolhaBusca:	.asciiz	"\n\nEscolha a operacao desejada:\n1 - AUMENTAR QUANTIDADE\n2 - REMOVER QUANTIDADE\n3 - REMOVER PRODUTO\n"
msgAumentar:	.asciiz "\nDigite a quantidade que deseja acrescentar: "
msgRemover:	.asciiz "\nDigite a quantidade que deseja remover: "
msgErroRemover:	.asciiz "\nQuantidade nao disponivel em estoque para ser removida\n"
msgErroOp:	.asciiz "\nDIGITE UMA OPERACAO VALIDA\n"
msgCheio:	.asciiz "\nNAO FOI POSSIVEL INSERIR. ESTOQUE CHEIO.\n"
ehigual:	.asciiz	"\nPRODUTO ENCONTRADO: "
ehdiferente:	.asciiz	"\nPRODUTO NAO ENCONTRADO\n"	
msg2:	.asciiz "\nEM ESTOQUE:\n"
msg3:	.asciiz " ID   -   QTD  -   PRODUTO\n"
hif:	.asciiz "  -    "
escolhaOperacao: .asciiz "\nQual operacao deseja fazer?\n1 - INSERIR PRODUTO\n2 - BUSCAR PRODUTO\n3 - VISUALIZAR ESTOQUE\n"
mensagemInsercao1: .asciiz "Insira o nome do produto: "
mensagemInsercao2: .asciiz "Insira a quantidade do produto: "
msgIgual2:	.asciiz "\nPRODUTO JA EXISTE EM ESTOQUE. DESEJA ALTERAR A QUANTIDADE?\n1 - SIM\n2 - NAO\n"

estoque:
	.align 2
	.space 2000 #10 posicoes no estoque, strings

produto:
	.space 20 #12 bytes por palavra (string) 
	
quantidades:
	.space 400#10 posicoes para quantidade, inteiros

ids:
	.space 400#10 posicoes para ids, inteiros

buscar:		
	.space	20 #Vetor para armazenar a palavra buscada
	
.text
.globl main
main:
#REGISTRADORES RESERVADOS
li $t7, 0	#QTY - contador da posicao das quantidades
li $t8, 0	#NOVO - para ler as os produtos - inicio
li $t9, 20	#NOVO - para ler as os produtos - fim
li $k0, 1001	#Primeiro ID
li $k1, 0	#Contador para quantidade de produtos
li $s1, 1	#Marcador para busca2

carregaIds:
	li $t0, 0
	li $t1, 400
	loopIds:
		beq $t0, $t1, operacao
		sw $zero, ids($t0)
		addi $t0, $t0, 4
		j loopIds
operacao:
	li $t0, 1 #INSERIR
	li $t1, 2 #BUSCAR
	li $t2, 3 #VISUALIZAR
	
	#Qual operacao deseja fazer?\n1 - INSERIR PRODUTO\n2 - BUSCAR PRODUTO\n3 - VISUALIZAR ESTOQUE\n
	la $a0, escolhaOperacao 
	li $v0, 4
	syscall
	
	#INPUT USUARIO - ESCOLHE A OPERACAO (1,2 OU 3)
	li $v0, 5
	syscall
	move $t4, $v0
	
	#FAZ O BRANCH PARA OP ESCOLHIDA
	beq $t4, $t0, novo
	beq $t4, $t1, remocao
	beq $t4, $t2, visualizacao
	
	#MENSAGEM DE ERRO - OPCAO INVALIDA
	la $a0, msgErroOp
	li $v0, 4
	syscall
	
	j operacao
	
novo:
	#VERIFICA SE O ESTOQUE ESTA CHEIO
	li $t0, 10	# 10 posicoes no estoque
	beq $t0, $k1, cheio
	addi $k1, $k1, 1
	
	#Insira o nome do produto:
	la $a0, mensagemInsercao1 
	li $v0, 4
	syscall
	
	#LEITURA DO PRODUTO
	li $v0, 8
	la $a0, produto
	la $a1, 19
	syscall
	
	#VERIFICA SE O PRODUTO JA EXISTE EM ESTOQUE
	li $s1, 0 #Ativa busca 2
	beq $s1, $zero, busca2

novo2:	
	#PASSANDO O PRODUTO PARA ESTOQUE
	li $t0, 0 	#Contador
	
	loopEstoque:
		beq $t8, $t9, updateReg
		lw $s0, produto($t0)
		sw $s0, estoque($t8)
		addi $t0, $t0, 4
		addi $t8, $t8, 4
		j loopEstoque
updateReg:
	addi $t9,$t9, 20
qty:		
	#Insira a quantidade do produto:
	la $a0, mensagemInsercao2
	li $v0, 4
	syscall
	
	#INPUT USUARIO - QUANTIDADE DO PRODUTO
	li $v0, 5
	syscall
	move $t3, $v0
	
	sw $t3, quantidades($t7) #armazena a quantidade na ordem correspondente 

id:
	sw $k0, ids($t7)
	addi $k0, $k0, 1
	
	addi $t7, $t7, 4 #atualiza o registrador para o proximo produto

	j operacao #retorna para mais uma operacao

remocao:
	j busca

busca:
    #Qual produto deseja buscar? 
    li $v0, 4
    la $a0, msgBusca
    syscall
    
    # get first string
    la      $s2,buscar
    move    $t2,$s2
    jal     getstr

    # get second string
    la      $s3,estoque
    move    $t2,$s3
    j buscaReg

busca2:
    # get first string
    la      $s2,produto
    move    $t2,$s2

    # get second string
    la      $s3,estoque
    move    $t2,$s3
 
buscaReg:
    # contador da diferenca
    li $t0, 0	#contador de string
    li $t1, 2000 #fim do nextString
    li $t4, 0	#contador caracter
    li $t5, 0	#recebe a diferenca
    li $t6, 20	#referencia tamanho palavra
    li $a3, 0	#contador para 'quantidades'
    
# string compare loop (just like strcmp)
cmploop:
    lb      $t2,($s2)                   # get next char from buscar
    lb      $t3,($s3)                   # get next char from estoque
    bne     $t2,$t3,nextString          # are they different? if yes, next string

    beq     $t2,$zero,igual             # at EOS? yes, fly (strings equal)

    addi    $s2,$s2,1                   # point to next char
    addi    $s3,$s3,1                   # point to next char
    addi    $t4, $t4, 1
    j       cmploop

getstr:
    # read in the string
    move    $a0,$t2
    li      $a1,19
    li      $v0,8
    syscall

    jr      $ra                         # return

nextString:
	beq $s1, $zero, nextString2
	addi $t0, $t0, 20
	beq $t0, $t1, diferente
	
	la      $s2,buscar	#reset index of buscar
	sub $t5, $t6, $t4	#pega a diferenca para o fim da string
	add $s3, $s3, $t5	#vai para proxima palavra
	addi $a3, $a3, 4	#proxima posicao em quantidades
	
	j cmploop

nextString2:
	addi $t0, $t0, 20
	beq $t0, $t1, diferente
	
	la      $s2,produto	#reset index of produto
	sub $t5, $t6, $t4	#pega a diferenca para o fim da string
	add $s3, $s3, $t5	#vai para proxima palavra
	addi $a3, $a3, 4	#proxima posicao em quantidades
	
	j cmploop
igual:
	beq $s1, $zero, igual2
	#PRODUTO ENCONTRADO:
	li $v0, 4
	la $a0, ehigual
	syscall
	
	#PRINT NOME DO PRODUTO ENCONTRADO
	li $v0, 4
	la $a0, buscar
	syscall
	
	#QUANTIDADE: 
	li $v0, 4
	la $a0, msgQtd
	syscall
	
	#PRINT DA QUANTIDADE
	lw $t0, quantidades($a3)
	li $v0, 1
	move $a0, $t0
	syscall
	
#SEGUNDO PAINEL DE SELECAO - BUSCA
selectBusca:
	#Escolha a operacao desejada:\n1 - AUMENTAR QUANTIDADE\n2 - REMOVER QUANTIDADE\n3 - REMOVER PRODUTO
	li $v0, 4
	la $a0, msgEscolhaBusca
	syscall

	#INPUT USUARIO - OP SELECTIONADA BUSCA
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $t1, 1	#AUMENTAR
	li $t2, 2	#REMOVER
	li $t3, 3	#REMOVER PRODUTO
	
	#BRANCH PARA OP SELECIONADA
	beq $t0, $t1, aumentarQtd
	beq $t0, $t2, removerQtd
	beq $t0, $t3, removerProduto
	
	#DIGITOU OUTRA OPCAO
	li $v0, 4
	la $a0, msgErroOp
	syscall
	
	j selectBusca

aumentarQtd:
	#Digite a quantidade que deseja acrescentar:
	li $v0, 4
	la $a0, msgAumentar
	syscall
	
	#INPUT USUARIO - QTD  AUMENTAR
	li $v0, 5
	syscall
	move $t0, $v0
	
	lw $t1, quantidades($a3)
	add $t2, $t0, $t1
	sw $t2, quantidades($a3)
	
	j operacao
	
removerQtd:
	#Digite a quantidade que deseja remover:
	li $v0, 4
	la $a0, msgRemover
	syscall
	
	#INPUT USUARIO - QTD  REMOVER
	li $v0, 5
	syscall
	move $t0, $v0
	
	lw $t1, quantidades($a3)
	
	bgt $t0, $t1, erroRemover
	
	sub $t2, $t1, $t0
	sw $t2, quantidades($a3)

	j operacao

erroRemover:
	li $v0, 4
	la $a0, msgErroRemover
	syscall
	
	j removerQtd
diferente:
	beq $s1, $zero, diferente2
	li $v0, 4
	la $a0, ehdiferente
	syscall
	
	j operacao

diferente2:
	li $s1, 1 #Desativa busca 2
	j novo2

igual2:
	li $s1, 1 #Desativa busca 2
	#PRODUTO JA EXISTE EM ESTOQUE. DESEJA ALTERAR A QUANTIDADE?\n1 - SIM\n2 - NAO
	li $v0, 4
	la $a0, msgIgual2
	syscall
	
	#INPUT USUARIO - SELECT OP
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $t1, 1 #SIM
	li $t2, 2 #NAO
	
	beq $t0, $t1, selectBusca
	beq $t0, $t2, operacao
	
	li $v0, 4
	la $a0, msgErroOp
	syscall
	
	j igual2
visualizacao:
	#EM ESTOQUE:\n
	li $v0, 4
	la $a0, msg2
	syscall
	
	#ID - QUANTIDADE - PRODUTO
	li $v0, 4
	la $a0, msg3
	syscall
	
	li $t0, 0	#contador do loop
	li $t1, 2000	#condicao de parada do loop
	li $t2, 0	#contador das quantidades
	li $t4, 0	#contador dos IDS
	loop: 
		beq, $t1, $t0, endloop
		
		#PRINT IDS
		lw $t3, ids($t4)
		li $t5, 1000
		blt $t3, $t5, pula #nao mostra se a id for 0
		
		li $v0, 1
		move $a0, $t3
		syscall
		addi $t4, $t4, 4
		
		#SEPARADOR
		li $v0, 4
		la $a0, hif
		syscall 
		
		#PRINT DA QUANTIDADE
		lw $t3, quantidades($t2)
		
		li $v0, 1
		move $a0, $t3
		syscall
		addi $t2, $t2, 4
		
		#SEPARADOR
		li $v0, 4
		la $a0, hif
		syscall 
		
		#PRINT DO PRODUTO
		li $v0, 4
		la $a0, estoque($t0)
		syscall 
		addi $t0, $t0, 20
		
		j loop
	pula:
		addi $t2, $t2, 4
		addi $t4, $t4, 4
		addi $t0, $t0, 20

		j loop
		
	endloop:
		j operacao

cheio:
	li $v0, 4
	la $a0, msgCheio
	syscall
	
	j operacao

removerProduto:
	li $t0, 1
	sub $k1, $k1, $t0
	sw $t0, ids($a3)
	j operacao