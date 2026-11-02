; =====================================================================
; ARQUIVO: main.asm
; =====================================================================

segment code
..start:
    extern desenha_cenario, desenha_lutadores, apaga_lutadores
    extern desenha_p1_normal, desenha_p2_normal
    extern desenha_p1_agachado, desenha_p2_agachado
    extern desenha_p1_andando, desenha_p2_andando

    extern status_jogadores
    extern energia_p1, energia_p2
    extern p1_x, p2_x, p1_y, p2_y
    
    extern p1_estado, p2_estado
    extern atualiza_movimento
    extern verifica_ataques

    extern instala_teclado, restaura_teclado
    extern key_q, key_a, key_d, key_left, key_right

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
    CALL render_p1
    CALL render_p2
    CALL status_jogadores

loop_principal:
    CALL delay

    CMP byte [key_q], 1
    JE sair_jogo

    ; 1. Verifica combates (socos/chutes)
    CALL verifica_ataques
    
    ; 2. Atualiza a física (se movimenta e apaga rastros)
    CALL apaga_lutadores
    CALL atualiza_movimento

    ; 3. Renderiza o quadro atual
    CALL render_p1
    CALL render_p2
    CALL desenha_cenario    
    
    JMP loop_principal            


; ==================================================
; FUNCOES ROTEADORAS DE RENDERIZACAO
; ==================================================
global render_p1, render_p2

render_p1:
    CMP byte [p1_estado], 1
    JE r_agachado_p1
    CMP word [p1_y], 115
    JG r_normal_p1      
    CMP byte [key_a], 1
    JE r_check_passo_p1
    CMP byte [key_d], 1
    JE r_check_passo_p1
r_normal_p1:
    CALL desenha_p1_normal
    RET
r_check_passo_p1:
    MOV AX, [p1_x]
    TEST AX, 0010h      
    JZ r_normal_p1
    CALL desenha_p1_andando
    RET
r_agachado_p1:
    CALL desenha_p1_agachado
    RET

render_p2:
    CMP byte [p2_estado], 1
    JE r_agachado_p2
    CMP word [p2_y], 115
    JG r_normal_p2      
    CMP byte [key_left], 1
    JE r_check_passo_p2
    CMP byte [key_right], 1
    JE r_check_passo_p2
r_normal_p2:
    CALL desenha_p2_normal
    RET
r_check_passo_p2:
    MOV AX, [p2_x]
    TEST AX, 0010h      
    JZ r_normal_p2
    CALL desenha_p2_andando
    RET
r_agachado_p2:
    CALL desenha_p2_agachado
    RET

; ==================================================
; FINALIZACAO
; ==================================================
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

segment stack stack
    resb 512
stacktop: