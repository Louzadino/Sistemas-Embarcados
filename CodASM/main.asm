; =====================================================================
; ARQUIVO: main.asm
; OBJETIVO: Loop principal do Jogo de Luta e controle de video
; =====================================================================

segment code
..start:
    extern desenha_cenario
    extern desenha_lutadores
    extern apaga_lutadores
    
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

loop_principal:
    CALL delay

    CMP byte [key_q], 1
    JE sair_jogo

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

    ; Processa Jogador 1
    CMP byte [key_a], 1
    JNE tenta_d
    SUB word [p1_x], 3
tenta_d:
    CMP byte [key_d], 1
    JNE tenta_left
    ADD word [p1_x], 3

    ; Processa Jogador 2
tenta_left:
    CMP byte [key_left], 1
    JNE tenta_right
    SUB word [p2_x], 3
tenta_right:
    CMP byte [key_right], 1
    JNE finaliza_frame
    ADD word [p2_x], 3

finaliza_frame:
    CALL desenha_lutadores  ; Desenha nas novas coordenadas
    CALL desenha_cenario    ; Restaura as linhas brancas da arena sobrescritas 
    JMP loop_principal

sair_jogo:
    ; Restaura o video e o teclado (Requisito 9)
    MOV AH, 0   
    MOV AL, [modo_anterior] 
    INT 10h
    
    CALL restaura_teclado

    MOV AX, 4C00h
    INT 21h

; =====================================================================
; FUNCAO DE DELAY (Ajuste o valor de CX se ficar rapido/lento demais)
; =====================================================================
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