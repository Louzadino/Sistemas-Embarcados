; =====================================================================
; ARQUIVO: colisoes.asm
; RESUMO: Módulo responsável por gerenciar o sistema de combate do jogo.
; Valida as teclas de ataque (socos e chutes), verifica se há colisão 
; ou distância válida entre os jogadores, processa a redução de energia,
; atualiza a HUD e implementa travas para evitar dano contínuo por pressão.
; =====================================================================

segment data
    global soco_p1_travado, soco_p2_travado
    global chute_p1_travado, chute_p2_travado

    ; Flags de trava de golpe (evitam que manter a tecla pressionada cause múltiplos danos seguidos)
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

; ==================================================
; FUNÇÃO CENTRAL: VERIFICA_ATAQUES
; Chama sequencialmente a verificação de golpes para ambos os jogadores
; ==================================================
verifica_ataques:
    PUSH AX
    CALL verifica_soco_p1
    CALL verifica_chute_p1
    CALL verifica_soco_p2
    CALL verifica_chute_p2
    POP AX
    RET

; ==================================================
; ROTINA: SOCO DO PLAYER 1 (Tecla T)
; ==================================================
verifica_soco_p1:
    CMP byte [key_t], 1             ; Verifica se a tecla T está pressionada
    JNE reseta_soco_p1              ; Se não estiver, reseta a trava do soco
    
    ; Desenha temporariamente o frame de soco do P1 na tela
    CALL apaga_lutadores
    CALL desenha_soco_p1
    CALL render_p2      
    CALL desenha_cenario

    CMP byte [soco_p1_travado], 1   ; Se o golpe já foi contabilizado nesta pressão, ignora
    JE fim_soco_p1
    
    MOV byte [soco_p1_travado], 1   ; Ativa a trava para registrar apenas um hit por toque
    
    ; Cálculo da distância horizontal entre P1 e P2 (AX = p2_x - p1_x)
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45                      ; Verifica se está dentro do alcance do soco (<= 45 pixels)
    JG fim_soco_p1
    
    ; Validação de Defesa (se o P2 estiver pulando no ar ou agachado, o golpe falha)
    CMP word [p2_y], 115
    JG fim_soco_p1                  ; P2 está no ar (pulando)
    CMP byte [p2_estado], 1
    JE fim_soco_p1                  ; P2 está agachado

    ; Validação e Aplicação do Dano no P2
    CMP word [energia_p2], 0
    JE fim_soco_p1                  ; Se já estiver sem energia, não faz nada
    DEC word [energia_p2]           ; Reduz 1 unidade de energia do P2
    CALL status_jogadores           ; Atualiza a barra de energia na tela (HUD)
fim_soco_p1:
    RET
reseta_soco_p1:
    MOV byte [soco_p1_travado], 0   ; Libera a trava quando a tecla é solta
    RET

; ==================================================
; ROTINA: CHUTE DO PLAYER 1 (Tecla R)
; ==================================================
verifica_chute_p1:
    CMP byte [key_r], 1             ; Verifica se a tecla R está pressionada
    JNE reseta_chute_p1
    
    CALL apaga_lutadores
    CALL desenha_chute_p1
    CALL render_p2      
    CALL desenha_cenario

    CMP byte [chute_p1_travado], 1
    JE fim_chute_p1
    
    MOV byte [chute_p1_travado], 1 
    
    ; Verifica alcance horizontal
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_chute_p1
    
    ; Verifica se P2 está defendendo (no ar)
    CMP word [p2_y], 115
    JG fim_chute_p1

    ; Aplica dano caso passe pelas validações
    CMP word [energia_p2], 0
    JE fim_chute_p1
    DEC word [energia_p2]
    CALL status_jogadores
fim_chute_p1:
    RET
reseta_chute_p1:
    MOV byte [chute_p1_travado], 0
    RET

; ==================================================
; ROTINA: SOCO DO PLAYER 2 (Tecla M)
; ==================================================
verifica_soco_p2:
    CMP byte [key_m], 1             ; Verifica se a tecla M está pressionada
    JNE reseta_soco_p2
    
    CALL apaga_lutadores
    CALL render_p1      
    CALL desenha_soco_p2
    CALL desenha_cenario

    CMP byte [soco_p2_travado], 1
    JE fim_soco_p2
    
    MOV byte [soco_p2_travado], 1 
    
    ; Distância horizontal para o P2
    MOV AX, [p2_x]
    SUB AX, [p1_x]
    CMP AX, 45
    JG fim_soco_p2

    ; Verifica se o P1 está defendendo (no ar ou agachado)
    CMP word [p1_y], 115
    JG fim_soco_p2
    CMP byte [p1_estado], 1
    JE fim_soco_p2

    ; Aplica dano no P1
    CMP word [energia_p1], 0
    JE fim_soco_p2
    DEC word [energia_p1]
    CALL status_jogadores
fim_soco_p2:
    RET
reseta_soco_p2:
    MOV byte [soco_p2_travado], 0
    RET

; ==================================================
; ROTINA: CHUTE DO PLAYER 2 (Tecla N)
; ==================================================
verifica_chute_p2:
    CMP byte [key_n], 1             ; Verifica se a tecla N está pressionada
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
