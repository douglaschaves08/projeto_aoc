.data
#GARBIEL DATA
lf:	.asciiz	"\n"
msgBusc:	.asciiz	"Qual produto deseja buscar?\n"
msgQtd:	.asciiz	"QUANTIDADE: "
msgEscolhaBusca:	.asciiz	"\n\nEscolha a operacao desejada:\n"
msgOpBusca:	.asciiz "1 - AUMENTAR QUANTIDADE\n2 - REMOVER QUANTIDADE\n3 - VOLTAR AO MENU\n"
msgAumentar:	.asciiz "\nDigite a quantidade que deseja acrescentar: "
msgRemover:	.asciiz "\nDigite a quantidade que deseja remover: "
msgErroRemover:	.asciiz "\nQuantidade nao disponivel em estoque para ser removida\n"
ehigual:	.asciiz	"\nPRODUTO ENCONTRADO: "
ehdiferente:	.asciiz	"\nPRODUTO NAO ENCONTRADO"	
buscar:		
	.space	20 #Vetor para armazenar a palavra buscada
msg2:	.asciiz "\nEM ESTOQUE:\n"
hif:	.asciiz " - "

#DOUGLAS DATA
escolhaOperacao: .asciiz "\nQual operacao deseja fazer?\n1 - INSERIR PRODUTO\n2 - BUSCAR PRODUTO\n3 - VISUALIZAR ESTOQUE\n"
insercaoTipo: .asciiz "\nQue tipo de produto sera inserido?\n1 - NOVO PRODUTO\n2 - PRODUTO EXISTENTE\n"
mensagemInsercao1: .asciiz "Insira o nome do produto: "
mensagemInsercao2: .asciiz "Insira a quantidade do produto: "

#GENERAL DATA
estoque:
	.align 2
	.space 200 #10 posicoes no estoque, strings

produto:
	.space 20 #12 bytes por palavra (string) 
	
quantidades:
	.space 40 #10 posicoes para quantidade, inteiros

ids:
	.space 40 #10 posicoes para ids, inteiros
	
.text
.globl main
main:
#REGISTRADORES RESERVADOS
li $t7, 0	#QTY - contador da posicao das quantidades
li $t8, 0	#NOVO - para ler as os produtos - inicio
li $t9, 20	#NOVO - para ler as os produtos - fim


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
	
novo:
	#Insira o nome do produto:
	la $a0, mensagemInsercao1 
	li $v0, 4
	syscall
	
	#LEITURA DO PRODUTO
	li $v0, 8
	la $a0, produto
	la $a1, 19
	syscall
	
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
	
	addi $t7, $t7, 4 #atualiza o registrador para o proximo produto
	
	j operacao #retorna para mais uma operacao

remocao:
	j busca

busca:
    # get first string
    la      $s2,buscar
    move    $t2,$s2
    jal     getstr

    # get second string
    la      $s3,estoque
    move    $t2,$s3

    # contador da diferenca
    li $t0, 0	#contador de string
    li $t1, 200 #fim do nextString
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
	addi $t0, $t0, 20
	beq $t0, $t1, diferente
	
	la      $s2,buscar	#reset index of buscar
	sub $t5, $t6, $t4	#pega a diferenca para o fim da string
	add $s3, $s3, $t5	#vai para proxima palavra
	addi $a3, $a3, 4	#proxima posicao em quantidades
	
	j cmploop
igual:
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
	#Escolha a operacao desejada: 
	li $v0, 4
	la $a0, msgEscolhaBusca
	syscall
	
	#1 - AUMENTAR QUANTIDADE\n2 - REMOVER QUANTIDADE\n3 - VOLTAR AO MENU
	li $v0, 4
	la $a0, msgOpBusca
	syscall
	
	#INPUT USUARIO - OP SELECTIONADA BUSCA
	li $v0, 5
	syscall
	move $t0, $v0
	
	li $t1, 1	#AUMENTAR
	li $t2, 2	#REMOVER
	li $t3, 3	#VOLTAR MENU 
	
	#BRANCH PARA OP SELECIONADA
	beq $t0, $t1, aumentarQtd
	beq $t0, $t2, removerQtd
	beq $t0, $t3, operacao
	j operacao

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
	
	j selectBusca
	
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

	j selectBusca

erroRemover:
	li $v0, 4
	la $a0, msgErroRemover
	syscall
	
	j removerQtd
diferente:
	li $v0, 4
	la $a0, ehdiferente
	syscall
	
	j operacao
visualizacao:
	#EM ESTOQUE:\n
	li $v0, 4
	la $a0, msg2
	syscall
	
	li $t0, 0	#contador do loop
	li $t1, 200	#condicao de parada do loop
	li $t2, 0	#contador das quantidades
	loop: 
		beq, $t1, $t0, endloop
		
		#PRINT DA QUANTIDADE
		lw $t3, quantidades($t2)
		
		beq $t3, $zero, pula #nao mostra se a qtd for 0
		
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
		addi $t0, $t0, 20
		
		j loop
		
	endloop:
		j operacao
