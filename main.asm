; =====================================================================
; ARQUIVO: main.asm  (versão corrigida)
; RESUMO: Módulo principal do jogo de luta em Assembly x86 16-bit.
; Orquestra a inicialização do vídeo VGA 12h, a seleção de cores,
; o ciclo fixo de 3 rounds (ini_round -> round -> end_round),
; a pausa/confirmação de saída e o encerramento seguro.
; =====================================================================

segment code
    ; Hardware e menus
    extern instala_teclado, restaura_teclado
    extern MENU_INICIAL

    ; Módulos de rounds e pausa
    extern ini_round, round, end_round, game_over
    extern reset_timer

    ; Variáveis globais de estado
    extern energia_p1, energia_p2, round_retomando

..start:
    ; -------------------------------------------------------------
    ; 1. INICIALIZAÇÃO DO SISTEMA E SEGMENTOS
    ; -------------------------------------------------------------
    MOV AX, data
    MOV DS, AX

    CLI                         ; troca de pilha sem interrupção no meio
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop
    STI

    ; Instala a rotina customizada da interrupção de teclado (INT 9h)
    CALL instala_teclado

    ; Salva o modo de vídeo atual e configura o Modo Gráfico VGA 640x480 (12h)
    MOV AH, 0Fh
    INT 10h
    AND AL, 7Fh                 ; descarta o bit 7 (flag "não limpar tela")
    MOV [modo_anterior], AL
    MOV AX, 0012h
    INT 10h

    ; -------------------------------------------------------------
    ; 2. MENU INICIAL DE SELEÇÃO DE CORES
    ;    (o primeiro frame é desenhado por ini_round)
    ; -------------------------------------------------------------
    CALL MENU_INICIAL

    MOV word [numero_do_round], 1

; =====================================================================
; 3. LAÇO DOS 3 ROUNDS DA PARTIDA
; =====================================================================
loop_partida:
    ; --- A. PREPARAÇÃO DO ROUND NOVO ---
    MOV word [energia_p1], 10
    MOV word [energia_p2], 10
    MOV word [round_retomando], 0
    CALL reset_timer            ; HUD já mostra 03:00 durante a contagem

    ; --- B. ANIMAÇÃO DE INÍCIO (3... 2... 1... ROUND N!) ---
    MOV AX, [numero_do_round]
    CALL ini_round

executa_combate:
    ; --- C. COMBATE ATIVO ---
    CALL round                  ; AX: 0 = Empate, 1 = P1, 2 = P2, 3 = Tecla Q

    ; --- D. TECLA Q (GAME OVER / PAUSA) ---
    CMP AX, 3
    JE  trata_pausa

    ; --- E. FIM DO ROUND (stdcall, end_round limpa a pilha com RET 4) ---
    PUSH word [numero_do_round] ; [BP+6]
    PUSH AX                     ; [BP+4]
    CALL end_round

    ; --- F. FIM DOS 3 ROUNDS? ---
    CMP word [numero_do_round], 3
    JGE encerra_jogo

    INC word [numero_do_round]
    JMP loop_partida

; -------------------------------------------------------------
; TRATAMENTO DA TECLA Q (CONFIRMAÇÃO DE SAÍDA)
; -------------------------------------------------------------
trata_pausa:
    CALL game_over              ; AX: 1 = Y (sair), 0 = N (cancelou)
    CMP AX, 1
    JE  encerra_jogo

    MOV word [round_retomando], 1   ; retoma o round atual (tempo e energia mantidos)
    JMP executa_combate

; =====================================================================
; 4. ENCERRAMENTO E RESTAURAÇÃO DO SISTEMA
; =====================================================================
encerra_jogo:
    CALL restaura_teclado       ; restaura a INT 9h original
    MOV AH, 0
    MOV AL, [modo_anterior]     ; restaura o modo de vídeo original (03h)
    INT 10h
    MOV AX, 4C00h               ; volta ao DOS
    INT 21h

; =====================================================================
; SEGMENTO DE DADOS E PILHA
; =====================================================================
segment data
    modo_anterior   db 0
    numero_do_round dw 1        ; contador de 1 a 3

segment stack stack
    resb 2048
stacktop: