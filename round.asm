; =====================================================================
; ARQUIVO: round.asm  (versão corrigida)
; RESUMO: Gerencia a execução de um round.
; Controla o ciclo de combate, bloqueia entradas pré-round e determina
; o vencedor ao término do tempo (3 min) ou por nocaute (KO).
;
; TEMPORIZAÇÃO: o framerate e o bloqueio pré-round usam o contador de
; ticks do BIOS (0040:006Ch, incrementado pela IRQ0 do PIT), sem laços
; de atraso por software.
;
; Retorno em AX:
;   0 = Empate
;   1 = Vitória do Jogador 1
;   2 = Vitória do Jogador 2
;   3 = Jogador apertou Q (a MAIN deve chamar game_over)
;
; Uso pela MAIN:
;   - Round novo:   zerar 'round_retomando' (=0), restaurar as energias
;                   e chamar round.
;   - Após Q:       chamar game_over; se AX = 0 (cancelou), setar
;                   'round_retomando' = 1 e chamar round de novo.
;                   (energias e timer são mantidos; a tela é redesenhada)
; =====================================================================

pre_round_ticks     equ 18      ; ~1 s de bloqueio de teclas em round novo
retomada_ticks      equ 5       ; ~0,3 s ao retomar depois do game_over

segment data
    global vencedor_round, round_retomando
    vencedor_round  dw 0        ; 0 = Empate, 1 = P1 Venceu, 2 = P2 Venceu
    round_retomando dw 0        ; 0 = round novo, 1 = retomando após Q/N
    resultado       dw 0        ; valor devolvido em AX
    ult_frame       dw 0        ; último tick usado para sincronizar o frame
    base_tick       dw 0        ; tick de referência do bloqueio pré-round

segment code
    global round

    extern atualiza_movimento, verifica_ataques
    extern apaga_lutadores, desenha_cenario
    extern render_p1, render_p2, status_jogadores
    extern timer, desenha_timer, reset_timer, retoma_timer

    extern energia_p1, energia_p2
    extern key_a, key_d, key_left, key_right
    extern key_w, key_s, key_up, key_down
    extern key_t, key_m, key_n, key_r
    extern key_q

; =====================================================================
; FUNÇÃO CENTRAL: ROUND
; =====================================================================
round:
    PUSHA

    ; --- Round novo x retomada ---
    CMP word [round_retomando], 0
    JNE .retomando
    CALL reset_timer            ; round novo: 03:00
    MOV CX, pre_round_ticks
    JMP .pre_round
.retomando:
    CALL retoma_timer           ; mantém o tempo; só ressincroniza o tick base
    MOV CX, retomada_ticks

.pre_round:
    MOV word [round_retomando], 0

    ; --- Bloqueio de teclas pré-round: durante CX ticks, descarta todas
    ;     as entradas (inclusive Q), medido pelo relógio do PC ---
    CALL le_tick_round
    MOV [base_tick], AX
.bloqueio:
    CALL reseta_teclas_entrada
    CALL le_tick_round
    SUB AX, [base_tick]
    CMP AX, CX
    JB .bloqueio

    ; --- Frame inicial (a tela pode ter sido limpa pelo game_over) ---
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores
    CALL desenha_timer

    CALL le_tick_round
    MOV [ult_frame], AX

; =====================================================================
; LAÇO PRINCIPAL DO ROUND
; =====================================================================
.loop_round:
    CALL espera_frame           ; sincroniza com o relógio do PC (PIT)

    ; --- Tecla Q: sai do round SEM computar vencedor ---
    CMP byte [key_q], 1
    JNE .combate
    MOV word [resultado], 3
    JMP .fim

.combate:
    CALL verifica_ataques

    CALL apaga_lutadores
    CALL atualiza_movimento

    CALL limita_energia         ; energia nunca fica negativa

    ; Ordem de desenho: cenário primeiro, lutadores por cima
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores

    ; --- Timer ---
    CALL timer
    CMP AX, 1
    JE .avalia                  ; tempo esgotado

    ; --- Nocaute (comparação com sinal: <= 0) ---
    CMP word [energia_p1], 0
    JLE .avalia
    CMP word [energia_p2], 0
    JLE .avalia

    JMP .loop_round

; =====================================================================
; AVALIAÇÃO DO VENCEDOR
; =====================================================================
.avalia:
    MOV AX, [energia_p1]
    CMP AX, [energia_p2]
    JE .empate
    JG .p1_venceu
    MOV word [vencedor_round], 2
    JMP .grava
.empate:
    MOV word [vencedor_round], 0
    JMP .grava
.p1_venceu:
    MOV word [vencedor_round], 1
.grava:
    MOV AX, [vencedor_round]
    MOV [resultado], AX

.fim:
    POPA
    MOV AX, [resultado]         ; POPA restaurou AX; carrega o retorno agora
    RET

; =====================================================================
; ESPERA_FRAME: bloqueia até o contador de ticks do BIOS mudar (~55 ms)
; =====================================================================
espera_frame:
    PUSH AX
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
.espera:
    MOV AX, [ES:006Ch]
    CMP AX, [ult_frame]
    JE .espera
    MOV [ult_frame], AX
    POP ES
    POP AX
    RET

; =====================================================================
; LE_TICK_ROUND: AX = word baixa do contador de ticks do BIOS
; =====================================================================
le_tick_round:
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
    MOV AX, [ES:006Ch]
    POP ES
    RET

; =====================================================================
; LIMITA_ENERGIA: se energia < 0, fixa em 0 (valores com sinal)
; =====================================================================
limita_energia:
    CMP word [energia_p1], 0
    JGE .p2
    MOV word [energia_p1], 0
.p2:
    CMP word [energia_p2], 0
    JGE .ok
    MOV word [energia_p2], 0
.ok:
    RET

; =====================================================================
; RESETA_TECLAS_ENTRADA: zera todas as flags de entrada (inclui Q)
; =====================================================================
reseta_teclas_entrada:
    MOV byte [key_a], 0
    MOV byte [key_d], 0
    MOV byte [key_left], 0
    MOV byte [key_right], 0
    MOV byte [key_w], 0
    MOV byte [key_s], 0
    MOV byte [key_up], 0
    MOV byte [key_down], 0
    MOV byte [key_t], 0
    MOV byte [key_m], 0
    MOV byte [key_n], 0
    MOV byte [key_r], 0
    MOV byte [key_q], 0
    RET