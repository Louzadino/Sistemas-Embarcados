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
    global desenha_p1_andando, desenha_p2_andando
    global desenha_soco_p1, desenha_soco_p2
    global desenha_chute_p1, desenha_chute_p2
    
    extern line, circle, cor

; =====================================================================
; MACROS DE DESENHO
; =====================================================================
; Macro para desenhar linhas baseadas em coordenadas relativas (Base + Offset)
; %1 = Base X, %2 = Offset X1, %3 = Base Y, %4 = Offset Y1
; %5 = Offset X2, %6 = Offset Y2
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

; Macro para desenhar a cabeca (raio fixo de 10)
; %1 = Base X, %2 = Offset X, %3 = Base Y, %4 = Offset Y
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
    MOV byte [cor], 1
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35   ; Corpo
    LINE [p1_x], 0, [p1_y], -15, 5, -25   ; Braco Tras Ombro-Cotovelo (V)
    LINE [p1_x], 5, [p1_y], -25, 10, -5   ; Braco Tras Cotovelo-Mao (V)
    LINE [p1_x], 0, [p1_y], -15, 10, -25  ; Braco Frente Ombro-Cotovelo (V)
    LINE [p1_x], 10, [p1_y], -25, 20, -5  ; Braco Frente Cotovelo-Mao (V)
    LINE [p1_x], 0, [p1_y], -35, -15, -65 ; Perna Tras
    LINE [p1_x], 0, [p1_y], -35, 15, -65  ; Perna Frente
    
    POP AX
    POP BP
    RET

desenha_p2_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35   ; Corpo
    LINE [p2_x], 0, [p2_y], -15, -5, -25  ; Braco Tras Ombro-Cotovelo (V)
    LINE [p2_x], -5, [p2_y], -25, -10, -5 ; Braco Tras Cotovelo-Mao (V)
    LINE [p2_x], 0, [p2_y], -15, -10, -25 ; Braco Frente Ombro-Cotovelo (V)
    LINE [p2_x], -10, [p2_y], -25, -20, -5; Braco Frente Cotovelo-Mao (V)
    LINE [p2_x], 0, [p2_y], -35, -15, -65 ; Perna Tras
    LINE [p2_x], 0, [p2_y], -35, 15, -65  ; Perna Frente
    
    POP AX
    POP BP
    RET

; ================== POSES DE PASSOS (ANDANDO) ==================
desenha_p1_andando:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 1
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   ; Guarda V Tras
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25  ; Guarda V Frente
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    LINE [p1_x], 0, [p1_y], -35, -5, -65  ; Pernas passo
    LINE [p1_x], 0, [p1_y], -35, 5, -65
    
    POP AX
    POP BP
    RET

desenha_p2_andando:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  ; Guarda V Tras
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25 ; Guarda V Frente
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -35, -5, -65  ; Pernas passo
    LINE [p2_x], 0, [p2_y], -35, 5, -65
    
    POP AX
    POP BP
    RET

; ================== POSES AGACHADAS ==================
desenha_p1_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 1
    
    CIRCLE [p1_x], 0, [p1_y], -25
    LINE [p1_x], 0, [p1_y], -35, 0, -50   ; Corpo baixo
    LINE [p1_x], 0, [p1_y], -40, 5, -50   ; Braco Tras Agachado
    LINE [p1_x], 5, [p1_y], -50, 10, -30 
    LINE [p1_x], 0, [p1_y], -40, 10, -50  ; Braco Frente Agachado
    LINE [p1_x], 10, [p1_y], -50, 20, -30
    LINE [p1_x], 0, [p1_y], -50, -20, -65 ; Pernas
    LINE [p1_x], 0, [p1_y], -50, 20, -65
    
    POP AX
    POP BP
    RET

desenha_p2_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    
    CIRCLE [p2_x], 0, [p2_y], -25
    LINE [p2_x], 0, [p2_y], -35, 0, -50
    LINE [p2_x], 0, [p2_y], -40, -5, -50  ; Braco Tras Agachado
    LINE [p2_x], -5, [p2_y], -50, -10, -30 
    LINE [p2_x], 0, [p2_y], -40, -10, -50 ; Braco Frente Agachado
    LINE [p2_x], -10, [p2_y], -50, -20, -30
    LINE [p2_x], 0, [p2_y], -50, -20, -65 ; Pernas
    LINE [p2_x], 0, [p2_y], -50, 20, -65
    
    POP AX
    POP BP
    RET

; ================== ROTINAS DE SOCO ==================
desenha_soco_p1:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 1
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   ; Guarda V Tras
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 40, -15  ; Braco Frente Esticado (Soco)
    LINE [p1_x], 0, [p1_y], -35, -15, -65 ; Pernas normais
    LINE [p1_x], 0, [p1_y], -35, 15, -65
    
    POP AX
    POP BP
    RET

desenha_soco_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  ; Guarda V Tras
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -40, -15 ; Braco Frente Esticado (Soco)
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
    MOV byte [cor], 1
    
    CIRCLE [p1_x], 0, [p1_y], 0
    LINE [p1_x], 0, [p1_y], -10, 0, -35
    LINE [p1_x], 0, [p1_y], -15, 5, -25   ; Guarda V Tras
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25  ; Guarda V Frente
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    LINE [p1_x], 0, [p1_y], -35, -15, -65 ; Perna Tras
    LINE [p1_x], 0, [p1_y], -35, 40, -35  ; Perna Frente Esticada (Chute)
    
    POP AX
    POP BP
    RET

desenha_chute_p2:
    PUSH BP
    MOV BP, SP
    PUSH AX
    MOV byte [cor], 4
    
    CIRCLE [p2_x], 0, [p2_y], 0
    LINE [p2_x], 0, [p2_y], -10, 0, -35
    LINE [p2_x], 0, [p2_y], -15, -5, -25  ; Guarda V Tras
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25 ; Guarda V Frente
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    LINE [p2_x], 0, [p2_y], -35, -15, -65
    LINE [p2_x], 0, [p2_y], -35, -40, -35 ; Perna Frente Esticada (Chute)
    
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
    CIRCLE [p1_x], 0, [p1_y], 0           ; Cabeca normal
    CIRCLE [p1_x], 0, [p1_y], -25         ; Cabeca agachada
    LINE [p1_x], 0, [p1_y], -10, 0, -50   ; Cobre corpo normal e agachado
    ; Bracos Normais V
    LINE [p1_x], 0, [p1_y], -15, 5, -25
    LINE [p1_x], 5, [p1_y], -25, 10, -5
    LINE [p1_x], 0, [p1_y], -15, 10, -25
    LINE [p1_x], 10, [p1_y], -25, 20, -5
    ; Braco Soco
    LINE [p1_x], 0, [p1_y], -15, 40, -15
    ; Bracos Agachados V
    LINE [p1_x], 0, [p1_y], -40, 5, -50
    LINE [p1_x], 5, [p1_y], -50, 10, -30
    LINE [p1_x], 0, [p1_y], -40, 10, -50
    LINE [p1_x], 10, [p1_y], -50, 20, -30
    ; Todas as poses de Pernas P1
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
    ; Bracos Normais V
    LINE [p2_x], 0, [p2_y], -15, -5, -25
    LINE [p2_x], -5, [p2_y], -25, -10, -5
    LINE [p2_x], 0, [p2_y], -15, -10, -25
    LINE [p2_x], -10, [p2_y], -25, -20, -5
    ; Braco Soco
    LINE [p2_x], 0, [p2_y], -15, -40, -15
    ; Bracos Agachados V
    LINE [p2_x], 0, [p2_y], -40, -5, -50
    LINE [p2_x], -5, [p2_y], -50, -10, -30
    LINE [p2_x], 0, [p2_y], -40, -10, -50
    LINE [p2_x], -10, [p2_y], -50, -20, -30
    ; Todas as poses de Pernas P2
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