; =====================================================================
; ARQUIVO: lutador.asm
; =====================================================================

segment data
    global p1_x, p1_y, p2_x, p2_y
    p1_x dw 150
    p1_y dw 115
    p2_x dw 490
    p2_y dw 115

segment code
    global desenha_lutadores, apaga_lutadores
    global desenha_p1_normal, desenha_p2_normal
    global desenha_p1_agachado, desenha_p2_agachado
    global desenha_soco_p1, desenha_soco_p2
    global desenha_chute_p1, desenha_chute_p2
    
    extern line, circle, cor

desenha_lutadores:
    CALL desenha_p1_normal
    CALL desenha_p2_normal
    RET

; ================== POSES NORMAIS ==================
desenha_p1_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
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
    POP AX
    POP BP
    RET

desenha_p2_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
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

; ================== POSES AGACHADAS ==================
desenha_p1_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 1
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 25
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 50
    PUSH AX
    CALL line
    MOV AX, [p1_x]
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 40
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 40
    PUSH AX
    CALL line
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 50
    PUSH AX
    MOV AX, [p1_x]
    SUB AX, 20
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 50
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line
    POP AX
    POP BP
    RET

desenha_p2_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 25
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 50
    PUSH AX
    CALL line
    MOV AX, [p2_x]
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 40
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 40
    PUSH AX
    CALL line
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 50
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 50
    PUSH AX
    MOV AX, [p2_x]
    ADD AX, 20
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line
    POP AX
    POP BP
    RET

; ================== LIMPEZA GERAL ==================
apaga_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    MOV byte [cor], 0
    
    ; --- APAGA P1 ---
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
    SUB AX, 25      
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
    SUB AX, 50      
    PUSH AX
    CALL line
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
    SUB AX, 10
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 40
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20      
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 40
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
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 50      
    PUSH AX
    MOV AX, [p1_x]
    SUB AX, 20      
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 65
    PUSH AX
    CALL line
    MOV AX, [p1_x]
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 50      
    PUSH AX
    MOV AX, [p1_x]
    ADD AX, 20      
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
    ADD AX, 40      
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    CALL line

    ; --- APAGA P2 ---
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
    SUB AX, 25      
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
    SUB AX, 50      
    PUSH AX
    CALL line
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
    ADD AX, 10
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 40
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20      
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 40
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
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 50      
    PUSH AX
    MOV AX, [p2_x]
    SUB AX, 20      
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 65
    PUSH AX
    CALL line
    MOV AX, [p2_x]
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 50      
    PUSH AX
    MOV AX, [p2_x]
    ADD AX, 20      
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
    SUB AX, 40      
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    CALL line

    POP AX
    POP BP
    RET

; ================== ROTINAS DE SOCO ==================
desenha_soco_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX
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
    POP AX
    POP BP
    RET

desenha_soco_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
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

; ================== ROTINAS DE CHUTE ==================
desenha_chute_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX
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
    ADD AX, 40
    PUSH AX
    MOV AX, [p1_y]
    SUB AX, 35
    PUSH AX
    CALL line
    POP AX
    POP BP
    RET

desenha_chute_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
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
    ADD AX, 15
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
    SUB AX, 40
    PUSH AX
    MOV AX, [p2_y]
    SUB AX, 35
    PUSH AX
    CALL line
    POP AX
    POP BP
    RET