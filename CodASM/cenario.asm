; RESUMO: Módulo responsável por desenhar a arena de luta gráfica, 
; estabelecendo os limites superior (teto), inferior (chão), esquerdo 
; e direito para conter a movimentação dos lutadores.

segment code
    global desenha_cenario      ; Torna a função visível para o main.asm
    
    extern line                 ; Importa a função de desenhar reta de outro módulo
    extern cor                  ; Importa a variável global de controle de cor

desenha_cenario:
    ; Salva o contexto na pilha para preservar os registradores originais
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; Define a cor dos delimitadores da arena como branco intenso (15)
    MOV byte [cor], 15

    ; 1. DESENHAR O CHÃO (Linha horizontal inferior)
    ; Coordenadas: X de 0 até 639, Y fixo em 50
    MOV AX, 0
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 639
    PUSH AX
    MOV AX, 50
    PUSH AX
    CALL line

    ; 2. DESENHAR O TETO / DELIMITADOR SUPERIOR (Linha horizontal superior)
    ; Coordenadas: X de 0 até 639, Y fixo em 300
    MOV AX, 0
    PUSH AX
    MOV AX, 300
    PUSH AX
    MOV AX, 639
    PUSH AX
    MOV AX, 300
    PUSH AX
    CALL line

    ; 3. DESENHAR O LIMITE ESQUERDO (Linha vertical)
    ; Coordenadas: X fixo em 5, Y de 50 até 300
    MOV AX, 5
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 5
    PUSH AX
    MOV AX, 300
    PUSH AX
    CALL line

    ; 4. DESENHAR O LIMITE DIREITO (Linha vertical)
    ; Coordenadas: X fixo em 634, Y de 50 até 300
    MOV AX, 634
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 634
    PUSH AX
    MOV AX, 300
    PUSH AX
    CALL line

    ; Restaura o contexto da pilha e retorna para a função chamadora
    POP AX
    POP BP
    RET