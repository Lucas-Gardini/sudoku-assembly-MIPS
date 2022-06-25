.data
bemVindo:     		.asciiz "Bem vindo ao jogo de sudoku!"
tabuleiro:		.word	1, 3, 8, 5, 0, 2, 0, 0, 0, 0, 0, 0, 6, 0, 0, 8, 7, 1, 2, 0, 0, 6, 0, 0, 0, 0, 7, 0, 4, 3, 0, 0, 3, 0, 8, 7
separador:		.asciiz " | "
separador_horizontal:	.asciiz "- - - - - - -\n"

.text
.globl main

main:
	li	$v0, 0
	la	$t1, tabuleiro
	jal imprimirTabuleiro
	j	exit

imprimirTabuleiro:
	# caso o contador ultrapasse 36, saimos da funcao
	bge     $t0, 36, exit

    	# carregando palavra do endereço do array e incrementando para o próximo
    	lw      $t2, 0($t1)
    	addi    $t1, $t1, 4

	beq	$t0, 18, imprimirSeparadorHorizontal

    	# syscall para imprimir o valor
    	li      $v0, 1      
    	move    $a0, $t2
    	syscall
    	
    	beq	$t0, 2, imprimirSeparador
    	beq	$t0, 5, imprimirNovaLinha
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

exit:
	li $v0, 10 # Definindo fim do programa #
	syscall
