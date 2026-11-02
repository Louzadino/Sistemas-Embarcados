; =====================================================================
; ARQUIVO: fisica.asm
; =====================================================================

segment data
    global p1_vy, p2_vy
    global p1_estado, p2_estado
    
    p1_vy dw 0          
    p2_vy dw 0          
    p1_estado db 0      ; 0 = Em pe, 1 = Agachado
    p2_estado db 0      ; 0 = Em pe, 1 = Agachado

segment code
    global atualiza_movimento
    
    extern p1_x, p1_y, p2_x, p2_y
    extern key_a, key_d, key_left, key_right
    extern key_w, key_s, key_up, key_down

atualiza_movimento:
    PUSH AX
    CALL estado_agachar
    CALL fisica_p1
    CALL fisica_p2
    POP AX
    RET

estado_agachar:
    ; --- ESTADOS DE AGACHAR ---
    MOV byte [p1_estado], 0
    CMP word [p1_y], 115
    JG check_p2_crouch      
    CMP byte [key_s], 1
    JNE check_p2_crouch
    MOV byte [p1_estado], 1
check_p2_crouch:
    MOV byte [p2_estado], 0
    CMP word [p2_y], 115
    JG fim_agachar
    CMP byte [key_down], 1
    JNE fim_agachar
    MOV byte [p2_estado], 1
fim_agachar:
    RET

fisica_p1:
    ; --- PULO P1 ---
    CMP word [p1_y], 115
    JG aplica_gravidade_p1
    
    CMP byte [p1_estado], 1
    JE processa_x_p1        
    
    CMP byte [key_w], 1
    JNE processa_x_p1       
    MOV word [p1_vy], 24    
    JMP aplica_gravidade_p1

aplica_gravidade_p1:
    MOV AX, [p1_vy]
    ADD word [p1_y], AX     
    SUB word [p1_vy], 4     

    CMP word [p1_y], 115
    JG processa_x_p1
    MOV word [p1_y], 115    
    MOV word [p1_vy], 0     

processa_x_p1:
    ; --- MOVIMENTO X P1 ---
    CMP byte [p1_estado], 1
    JE fim_fisica_p1       

    CMP byte [key_a], 1
    JNE tenta_d
    CMP word [p1_x], 25
    JLE tenta_d
    SUB word [p1_x], 3
tenta_d:
    CMP byte [key_d], 1
    JNE fim_fisica_p1
    MOV AX, [p2_x]
    SUB AX, 40              
    CMP [p1_x], AX
    JGE fim_fisica_p1
    ADD word [p1_x], 3
fim_fisica_p1:
    RET

fisica_p2:
    ; --- PULO P2 ---
    CMP word [p2_y], 115
    JG aplica_gravidade_p2
    
    CMP byte [p2_estado], 1
    JE processa_x_p2
    
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
    CMP byte [p2_estado], 1
    JE fim_fisica_p2       

    CMP byte [key_left], 1
    JNE tenta_right
    MOV AX, [p1_x]
    ADD AX, 40
    CMP [p2_x], AX
    JLE tenta_right
    SUB word [p2_x], 3
tenta_right:
    CMP byte [key_right], 1
    JNE fim_fisica_p2
    CMP word [p2_x], 614
    JGE fim_fisica_p2
    ADD word [p2_x], 3
fim_fisica_p2:
    RET