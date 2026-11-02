; RESUMO: Módulo gráfico responsável pela renderização dos lutadores e 
; gerenciamento de suas posições e cores na arena. Utiliza macros do 
; NASM para desenhar linhas e círculos de forma compacta, cobrindo todas 
; as poses (normal, passos, agachado, soco e chute) para ambos os jogadores.

segment data
    global p1_x, p1_y, p2_x, p2_y
    global cor_p1, cor_p2
    
    ; Coordenadas iniciais dos lutadores na tela
    p1_x dw 150
    p1_y dw 115
    p2_x dw 490
    p2_y dw 115
    
    ; Cores dinâmicas para customização na tela de seleção
    cor_p1 db 1     ; Cor padrão Player 1 (Azul)
    cor_p2 db 4     ; Cor padrão Player 2 (Vermelho)

segment code
    global desenha_lutadores, apaga_lutadores
    global desenha_p1_normal, desenha_p2_normal
    global desenha_p1_agachado, desenha_p2_agachado
    global desenha_p1_andando, desenha_p2_andando
    global desenha_soco_p1, desenha_soco_p2
    global desenha_chute_p1, desenha_chute_p2
    
    extern line, circle, cor

; MACROS DE DESENHO GEOMETRICO
; Simplificam a chamada das funções de primitivas gráficas por deslocamento

; Macro para desenhar linhas relativas à base (X, Y)
; Parâmetros: %1=BaseX, %2=OffsetX1, %3=BaseY, %4=OffsetY1, %5=OffsetX2, %6=OffsetY2
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

; Macro para desenhar a cabeça (círculo com raio fixo de 10 pixels)
; Parâmetros: %1=BaseX, %2=OffsetX, %3=BaseY, %4=OffsetY
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

; POSES NORMAIS (EM PÉ)
desenha_p1_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    ; Aplica a cor customizada do Jogador 1
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], 0           ; Cabeça
    LINE [p1_x], 0, [p1_y], -10, 0, -35   ; Tronco/Corpo
    LINE [p1_x], 0, [p1_y], -15, 5, -25   ; Braço Trás (Ombro ao Cotovelo)
    LINE [p1_x], 5, [p1_y], -25, 10, -5   ; Braço Trás (Cotovelo à Mão)
    LINE [p1_x], 0, [p1_y], -15, 10, -25  ; Braço Frente (Ombro ao Cotovelo)
    LINE [p1_x], 10, [p1_y], -25, 20, -5  ; Braço Frente (Cotovelo à Mão)
    LINE [p1_x], 0, [p1_y], -35, -15, -65 ; Perna Trás
    LINE [p1_x], 0, [p1_y], -35, 15, -65  ; Perna Frente
    
    POP AX
    POP BP
    RET

desenha_p2_normal:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    ; Aplica a cor customizada do Jogador 2
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

; POSES DE PASSOS (ANDANDO)
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
    LINE [p1_x], 0, [p1_y], -35, -5, -65  ; Posição das pernas alterada para simular passo
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

; POSES AGACHADAS
desenha_p1_agachado:
    PUSH BP
    MOV BP, SP
    PUSH AX
    
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    
    CIRCLE [p1_x], 0, [p1_y], -25         ; Cabeça posicionada mais abaixo
    LINE [p1_x], 0, [p1_y], -35, 0, -50   ; Tronco reduzido
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

; ROTINAS DE SOCO
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
    LINE [p1_x], 0, [p1_y], -15, 40, -15  ; Braço esticado para a frente (Ataque)
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
    LINE [p2_x], 0, [p2_y], -15, -40, -15 ; Braço esticado para a frente (Ataque)
    LINE [p2_x], 0, [p2_y], -35, -15, -65
    LINE [p2_x], 0, [p2_y], -35, 15, -65
    
    POP AX
    POP BP
    RET

; ROTINAS DE CHUTE
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
    LINE [p1_x], 0, [p1_y], -35, 40, -35  ; Perna esticada para a frente (Chute)
    
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
    LINE [p2_x], 0, [p2_y], -35, -40, -35 ; Perna esticada para a frente (Chute)
    
    POP AX
    POP BP
    RET

; ROTINA DE LIMPEZA GERAL
; Desenha todas as possíveis posições com a cor 0 (preto) 
; para apagar completamente os rastros dos lutadores na tela.
apaga_lutadores:
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; Define a cor preta (0) para apagar
    MOV byte [cor], 0
    
    ; Apaga rastros do P1 
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
    
    ; Apaga rastros do P2 
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