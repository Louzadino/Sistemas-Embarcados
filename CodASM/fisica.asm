; RESUMO: Módulo responsável por gerenciar a física e os movimentos dos
; lutadores. Controla a gravidade, a mecânica de pulo, a verificação do
; estado de agachamento e a movimentação horizontal (esquerda/direita),
; garantindo também os limites da arena e a colisão de corpos no eixo X.

segment data
    global p1_vy, p2_vy
    global p1_estado, p2_estado
    
    p1_vy dw 0          ; Velocidade vertical atual do Player 1
    p2_vy dw 0          ; Velocidade vertical atual do Player 2
    p1_estado db 0      ; Estado do P1: 0 = Em pé, 1 = Agachado
    p2_estado db 0      ; Estado do P2: 0 = Em pé, 1 = Agachado

segment code
    global atualiza_movimento
    
    extern p1_x, p1_y, p2_x, p2_y
    extern key_a, key_d, key_left, key_right
    extern key_w, key_s, key_up, key_down

; FUNÇÃO CENTRAL: ATUALIZA_MOVIMENTO
; Orquestra a verificação de agachamento e a física de cada lutador
atualiza_movimento:
    PUSH AX
    CALL estado_agachar
    CALL fisica_p1
    CALL fisica_p2
    POP AX
    RET

; ROTINA: ESTADO_AGACHAR
; Verifica se os jogadores estão tentando se abaixar (teclas S e Down)
estado_agachar:
    ; Avalia o agachamento do Player 1 
    MOV byte [p1_estado], 0
    CMP word [p1_y], 115        ; Se o P1 estiver no ar, não pode abaixar
    JG check_p2_crouch      
    CMP byte [key_s], 1         ; Verifica se a tecla S está pressionada
    JNE check_p2_crouch
    MOV byte [p1_estado], 1     ; Define P1 como agachado

check_p2_crouch:
    ; Avalia o agachamento do Player 2 
    MOV byte [p2_estado], 0
    CMP word [p2_y], 115        ; Se o P2 estiver no ar, não pode abaixar
    JG fim_agachar
    CMP byte [key_down], 1      ; Verifica se a tecla Seta para Baixo está pressionada
    JNE fim_agachar
    MOV byte [p2_estado], 1     ; Define P2 como agachado
fim_agachar:
    RET

; ROTINA: FÍSICA DO PLAYER 1 (Pulo, Gravidade e Eixo X)
fisica_p1:
    ; --- Tratamento do Pulo (P1) ---
    CMP word [p1_y], 115
    JG aplica_gravidade_p1      ; Se estiver no ar, continua aplicando a gravidade
    
    CMP byte [p1_estado], 1
    JE processa_x_p1            ; Se estiver agachado, não pode pular
    
    CMP byte [key_w], 1         ; Verifica se a tecla W (pular) foi pressionada
    JNE processa_x_p1       
    MOV word [p1_vy], 24        ; Aplica impulso inicial para cima (velocidade vertical)
    JMP aplica_gravidade_p1

aplica_gravidade_p1:
    MOV AX, [p1_vy]
    ADD word [p1_y], AX         ; Atualiza a posição Y com base na velocidade vertical
    SUB word [p1_vy], 4         ; Aplica o efeito da gravidade (reduz a velocidade de subida/aumenta queda)

    CMP word [p1_y], 115
    JG processa_x_p1
    MOV word [p1_y], 115        ; Garante que o lutador aterre no nível do chão (Y = 115)
    MOV word [p1_vy], 0         ; Zera a velocidade vertical ao aterrissar

processa_x_p1:
    ; Movimentação Horizontal no Eixo X (P1) 
    CMP byte [p1_estado], 1
    JE fim_fisica_p1            ; Se estiver agachado, não se desloca horizontalmente

    ; Movimento para a Esquerda (Tecla A)
    CMP byte [key_a], 1
    JNE tenta_d
    CMP word [p1_x], 25         ; Limite esquerdo da tela/arena
    JLE tenta_d
    SUB word [p1_x], 3          ; Move para a esquerda

tenta_d:
    ; Movimento para a Direita (Tecla D)
    CMP byte [key_d], 1
    JNE fim_fisica_p1
    MOV AX, [p2_x]
    SUB AX, 40                  ; Impede que P1 atravesse a posição de P2
    CMP [p1_x], AX
    JGE fim_fisica_p1
    ADD word [p1_x], 3          ; Move para a direita
fim_fisica_p1:
    RET

; ROTINA: FÍSICA DO PLAYER 2 (Pulo, Gravidade e Eixo X)
fisica_p2:
    ; Tratamento do Pulo (P2) 
    CMP word [p2_y], 115
    JG aplica_gravidade_p2
    
    CMP byte [p2_estado], 1
    JE processa_x_p2
    
    CMP byte [key_up], 1        ; Verifica se a tecla Seta para Cima foi pressionada
    JNE processa_x_p2
    MOV word [p2_vy], 24        ; Impulso inicial para cima
    JMP aplica_gravidade_p2

aplica_gravidade_p2:
    MOV AX, [p2_vy]
    ADD word [p2_y], AX
    SUB word [p2_vy], 4         ; Gravidade

    CMP word [p2_y], 115
    JG processa_x_p2
    MOV word [p2_y], 115        ; Reseta ao tocar o chão
    MOV word [p2_vy], 0

processa_x_p2:
    ; Movimentação Horizontal no Eixo X (P2) 
    CMP byte [p2_estado], 1
    JE fim_fisica_p2       

    ; Movimento para a Esquerda (Tecla Seta Esquerda)
    CMP byte [key_left], 1
    JNE tenta_right
    MOV AX, [p1_x]
    ADD AX, 40                  ; Impede que P2 atravesse P1
    CMP [p2_x], AX
    JLE tenta_right
    SUB word [p2_x], 3

tenta_right:
    ; Movimento para a Direita (Tecla Seta Direita)
    CMP byte [key_right], 1
    JNE fim_fisica_p2
    CMP word [p2_x], 614        ; Limite direito da arena
    JGE fim_fisica_p2
    ADD word [p2_x], 3
fim_fisica_p2:
    RET