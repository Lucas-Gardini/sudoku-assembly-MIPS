.data
bemVindo:     		.asciiz "Bem vindo ao jogo de sudoku!"
tabuleiro:		.word	1, 3, 8, 5, 0, 2, 0, 0, 0, 0, 0, 0, 6, 0, 0, 8, 7, 1, 2, 0, 0, 6, 0, 0, 0, 0, 7, 0, 4, 3, 0, 0, 3, 0, 8, 7
separador:		.asciiz " | "
separador_horizontal:	.asciiz "- - - + - - -\n"
separador_vertical:	.asciiz "\n\n\n"
mensagemEntrada:	.asciiz "Digite um número para colocar na posição do 'X' ou selecione cancelar para ir para a próxima casa"
mensagemErro:		.asciiz "Erro ao processar o numero digitado, verifique o que você digitou"


.text
.globl main

main: 
	li	$v0, 55 # syscall de diálogo (tela popup)
	la	$a0, bemVindo # mensagem que será exibida
	li	$a1, 1
	syscall

	li	$t9, 0 # iniciando índice de espaço vazio
	li	$t3, 0 # 0 = não substituir, 1 = substituir
	li	$t4, 0 # contador do manuseador de entradas
	jal	manusearEntradas	
	
	j	exit

manusearEntradas:
	la	$t5, tabuleiro
	jal	proxCasaVazia

	li	$v0, 0
	la	$t1, tabuleiro

	# imprimindo um separador vertical para separar o tabuleiro
    	li      $v0, 4
    	la      $a0, separador_vertical
    	syscall

	jal 	imprimirTabuleiro
	
	li	$v0, 51 # syscall de diálogo de entrada (prompt popup)
	la	$a0, mensagemEntrada
	syscall
	
	# Verificando status retornado pelo prompt
	beq	$a1, 0, valorOk
	beq	$a1, -1, erroAoParsearInt # erro do compilador ou foi digitado algo que não era esperado
	beq	$a1, -2, usuarioCancelou # usuário clicou em cancelar, indo para a proxima casa
	beq	$a1, -3, usuarioCancelou # usuário clicou em ok, mas não digitou nada, indo para a proxima ca
	
	erroAoParsearInt:
		li	$v0, 55
		la	$a0, mensagemErro
		li	$a1, 0
		syscall
		j	manusearEntradas
	
	valorOk:
		add	$t4, $t4, 1 # Mais um ao contador
		li	$t3, 1 # Identificador de substituição
		j	fimManusear
	
	usuarioCancelou:
		li	$t3, 0
		j	fimManusear
	
	fimManusear:
		bge     $t4, 36, exit # Contador maior que 36, fim
		
		mul 	$t9, $t9, 4 # multiplicando o íncide por 4 (array anda de 4 em 4 bytes)
		#sub	$t9, $t9, 4 # voltando uma posição na memória
		add 	$s0, $zero, $a0 # adicionando o valor inserido pelo usuário ao s0
		sw      $s0, tabuleiro($t9) # adicionando o endereço ao array na posição $t8 ($t9 * 4)
		
		#add 	$t9, $t9, 1
		li	$t9, 0 # Resetando posição da array para futuras inserções
		
		move 	$t5, $a0
		
		j 	manusearEntradas # Loop

proxCasaVazia:
	bge 	$t9, 36, fimDeJogo # Contador maior que 36, fim

	add	$t9, $t9, 1
	lw      $t6, 0($t5)
    	addi    $t5, $t5, 4 # Array/memória anda de 4 em 4 bytes
    	
    	beq	$t6, 0, achouCasaVazia # Encontrou 0 no array
    	
    	j	proxCasaVazia
    	
    	achouCasaVazia:
    		#li	$t9, 4
    		sub	$t9, $t9, 1
    		jr	$ra	

imprimirTabuleiro:	
	# caso o contador ultrapasse 36, saimos da função
	bge     $t0, 36, sair

	bne	$t3, 0, substituirValor # se $t3 não for zero, quer dizer que o usuário vai substituir algum valor
	j	continuar

	substituirValor:
		#bne	$t9, $t0, continuar # se o índice de substituição não for igual o índice desse momento, não fazer nada
		#move 	$t8, $t9
		#mul 	$t8, $t8, 4 # multiplicando o íncide por 4 (array anda de 4 em 4 bytes)
		#sub	$t8, $t8, 4 # voltando uma posição na memória
		#add 	$s0, $zero, $t5 # adicionando o valor inserido pelo usuário ao s0
		#sw      $s0, tabuleiro($t8) # adicionando o endereço ao array na posição $t8 ($t9 * 4)
	
		#li	$v0, 0
		#la	$t5, tabuleiro
		#la	$t1, tabuleiro
		#li	$t8, 0
		
		#sw	$ra, ($gp)
		
		#jal	proxCasaVazia
		
		#lw	$ra, ($gp)
	
	continuar:
    		# carregando palavra do endereço do array e incrementando para o próximo
    		lw      $t2, 0($t1)
    		addi    $t1, $t1, 4

	beq	$t0, 18, imprimirSeparadorHorizontal # caso o contador seja 18, imprimimos uma divisão
	beq	$t0, $t9, imprimirX # imprime um "X" na casa selecionada pra inserção de número
	beq 	$t2, 0,	imprimirNumeroVazio # imprimir espaço onde não existe número
	
	# Imprimindo caractere "X"
    	imprimirX:
    		bne 	$t2, 0, imprimirValor # caso ja tenha um valor nessa casa, não imprimimos o X
    		li      $v0, 11  
    		li      $a0, 88 # "X"
    		syscall
    		j	imprimirNumeros

	# Imprimindo o valor contido na posição do contador do array
	imprimirValor:
    		li      $v0, 1      
    		move    $a0, $t2
    		syscall
    		j	imprimirNumeros
    	
    	# Imprimindo um caractere de espaço em branco
    	imprimirNumeroVazio:
    		li      $v0, 11  
    		li      $a0, 32 # " "
    		syscall
    		j	imprimirNumeros
    	
    	# Lógica de impressão dos números (casas, divisões, separadores)
    	imprimirNumeros:
    		beq	$t0, 2, imprimirSeparador # fim do bloco
    		beq	$t0, 5, imprimirNovaLinha # fim da linha
    		beq	$t0, 8, imprimirSeparador
    		beq	$t0, 11, imprimirNovaLinha
    		beq	$t0, 14, imprimirSeparador
    		beq	$t0, 17, imprimirNovaLinha
    		beq	$t0, 20, imprimirSeparador
    		beq	$t0, 23, imprimirNovaLinha
    		beq	$t0, 26, imprimirSeparador
    		beq	$t0, 29, imprimirNovaLinha
    		beq	$t0, 32, imprimirSeparador
    		beq	$t0, 35, imprimirNovaLinha
    		j	imprimirEspaco
    	
    	imprimirNovaLinha:
    		# imprimindo uma nova linha
    		li      $a0, 10 # "\n"
    		li      $v0, 11  
    		syscall
    		j	loopImprimirTabuleiro
    		
    	imprimirEspaco:
    		# imprimindo um espaço para separar os valores
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


fimDeJogo:
	li	$v0, 0
	la	$t1, tabuleiro

    	li      $v0, 4
    	la      $a0, separador_vertical
    	syscall

	jal 	imprimirTabuleiro
	j 	exit

exit:
	li 	$v0, 10 # Definindo fim do programa
	syscall
