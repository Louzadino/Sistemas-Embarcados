; RESUMO: Arquivo principal do jogo de luta. É responsável por gerenciar
; a inicialização do sistema, configuração de vídeo, laço principal 
; (game loop), chamadas de renderização, física, colisões e encerramento.

segment code
..start:
    ; Importação de funções gráficas e de cenário de outros módulos
    extern desenha_cenario, desenha_lutadores, apaga_lutadores
    extern desenha_p1_normal, desenha_p2_normal
    extern desenha_p1_agachado, desenha_p2_agachado
    extern desenha_p1_andando, desenha_p2_andando

    ; Importação de variáveis de status e posições
    extern status_jogadores
    extern energia_p1, energia_p2
    extern p1_x, p2_x, p1_y, p2_y
    
    ; Importação de estados e módulos externos (física e colisões)
    extern p1_estado, p2_estado
    extern atualiza_movimento
    extern verifica_ataques

    ; Importação de rotinas de hardware de teclado e teclas mapeadas
    extern instala_teclado, restaura_teclado
    extern key_q, key_a, key_d, key_left, key_right

    ; Importação da função de menu inicial (seleção de cores dos lutadores)
    extern MENU_INICIAL, cor_p1, cor_p2, cor

    ; INICIALIZAÇÃO DO SISTEMA E VÍDEO
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    ; Instala a nova interrupção de teclado (INT 9h)
    CALL instala_teclado

    ; Salva o modo de vídeo atual e configura o modo gráfico 640x480 (16h / 12h)
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; EXECUTA O MENU INTERATIVO DE SELEÇÃO DE CORES
    ; (Fica retido aqui até os dois jogadores escolherem as cores e apertarem ENTER)  

    CALL MENU_INICIAL

    ; Já presente nas suas funções de desenho do P1:
    MOV AL, [cor_p1]
    MOV byte [cor], AL

    ; Já presente nas suas funções de desenho do P2:
    MOV AL, [cor_p2]
    MOV byte [cor], AL

    ; Inicia o cenário e renderiza os lutadores já com as cores escolhidas em 'cor_p1' e 'cor_p2'
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores

    ; LAÇO PRINCIPAL DO JOGO (GAME LOOP)
loop_principal:
    CALL delay

    ; --- Correção do pulo de saída ---
    CMP byte [key_q], 1
    JNE continua_game_loop
    JMP sair_jogo

continua_game_loop:
    ; 1. Processa colisões e ataques
    CALL verifica_ataques
    
    ; 2. Apaga rastro e atualiza física
    CALL apaga_lutadores
    CALL atualiza_movimento

    ; 3. Renderiza o quadro atual
    CALL render_p1
    CALL render_p2
    CALL desenha_cenario    
    
    JMP loop_principal
; FUNÇÕES DE RENDERIZAÇÃO
; Decidem qual sprite do lutador desenhar com base 
; na física (se está pulando, agachando ou andando)
global render_p1, render_p2

render_p1:
    CMP byte [p1_estado], 1      ; Verifica se o P1 está agachado
    JE r_agachado_p1
    CMP word [p1_y], 115         ; Verifica se o P1 está no ar (pulando)
    JG r_normal_p1      
    CMP byte [key_a], 1          ; Verifica se está andando para esquerda
    JE r_check_passo_p1
    CMP byte [key_d], 1          ; Verifica se está andando para direita
    JE r_check_passo_p1
r_normal_p1:
    CALL desenha_p1_normal       ; Desenha pose padrão em pé
    RET
r_check_passo_p1:
    MOV AX, [p1_x]
    TEST AX, 0010h               ; Alterna o sprite de passo baseando nos bits da posição X
    JZ r_normal_p1
    CALL desenha_p1_andando      ; Desenha pose andando
    RET
r_agachado_p1:
    CALL desenha_p1_agachado     ; Desenha pose agachada
    RET

render_p2:
    CMP byte [p2_estado], 1      ; Verifica se o P2 está agachado
    JE r_agachado_p2
    CMP word [p2_y], 115         ; Verifica se o P2 está no ar
    JG r_normal_p2      
    CMP byte [key_left], 1       ; Verifica se está andando para esquerda
    JE r_check_passo_p2
    CMP byte [key_right], 1      ; Verifica se está andando para direita
    JE r_check_passo_p2
r_normal_p2:
    CALL desenha_p2_normal       ; Desenha pose padrão em pé
    RET
r_check_passo_p2:
    MOV AX, [p2_x]
    TEST AX, 0010h               ; Alterna sprite de passo do P2
    JZ r_normal_p2
    CALL desenha_p2_andando      ; Desenha pose andando
    RET
r_agachado_p2:
    CALL desenha_p2_agachado     ; Desenha pose agachada
    RET

; ROTINA DE ENCERRAMENTO E RESTAURAÇÃO DO SISTEMA
sair_jogo:
    MOV AH, 0   
    MOV AL, [modo_anterior]      ; Restaura o modo de vídeo original do DOS
    INT 10h
    CALL restaura_teclado        ; Restaura a interrupção original do teclado
    MOV AX, 4C00h                ; Encerra o programa com segurança
    INT 21h

; ROTINA DE DELAY (ATRASO POR SOFTWARE)
delay:
    PUSH CX
    MOV CX, 0100h       
del2:
    PUSH CX
    MOV CX, 0800h       
del1:
    LOOP del1
    POP CX
    LOOP del2
    POP CX
    RET

segment data
    modo_anterior db 0           ; Armazena o modo de vídeo anterior

segment stack stack
    resb 512
stacktop: