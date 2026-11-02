; =====================================================================
; ARQUIVO: lutador.asm
; =====================================================================

segment data
    global p1_x, p1_y, p2_x, p2_y
    global cor_p1, cor_p2
    
    p1_x dw 150
    p1_y dw 115
    p2_x dw 490
    p2_y dw 115
    
    cor_p1 db 1     ; Cor padrao Player 1 (Azul)
    cor_p2 db 4     ; Cor padrao Player 2 (Vermelho)

segment code
    global desenha_lutadores, apaga_lutadores
    global desenha_p1_normal, desenha_p2_normal
    global desenha_p1_agachado, desenha_p2_agachado
    global desenha_p1_andando, desenha_p2_andando
    global desenha_soco_p1, desenha_soco_p2
    global desenha_chute_p1, desenha_chute_p2
    
    extern line, circle, cor

; =====================================================================
; MACROS DE DESENHO
; =====================================================================
%macro LINE 6
    MOV AX, %1
    ADD AX, %2
    PUSH AX
    MOV AX, %3
    ADD AX, %4
    PUSH AX
    MOV AX, %1
    ADD AX, %5
    PUSH AX
    MOV AX, %3
    ADD AX, %6
    PUSH AX
    CALL line
%endmacro

%macro CIRCLE 4
    MOV AX, %1
    ADD AX, %2
    PUSH AX
    MOV AX, %3
    ADD AX, %4
    PUSH AX
    MOV AX, 10
    PUSH AX
    CALL circle
%endmacro

desenha_lutadores:
    CALL desenha_p1_normal
    CALL desenha_p2_normal
    RET

; ================== POSES NORMAIS ==================
desenha_p1_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    ; Define a cor baseada na variavel global
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35   
    LINE [p1_x], 0, [p1_y], -15, 5, -25   
    LINE [p1_x], 5, [p1_y], -25, 10, -5   
    LINE [p1_x], 0, [p1_y], -15, 10, -25  
    LINE [p1_x], 10, [p1_y], -25, 20, -5  
    LINE [p1_x], 0, [p1_y], -35, -15, -65 
    LINE [p1_x], 0, [p1_y], -35, 15, -65  
    
    POP AX
    POP BP
    RET

desenha_p2_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    ; Define a cor baseada na variavel global
    MOV AL, [cor_p2]
    MOV byte [cor], AL
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35   
    LINE [p2_x], 0, [p2_y], -15, -5, -25  
    LINE [p2_x], -5, [p2_y], -25, -10, -5 
    LINE [p2_x], 0, [p2_y], -15, -10, -25 
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -35, -15, -65 
    LINE [p2_x], 0, [p2_y], -35, 15, -65  
    
    POP AX
    POP BP
    RET

; ================== POSES DE PASSOS (ANDANDO) ==================
desenha_p1_andando:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25  
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    LINE [p1_x], 0, [p1_y], -35, -5, -65  
    LINE [p1_x], 0, [p1_y], -35, 5, -65
    
    POP AX
    POP BP
    RET

desenha_p2_andando:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p2]
    MOV byte [cor], AL
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25 
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -35, -5, -65  
    LINE [p2_x], 0, [p2_y], -35, 5, -65
    
    POP AX
    POP BP
    RET

; ================== POSES AGACHADAS ==================
desenha_p1_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], -25
    LINE [p1_x], 0, [p1_y], -35, 0, -50   
    LINE [p1_x], 0, [p1_y], -40, 5, -50   
    LINE [p1_x], 5, [p1_y], -50, 10, -30 
    LINE [p1_x], 0, [p1_y], -40, 10, -50  
    LINE [p1_x], 10, [p1_y], -50, 20, -30
    LINE [p1_x], 0, [p1_y], -50, -20, -65 
    LINE [p1_x], 0, [p1_y], -50, 20, -65
    
    POP AX
    POP BP
    RET

desenha_p2_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p2]
    MOV byte [cor], AL
    
    CIRCLE [p2_x], 0, [p2_y], -25
    LINE [p2_x], 0, [p2_y], -35, 0, -50
    LINE [p2_x], 0, [p2_y], -40, -5, -50  
    LINE [p2_x], -5, [p2_y], -50, -10, -30 
    LINE [p2_x], 0, [p2_y], -40, -10, -50 
    LINE [p2_x], -10, [p2_y], -50, -20, -30
    LINE [p2_x], 0, [p2_y], -50, -20, -65 
    LINE [p2_x], 0, [p2_y], -50, 20, -65
    
    POP AX
    POP BP
    RET

; ================== ROTINAS DE SOCO ==================
desenha_soco_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 40, -15  
    LINE [p1_x], 0, [p1_y], -35, -15, -65 
    LINE [p1_x], 0, [p1_y], -35, 15, -65
    
    POP AX
    POP BP
    RET

desenha_soco_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p2]
    MOV byte [cor], AL
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -40, -15 
    LINE [p2_x], 0, [p2_y], -35, -15, -65
    LINE [p2_x], 0, [p2_y], -35, 15, -65
    
    POP AX
    POP BP
    RET

; ================== ROTINAS DE CHUTE ==================
desenha_chute_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25  
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    LINE [p1_x], 0, [p1_y], -35, -15, -65 
    LINE [p1_x], 0, [p1_y], -35, 40, -35  
    
    POP AX
    POP BP
    RET

desenha_chute_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p2]
    MOV byte [cor], AL
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25 
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -35, -15, -65
    LINE [p2_x], 0, [p2_y], -35, -40, -35 
    
    POP AX
    POP BP
    RET

; ================== LIMPEZA GERAL ==================
apaga_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; Cor 0 = Preto (apaga os rastros)
    MOV byte [cor], 0
    
    ; --- APAGA P1 ---
    CIRCLE [p1_x], 0, [p1_y], 0           
    CIRCLE [p1_x], 0, [p1_y], -25         
    LINE [p1_x], 0, [p1_y], -10, 0, -50   
    LINE [p1_x], 0, [p1_y], -15, 5, -25
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    LINE [p1_x], 0, [p1_y], -15, 40, -15
    LINE [p1_x], 0, [p1_y], -40, 5, -50
    LINE [p1_x], 5, [p1_y], -50, 10, -30
    LINE [p1_x], 0, [p1_y], -40, 10, -50
    LINE [p1_x], 10, [p1_y], -50, 20, -30
    LINE [p1_x], 0, [p1_y], -35, -15, -65
    LINE [p1_x], 0, [p1_y], -35, 15, -65
    LINE [p1_x], 0, [p1_y], -35, -5, -65
    LINE [p1_x], 0, [p1_y], -35, 5, -65
    LINE [p1_x], 0, [p1_y], -50, -20, -65
    LINE [p1_x], 0, [p1_y], -50, 20, -65
    LINE [p1_x], 0, [p1_y], -35, 40, -35
    
    ; --- APAGA P2 ---
    CIRCLE [p2_x], 0, [p2_y], 0
    CIRCLE [p2_x], 0, [p2_y], -25
    LINE [p2_x], 0, [p2_y], -10, 0, -50
    LINE [p2_x], 0, [p2_y], -15, -5, -25
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -15, -40, -15
    LINE [p2_x], 0, [p2_y], -40, -5, -50
    LINE [p2_x], -5, [p2_y], -50, -10, -30
    LINE [p2_x], 0, [p2_y], -40, -10, -50
    LINE [p2_x], -10, [p2_y], -50, -20, -30
    LINE [p2_x], 0, [p2_y], -35, -15, -65
    LINE [p2_x], 0, [p2_y], -35, 15, -65
    LINE [p2_x], 0, [p2_y], -35, -5, -65
    LINE [p2_x], 0, [p2_y], -35, 5, -65
    LINE [p2_x], 0, [p2_y], -50, -20, -65
    LINE [p2_x], 0, [p2_y], -50, 20, -65
    LINE [p2_x], 0, [p2_y], -35, -40, -35

    POP AX
    POP BP
    RET