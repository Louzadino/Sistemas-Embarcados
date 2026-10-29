; OBJETIVO: Desenhar e gerenciar os lutadores

segment data
    global p1_x, p1_y, p2_x, p2_y
    p1_x dw 150
    p1_y dw 115
    p2_x dw 490
    p2_y dw 115

segment code
    global desenha_lutadores
    global apaga_lutadores
    global desenha_soco_p1
    global desenha_soco_p2      ; Nova funcao exportada
    
    extern line
    extern circle
    extern cor

desenha_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; DESENHAR JOGADOR 1 (AZUL)
    MOV byte [cor], 1

    ; Cabeca P1
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle
    ; Tronco P1
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
    ; Bracos P1
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
    ; Perna Esquerda P1
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
    MOV byte [cor], 4

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
    ; Bracos P2
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
    ; Braco P1 (Apagador estendido para 40px para limpar o soco)
    MOV AX, [p1_x]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 40
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
    ; Braco P2 (Apagador estendido para 40px para a esquerda)
    MOV AX, [p2_x]
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 40
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

desenha_soco_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; --- P1 SOQUEANDO ---
    MOV byte [cor], 1
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
    ; Braço Esticado
    MOV AX, [p1_x]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 40
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

    ; --- P2 NORMAL ---
    MOV byte [cor], 4
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

desenha_soco_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; --- P1 NORMAL ---
    MOV byte [cor], 1
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

    ; --- P2 SOQUEANDO ---
    MOV byte [cor], 4
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
    ; Braço P2 Esticado (Alcancando para a Esquerda)
    MOV AX, [p2_x]
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 15
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 40
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