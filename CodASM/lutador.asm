; OBJETIVO: Desenhar e gerenciar os lutadores

segment data
    ; Variaveis globais de posicao
    global p1_x, p1_y, p2_x, p2_y
    
    ; O chao esta em Y=50. O centro da cabeca ficara em Y=115.
    ; Como o raio e 10 e o corpo desce 65 pixels, os pes tocam exatamente no 50
    p1_x dw 150     ; Jogador 1 (Esquerda)
    p1_y dw 115
    
    p2_x dw 490     ; Jogador 2 (Direita)
    p2_y dw 115

segment code
    global desenha_lutadores
    global apaga_lutadores
    
    extern line
    extern circle
    extern cor

desenha_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; DESENHAR JOGADOR 1 (AZUL)
    MOV byte [cor], 1   ; Azul

    ; Cabeca P1 (Raio 10)
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle

    ; Tronco P1 (Pescoco em Y-10 ate Cintura em Y-35)
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    CALL line

    ; Bracos P1 (Ombros em Y-15, apontando para a direita)
    MOV AX, [p1_x]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    CALL line

    ; Perna Esquerda P1 (Cintura em Y-35 ate chao em Y-65)
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p1_x]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65      ; 115 - 65 = 50 (Toca no chao da arena)
    PUSH AX
    CALL line

    ; Perna Direita P1
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 15
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line

    ; DESENHAR JOGADOR 2 (VERMELHO)
    MOV byte [cor], 4   ; Vermelho

    ; Cabeca P2
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle

    ; Tronco P2
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 10
    PUSH AX
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    CALL line

    ; Bracos P2 (Ombros em Y-15, apontando para a esquerda)
    MOV AX, [p2_x]
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    CALL line

    ; Perna Esquerda P2
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line

    ; Perna Direita P2
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p2_x]
    ADD AX, 15
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line

    POP AX
    POP BP
    RET

apaga_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    MOV byte [cor], 0   ; Preto
    
    ; APAGA P1
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle

    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    CALL line

    MOV AX, [p1_x]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    CALL line

    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p1_x]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line

    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 15
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line

    ; APAGA P2
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle

    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 10
    PUSH AX
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    CALL line

    MOV AX, [p2_x]
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    CALL line

    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line

    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p2_x]
    ADD AX, 15
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line

    POP AX
    POP BP
    RET