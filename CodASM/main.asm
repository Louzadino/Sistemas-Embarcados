; =====================================================================
; ARQUIVO: main.asm
; =====================================================================

segment code
..start:
    extern desenha_cenario
    extern desenha_lutadores
    extern apaga_lutadores
    extern desenha_p1_normal, desenha_p2_normal
    extern desenha_soco_p1, desenha_soco_p2
    extern desenha_chute_p1, desenha_chute_p2

    extern status_jogadores, escrever_na_tela, barra_de_energia, quadrado
    extern energia_p1, energia_p2

    extern instala_teclado, restaura_teclado
    extern key_a, key_d, key_left, key_right, key_q
    extern key_t, key_m, key_n, key_r
    extern key_w, key_s, key_up, key_down
    
    extern p1_x, p2_x, p1_y, p2_y

    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    CALL instala_teclado

    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    CALL desenha_cenario
    CALL desenha_lutadores
    CALL status_jogadores

loop_principal:
    CALL delay

    CMP byte [key_q], 1
    JNE continua
    JMP sair_jogo
continua:

    ; ================== ATAQUES P1 ==================
verifica_soco_p1:
    CMP byte [key_t], 1
    JNE verifica_chute_p1
    
    CALL apaga_lutadores
    CALL desenha_soco_p1
    CALL desenha_p2_normal      
    CALL desenha_cenario

    CMP byte [soco_p1_travado], 1
    JE verifica_ataques_p2
    MOV byte [soco_p1_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG verifica_ataques_p2
    
    ; Verifica se P2 esta no ar (esquiva do soco)
    CMP word [p2_y], 115
    JG verifica_ataques_p2

    CMP word [energia_p2], 0
    JE verifica_ataques_p2
    DEC word [energia_p2]
    CALL status_jogadores
    JMP verifica_ataques_p2

verifica_chute_p1:
    MOV byte [soco_p1_travado], 0   
    
    CMP byte [key_r], 1             
    JNE reseta_chute_p1
    
    CALL apaga_lutadores
    CALL desenha_chute_p1
    CALL desenha_p2_normal      
    CALL desenha_cenario

    CMP byte [chute_p1_travado], 1
    JE verifica_ataques_p2
    MOV byte [chute_p1_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG verifica_ataques_p2

    CMP word [p2_y], 115
    JG verifica_ataques_p2

    CMP word [energia_p2], 0
    JE verifica_ataques_p2
    DEC word [energia_p2]
    CALL status_jogadores
    JMP verifica_ataques_p2

reseta_chute_p1:
    MOV byte [chute_p1_travado], 0


    ; ================== ATAQUES P2 ==================
verifica_ataques_p2:
    CMP byte [key_m], 1
    JNE verifica_chute_p2
    
    CALL apaga_lutadores
    CALL desenha_p1_normal      
    CALL desenha_soco_p2
    CALL desenha_cenario

    CMP byte [soco_p2_travado], 1
    JE verifica_movimento
    MOV byte [soco_p2_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG verifica_movimento

    CMP word [p1_y], 115
    JG verifica_movimento

    CMP word [energia_p1], 0
    JE verifica_movimento
    DEC word [energia_p1]
    CALL status_jogadores
    JMP verifica_movimento

verifica_chute_p2:
    MOV byte [soco_p2_travado], 0
    
    CMP byte [key_n], 1             
    JNE reseta_chute_p2
    
    CALL apaga_lutadores
    CALL desenha_p1_normal      
    CALL desenha_chute_p2
    CALL desenha_cenario

    CMP byte [chute_p2_travado], 1
    JE verifica_movimento
    MOV byte [chute_p2_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG verifica_movimento

    CMP word [p1_y], 115
    JG verifica_movimento

    CMP word [energia_p1], 0
    JE verifica_movimento
    DEC word [energia_p1]
    CALL status_jogadores
    JMP verifica_movimento

reseta_chute_p2:
    MOV byte [chute_p2_travado], 0


    ; ================== GATILHO DE MOVIMENTO E FISICA ==================
verifica_movimento:
    ; Precisamos atualizar a tela se alguem andar OU se alguem pular OU se estiver caindo
    CMP byte [key_a], 1
    JE atualiza_posicoes
    CMP byte [key_d], 1
    JE atualiza_posicoes
    CMP byte [key_left], 1
    JE atualiza_posicoes
    CMP byte [key_right], 1
    JE atualiza_posicoes
    CMP byte [key_w], 1
    JE atualiza_posicoes
    CMP byte [key_up], 1
    JE atualiza_posicoes
    CMP word [p1_y], 115    ; P1 esta no ar?
    JG atualiza_posicoes
    CMP word [p2_y], 115    ; P2 esta no ar?
    JG atualiza_posicoes

    JMP loop_principal            

atualiza_posicoes:
    CALL apaga_lutadores    

    ; --- FISICA DE PULO P1 ---
    CMP word [p1_y], 115    ; Verifica se esta no chao
    JG aplica_gravidade_p1  ; Se for maior, esta no ar
    
    CMP byte [key_w], 1     ; Se esta no chao e apertou W
    JNE processa_x_p1       
    MOV word [p1_vy], 24    ; Forca inicial do pulo
    JMP aplica_gravidade_p1

aplica_gravidade_p1:
    MOV AX, [p1_vy]
    ADD word [p1_y], AX     ; Atualiza a altura do lutador
    SUB word [p1_vy], 4     ; A gravidade puxa 4 pixels por frame

    CMP word [p1_y], 115    ; Se apos a queda passar do chao (<= 115)
    JG processa_x_p1
    MOV word [p1_y], 115    ; Trava o lutador no chao
    MOV word [p1_vy], 0     ; Zera a velocidade

processa_x_p1:
    ; --- MOVIMENTO X P1 ---
    CMP byte [key_a], 1
    JNE tenta_d
    CMP word [p1_x], 25
    JLE tenta_d
    SUB word [p1_x], 3
tenta_d:
    CMP byte [key_d], 1
    JNE fisica_pulo_p2
    MOV AX, [p2_x]
    SUB AX, 40              
    CMP [p1_x], AX
    JGE fisica_pulo_p2
    ADD word [p1_x], 3

fisica_pulo_p2:
    ; --- FISICA DE PULO P2 ---
    CMP word [p2_y], 115
    JG aplica_gravidade_p2
    
    CMP byte [key_up], 1
    JNE processa_x_p2
    MOV word [p2_vy], 24
    JMP aplica_gravidade_p2

aplica_gravidade_p2:
    MOV AX, [p2_vy]
    ADD word [p2_y], AX
    SUB word [p2_vy], 4

    CMP word [p2_y], 115
    JG processa_x_p2
    MOV word [p2_y], 115
    MOV word [p2_vy], 0

processa_x_p2:
    ; --- MOVIMENTO X P2 ---
    CMP byte [key_left], 1
    JNE tenta_right
    MOV AX, [p1_x]
    ADD AX, 40
    CMP [p2_x], AX
    JLE tenta_right
    SUB word [p2_x], 3
tenta_right:
    CMP byte [key_right], 1
    JNE finaliza_frame
    CMP word [p2_x], 614
    JGE finaliza_frame
    ADD word [p2_x], 3

finaliza_frame:
    CALL desenha_lutadores  
    CALL desenha_cenario    
    JMP loop_principal      

sair_jogo:
    MOV AH, 0   
    MOV AL, [modo_anterior] 
    INT 10h
    CALL restaura_teclado
    MOV AX, 4C00h
    INT 21h

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
    modo_anterior db 0
    soco_p1_travado db 0
    soco_p2_travado db 0
    chute_p1_travado db 0
    chute_p2_travado db 0
    p1_vy dw 0          ; Velocidade vertical do P1
    p2_vy dw 0          ; Velocidade vertical do P2

segment stack stack
    resb 512
stacktop: