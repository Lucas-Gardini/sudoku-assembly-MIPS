# Sudoku 2x2
# Feito por:
# Lucas Gardini Dias
# Gabriel Luiz de Oliveira
# Thiago Aio

.data
bemVindo:     		.asciiz "Bem vindo ao jogo de sudoku!\n\nDigite somente numeros de 1 a 4 para completar as lacunas!\n\nAlem disso o numero digitado nao pode ser igual a qualquer outro numero de sua linha ou coluna!\n"
tabuleiro:		.word	0, 1, 4, 3, 3, 0, 2, 1, 1, 2, 0, 4, 4, 3, 1, 0
separador:		.asciiz " | "
separador_horizontal:	.asciiz "- - + - - \n"
separador_vertical:	.asciiz "\n\n\n"
mensagemEntrada:	.asciiz "Digite um numero para colocar na posicao do 'X'"
mensagemErro:		.asciiz "Erro ao processar o numero digitado, verifique o que voce digitou"
mensagemDerrota: 	.asciiz "Voce perdeu!"
mensagemVitoria:	.asciiz "Parabens! Voce ganhou!"

.text
.globl main

main: 
	li	$v0, 55 # syscall de dialogo (tela popup)
	la	$a0, bemVindo # mensagem que sera exibida
	li	$a1, 1
	syscall

	li	$t9, 0 # iniciando indice de espaÃ§o vazio
	li	$t3, 0 # 0 = nao substituir, 1 = substituir (flags internas)
	li	$t4, 0 # contador do manuseador de entradas
	jal	manusearEntradas	
	
	j	exit

manusearEntradas:
	la	$t5, tabuleiro # carregando tabuleiro para uso do bloco abaixo
	jal	proxCasaVazia

	li	$v0, 0
	la	$t1, tabuleiro

	# imprimindo um separador vertical para separar o tabuleiro
    	li      $v0, 4
    	la      $a0, separador_vertical
    	syscall

	jal 	imprimirTabuleiro
	
	li	$v0, 51 # syscall de dialogo de entrada (prompt popup)
	la	$a0, mensagemEntrada
	syscall 
	
	bgt 	$a0, 4, exit #Se $a0 maior que 4 = erro
	blt 	$a0, 1, exit #Se $a0 menor que 1 = erro
	
	# Verificando status retornado pelo prompt
	beq	$a1, 0, valorOk
	
	valorOk:
		add	$t4, $t4, 1 # Mais um ao contador
		li	$t3, 1 # Identificador de substituicao (flag interna)
		j	fimManusear
	
	fimManusear:
		bge     $t4, 5, fimDeJogo # Contador maior que 5, fim
		beq 	$t4, 1, verificaNum
		beq 	$t4, 2, verificaNum2
		beq	$t4, 3, verificaNum3
		beq	$t4, 4, verificaNum4

	continue:
		mul 	$t9, $t9, 4 # multiplicando o incide por 4 (array/memoria anda de 4 em 4 bytes)
		add 	$s0, $zero, $a0 # adicionando o valor inserido pelo usuario ao s0
		sw      $s0, tabuleiro($t9) # adicionando o endereco ao array na posicao $t8 ($t9 * 4)
		li	$t9, 0 # Resetando posicaoo da array para futuras insercoes
		
		move 	$t5, $a0
		
		j 	manusearEntradas # Loop

proxCasaVazia:
	bge 	$t9, 16, fimDeJogo # Contador maior que 16, fim

	# lendo o valor na posicao correspondente no $t5 
	# (carregado anteriormente com o endereco da array de tabuleiro)
	add	$t9, $t9, 1
	lw      $t6, 0($t5) 
    	addi    $t5, $t5, 4 # Array/memoria anda de 4 em 4 bytes
    	
    	beq	$t6, 0, achouCasaVazia # Encontrou 0 no array (0 = casa vazia)
    	
    	j	proxCasaVazia # Loop
    	
    	achouCasaVazia:
    		sub	$t9, $t9, 1
    		jr	$ra	

imprimirTabuleiro:	
	# caso o contador ultrapasse 16, saimos da funcao
	bge     $t0, 16, sair

    	# carregando palavra do endereco do array e incrementando para o proximo
    	lw      $t2, 0($t1)
    	addi    $t1, $t1, 4

	beq	$t0, 8, imprimirSeparadorHorizontal # caso o contador seja 8, imprimimos um 'pipe' -> |
	beq	$t0, $t9, imprimirX # imprime um "X" na casa selecionada pra insercao de numero
	beq 	$t2, 0,	imprimirNumeroVazio # imprimir espaco onde nao existe numero
	
	# Imprimindo caractere "X"
    	imprimirX:
    		bne 	$t2, 0, imprimirValor # caso ja tenha um valor nessa casa, nao imprimimos o X
    		li      $v0, 11  
    		li      $a0, 88 # "X"
    		syscall
    		j	imprimirNumeros

	# Imprimindo o valor contido na posicaoo do contador do array
	imprimirValor:
    		li      $v0, 1      
    		move    $a0, $t2
    		syscall
    		j	imprimirNumeros
    	
    	# Imprimindo um caractere de espaco em branco
    	imprimirNumeroVazio:
    		li      $v0, 11  
    		li      $a0, 32 # " "
    		syscall
    		j	imprimirNumeros
    	
    	# Logica de impressao dos numeros (casas, separadores)
    	imprimirNumeros:
    		beq	$t0, 1, imprimirSeparador # fim do bloco
    		beq	$t0, 3, imprimirNovaLinha # fim da linha
    		beq	$t0, 5, imprimirSeparador
    		beq	$t0, 7, imprimirNovaLinha
    		beq	$t0, 9, imprimirSeparador
    		beq	$t0, 11, imprimirNovaLinha
    		beq	$t0, 13, imprimirSeparador
    		beq	$t0, 15, imprimirNovaLinha
    		j	imprimirEspaco
    	
    	imprimirNovaLinha:
    		# imprimindo uma nova linha
    		li      $a0, 10 # "\n"
    		li      $v0, 11  
    		syscall
    		j	loopImprimirTabuleiro
    		
    	imprimirEspaco:
    		# imprimindo um espaco para separar os valores
    		li      $a0, 32 # " "
    		li      $v0, 11  
    		syscall	
    		j	loopImprimirTabuleiro
    	
    	imprimirSeparador:
    		# imprimindo um separador para separar os quadrados
    		la      $a0, separador
    		li      $v0, 4
    		syscall	
    		j	loopImprimirTabuleiro
    		
    	imprimirSeparadorHorizontal:
    		# imprimindo um separador horizontal para separar os quadrados
    		la      $a0, separador_horizontal
    		li      $v0, 4
    		syscall	
    		
    		# syscall para imprimir o valor
    		li      $v0, 1      
    		move    $a0, $t2
    		syscall
    		
    		j	imprimirEspaco
    		
    		j	loopImprimirTabuleiro
    	

	loopImprimirTabuleiro:
    		# incrementando contador (loop)
    		addi    $t0, $t0, 1
    		j      imprimirTabuleiro

	sair:
		li	$t0, 0
		jr	$ra

# Funcoes de verificacao da logica do sudoku

verificaNum:
	beq	$a0, 1, exit #verifica se o numero digitado eh igual a 1
	beq	$a0, 3, exit #verifica se o numero digitado eh igual a 3
	beq	$a0, 4, exit #verifica se o numero digitado eh igual a 4
	j	continue


verificaNum2:
	beq	$a0, 1, exit
	beq	$a0, 3, exit
	beq 	$a0, 2, exit
	j 	continue


verificaNum3:
	beq	$a0, 1, exit
	beq	$a0, 2, exit
	beq	$a0, 4, exit
	j 	continue
	
	
verificaNum4:
	beq	$a0, 1, exit
	beq	$a0, 3, exit
	beq	$a0, 4, exit
	j 	continue
	
	
fimDeJogo:
	# Imprimindo o tabuleiro no fim do jogo
	li	$v0, 0
	la	$t1, tabuleiro

    	li      $v0, 4
    	la      $a0, separador_vertical
    	syscall
    	
	jal 	imprimirTabuleiro
	
	# Caixa de popup com a mensagem de vitoria
	li 	$v0, 55
	la	$a0, mensagemVitoria
	la 	$a1, 3
	syscall
	
	# Chamada de fim do programa
	li 	$v0, 10
	syscall


exit:
	# Caixa de popup com a mensagem de derrota
	li 	$v0, 55
	la	$a0, mensagemDerrota
	syscall
	
	# Chamada de fim do programa
	li 	$v0, 10
	syscall
