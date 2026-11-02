; =====================================================================
; ARQUIVO: colisoes.asm
; =====================================================================

segment data
    global soco_p1_travado, soco_p2_travado
    global chute_p1_travado, chute_p2_travado

    soco_p1_travado db 0
    soco_p2_travado db 0
    chute_p1_travado db 0
    chute_p2_travado db 0

segment code
    global verifica_ataques
    
    extern p1_x, p1_y, p2_x, p2_y
    extern p1_estado, p2_estado
    extern energia_p1, energia_p2
    extern status_jogadores
    
    extern key_t, key_m, key_n, key_r
    
    extern apaga_lutadores, desenha_cenario
    extern desenha_soco_p1, desenha_soco_p2
    extern desenha_chute_p1, desenha_chute_p2
    extern render_p1, render_p2

verifica_ataques:
    PUSH AX
    CALL verifica_soco_p1
    CALL verifica_chute_p1
    CALL verifica_soco_p2
    CALL verifica_chute_p2
    POP AX
    RET

; --- SOCO P1 ---
verifica_soco_p1:
    CMP byte [key_t], 1
    JNE reseta_soco_p1
    
    CALL apaga_lutadores
    CALL desenha_soco_p1
    CALL render_p2      
    CALL desenha_cenario

    CMP byte [soco_p1_travado], 1
    JE fim_soco_p1
    
    MOV byte [soco_p1_travado], 1 
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_soco_p1
    
    CMP word [p2_y], 115
    JG fim_soco_p1
    CMP byte [p2_estado], 1
    JE fim_soco_p1

    CMP word [energia_p2], 0
    JE fim_soco_p1
    DEC word [energia_p2]
    CALL status_jogadores
fim_soco_p1:
    RET
reseta_soco_p1:
    MOV byte [soco_p1_travado], 0
    RET

; --- CHUTE P1 ---
verifica_chute_p1:
    CMP byte [key_r], 1             
    JNE reseta_chute_p1
    
    CALL apaga_lutadores
    CALL desenha_chute_p1
    CALL render_p2      
    CALL desenha_cenario

    CMP byte [chute_p1_travado], 1
    JE fim_chute_p1
    
    MOV byte [chute_p1_travado], 1 
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_chute_p1
    
    CMP word [p2_y], 115
    JG fim_chute_p1

    CMP word [energia_p2], 0
    JE fim_chute_p1
    DEC word [energia_p2]
    CALL status_jogadores
fim_chute_p1:
    RET
reseta_chute_p1:
    MOV byte [chute_p1_travado], 0
    RET

; --- SOCO P2 ---
verifica_soco_p2:
    CMP byte [key_m], 1
    JNE reseta_soco_p2
    
    CALL apaga_lutadores
    CALL render_p1      
    CALL desenha_soco_p2
    CALL desenha_cenario

    CMP byte [soco_p2_travado], 1
    JE fim_soco_p2
    
    MOV byte [soco_p2_travado], 1 
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_soco_p2

    CMP word [p1_y], 115
    JG fim_soco_p2
    CMP byte [p1_estado], 1
    JE fim_soco_p2

    CMP word [energia_p1], 0
    JE fim_soco_p2
    DEC word [energia_p1]
    CALL status_jogadores
fim_soco_p2:
    RET
reseta_soco_p2:
    MOV byte [soco_p2_travado], 0
    RET

; --- CHUTE P2 ---
verifica_chute_p2:
    CMP byte [key_n], 1             
    JNE reseta_chute_p2
    
    CALL apaga_lutadores
    CALL render_p1      
    CALL desenha_chute_p2
    CALL desenha_cenario

    CMP byte [chute_p2_travado], 1
    JE fim_chute_p2
    
    MOV byte [chute_p2_travado], 1 
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_chute_p2
    
    CMP word [p1_y], 115
    JG fim_chute_p2

    CMP word [energia_p1], 0
    JE fim_chute_p2
    DEC word [energia_p1]
    CALL status_jogadores
fim_chute_p2:
    RET
reseta_chute_p2:
    MOV byte [chute_p2_travado], 0
    RET