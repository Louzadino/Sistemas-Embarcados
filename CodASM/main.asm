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
    
    extern p1_x, p2_x

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
    CALL desenha_p2_normal      ; Correcao: renderiza so o P2 parado
    CALL desenha_cenario

    CMP byte [soco_p1_travado], 1
    JE verifica_ataques_p2
    MOV byte [soco_p1_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
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
    CALL desenha_p2_normal      ; Correcao: renderiza so o P2 parado
    CALL desenha_cenario

    CMP byte [chute_p1_travado], 1
    JE verifica_ataques_p2
    MOV byte [chute_p1_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
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
    CALL desenha_p1_normal      ; Correcao: renderiza so o P1 parado
    CALL desenha_soco_p2
    CALL desenha_cenario

    CMP byte [soco_p2_travado], 1
    JE verifica_movimento
    MOV byte [soco_p2_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
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
    CALL desenha_p1_normal      ; Correcao: renderiza so o P1 parado
    CALL desenha_chute_p2
    CALL desenha_cenario

    CMP byte [chute_p2_travado], 1
    JE verifica_movimento
    MOV byte [chute_p2_travado], 1 

    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG verifica_movimento
    CMP word [energia_p1], 0
    JE verifica_movimento
    DEC word [energia_p1]
    CALL status_jogadores
    JMP verifica_movimento

reseta_chute_p2:
    MOV byte [chute_p2_travado], 0


    ; ================== MOVIMENTO ==================
verifica_movimento:
    CMP byte [key_a], 1
    JE atualiza_posicoes
    CMP byte [key_d], 1
    JE atualiza_posicoes
    CMP byte [key_left], 1
    JE atualiza_posicoes
    CMP byte [key_right], 1
    JE atualiza_posicoes
    JMP loop_principal            

atualiza_posicoes:
    CALL apaga_lutadores    

    ; --- P1 ---
    CMP byte [key_a], 1
    JNE tenta_d
    CMP word [p1_x], 25
    JLE tenta_d
    SUB word [p1_x], 3
tenta_d:
    CMP byte [key_d], 1
    JNE tenta_left
    MOV AX, [p2_x]
    SUB AX, 40              
    CMP [p1_x], AX
    JGE tenta_left
    ADD word [p1_x], 3

    ; --- P2 ---
tenta_left:
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

segment stack stack
    resb 512
stacktop: