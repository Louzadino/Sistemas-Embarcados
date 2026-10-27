; OBJETIVO: Loop principal do Jogo de Luta e controle de video

segment code
..start:
    extern desenha_cenario
    extern desenha_lutadores
    extern apaga_lutadores

    ; importações do status
    extern status_jogadores
    extern escrever_na_tela
    extern barra_de_energia
    extern quadrado

    ; Importacoes do teclado
    extern instala_teclado
    extern restaura_teclado
    extern key_a, key_d, key_left, key_right, key_q
    
    ; Variaveis dos lutadores para alteracao de coordenadas
    extern p1_x, p2_x

    ; 1. Inicializacao dos registradores
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    ; 2. Instala a nova interrupcao de teclado (INT 9h)
    CALL instala_teclado

    ; 3. Inicia o modo grafico
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    CALL desenha_cenario
    CALL desenha_lutadores
    CALL status_jogadores       ; expõe o status dos jogadores

loop_principal:
    CALL delay

    CMP byte [key_q], 1
    JNE continua
    JMP sair_jogo
    continua:

    ; Verifica se alguem vai se mover neste frame
    CMP byte [key_a], 1
    JE atualiza_posicoes
    CMP byte [key_d], 1
    JE atualiza_posicoes
    CMP byte [key_left], 1
    JE atualiza_posicoes
    CMP byte [key_right], 1
    JE atualiza_posicoes

    JMP loop_principal      ; Se ninguem se moveu, apenas aguarda

atualiza_posicoes:
    CALL apaga_lutadores    ; Apaga as posicoes antigas

    ; Processa Movimento do Jogador 1 
    CMP byte [key_a], 1
    JNE tenta_d
    ; Impede que atravesse o limite esquerdo (Parede X=5 + Braço 20 = 25)
    CMP word [p1_x], 25
    JLE tenta_d
    SUB word [p1_x], 3

tenta_d:
    CMP byte [key_d], 1
    JNE tenta_left
    ; Impede que atravesse o Jogador 2 (Distância de segurança de 40px)
    MOV AX, [p2_x]
    SUB AX, 40              
    CMP [p1_x], AX
    JGE tenta_left
    ADD word [p1_x], 3

    ; Processa Movimento do Jogador 2 
tenta_left:
    CMP byte [key_left], 1
    JNE tenta_right
    ; Impede que atravesse o Jogador 1 (Distância de segurança de 40px)
    MOV AX, [p1_x]
    ADD AX, 40
    CMP [p2_x], AX
    JLE tenta_right
    SUB word [p2_x], 3

tenta_right:
    CMP byte [key_right], 1
    JNE finaliza_frame
    ; Impede que atravesse o limite direito (Parede X=634 - Braço 20 = 614)
    CMP word [p2_x], 614
    JGE finaliza_frame
    ADD word [p2_x], 3

finaliza_frame:
    CALL desenha_lutadores  ; Desenha nas novas coordenadas
    CALL desenha_cenario    ; Restaura as linhas brancas apagadas
    JMP loop_principal      ; Retorna ao fluxo

sair_jogo:
    ; Restaura o video e o teclado (Requisito 9)
    MOV AH, 0   
    MOV AL, [modo_anterior] 
    INT 10h
    
    CALL restaura_teclado

    MOV AX, 4C00h
    INT 21h

; FUNCAO DE DELAY (Ajustar valor de CX se ficar rapido/lento demais)
delay:
    PUSH CX
    MOV CX, 0100h       ; Multiplicador externo (ajuste a velocidade aqui)
del2:
    PUSH CX
    MOV CX, 0800h       ; Loop interno
del1:
    LOOP del1
    POP CX
    LOOP del2
    POP CX
    RET

segment data
    modo_anterior db 0

segment stack stack
    resb 512
stacktop: