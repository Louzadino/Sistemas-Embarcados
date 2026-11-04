; =====================================================================
; ARQUIVO: timer.asm  (versão corrigida)
; RESUMO: Contagem regressiva do jogo (MM:SS) desenhada na HUD.
;
; TEMPORIZAÇÃO: usa o contador de ticks do BIOS em 0040:006Ch, que é
; incrementado pela IRQ0 do PIT 8253/8254 (canal 0, ~18,2065 Hz) em
; qualquer PC/XT/AT. O tempo passa em tempo real, independente da
; velocidade da CPU e do framerate do game loop, sem laços de atraso.
;
; Funções:
;   reset_timer   : reinicia em 03:00 (chame antes de cada partida)
;   timer         : atualiza o relógio; AX = 1 se chegou a 00:00, senão 0
;   desenha_timer : redesenha a string atual (chame a cada frame se o
;                   seu loop limpa a tela; 'timer' já chama por você)
; =====================================================================

; 18,2065 ticks/s * 5 = 91,03  ->  91 "meio-ticks" (ticks*5) = 5 s / 5
; Acumulamos ticks*5 e descontamos 91 por segundo (erro < 0,04 %).
ticks_x5_por_seg    equ 91
max_delta_ticks     equ 200         ; limita saltos (pausa, travamento)
cor_timer           equ 0Ch 

segment data
    minutos         dw 3
    segundos        dw 0
    ult_tick        dw 0            ; última leitura do contador do BIOS
    acc_ticks       dw 0            ; acumulador (ticks * 5)
    iniciado        db 0            ; 0 = ainda não leu o tick inicial

    str_timer       db '03:00'      ; texto exibido (5 caracteres)

segment code
    global timer, desenha_timer, reset_timer
    extern escrever_na_tela

; =====================================================================
; RESET_TIMER: volta para 03:00
; =====================================================================
reset_timer:
    MOV word [minutos], 3
    MOV word [segundos], 0
    MOV word [acc_ticks], 0
    MOV byte [iniciado], 0          ; o próximo 'timer' relê o tick base
    MOV byte [str_timer + 0], '0'
    MOV byte [str_timer + 1], '3'
    MOV byte [str_timer + 3], '0'
    MOV byte [str_timer + 4], '0'
    RET

; =====================================================================
; TIMER
; Retorna: AX = 1 se o tempo ACABOU (00:00), AX = 0 se ainda HÁ TEMPO.
; =====================================================================
timer:
    PUSH BX
    PUSH CX
    PUSH DX

    ; Primeira chamada após o reset: só registra o tick de referência
    CMP byte [iniciado], 1
    JE .ja_iniciado
    CALL le_tick
    MOV [ult_tick], AX
    MOV byte [iniciado], 1
.ja_iniciado:

    ; Já zerado antes? Só redesenha e sinaliza.
    MOV AX, [minutos]
    OR AX, [segundos]
    JZ .desenha

    ; --- ticks decorridos desde a última chamada (aritmética de 16 bits
    ;     módulo 65536: correta mesmo quando o contador dá a volta) ---
    CALL le_tick
    MOV DX, AX
    SUB DX, [ult_tick]
    MOV [ult_tick], AX
    CMP DX, max_delta_ticks
    JBE .delta_ok
    MOV DX, max_delta_ticks
.delta_ok:
    MOV AX, DX
    MOV BX, 5
    MUL BX                          ; AX = delta * 5 (<= 1000)
    ADD [acc_ticks], AX

    XOR CX, CX                      ; CX = 1 se algum segundo passou
.conta:
    CMP word [acc_ticks], ticks_x5_por_seg
    JB .fim_conta
    SUB word [acc_ticks], ticks_x5_por_seg

    CMP CX, 0
    JNE .ja_apagou
    MOV BL, 0                       ; apaga o texto antigo (preto)
    CALL escreve_timer
    MOV CX, 1
.ja_apagou:

    ; --- decrementa 1 segundo ---
    CMP word [segundos], 0
    JNE .dec_seg
    CMP word [minutos], 0
    JE .fim_conta                   ; (proteção; não deve ocorrer)
    DEC word [minutos]
    MOV word [segundos], 59
    JMP .checa_zero
.dec_seg:
    DEC word [segundos]
.checa_zero:
    MOV AX, [minutos]
    OR AX, [segundos]
    JNZ .conta                      ; ainda há tempo: processa mais segundos
    MOV word [acc_ticks], 0         ; chegou a 00:00

.fim_conta:
    CMP CX, 0
    JE .desenha
    CALL formata_timer              ; atualiza 'str_timer'

.desenha:
    CALL desenha_timer              ; escreve em branco

    MOV AX, [minutos]
    OR AX, [segundos]
    JNZ .tem_tempo
    MOV AX, 1                       ; 00:00 -> tempo esgotado (já neste frame)
    JMP .fim
.tem_tempo:
    XOR AX, AX
.fim:
    POP DX
    POP CX
    POP BX
    RET

; =====================================================================
; LE_TICK: AX = word baixa do contador de ticks do BIOS (0040:006C)
; =====================================================================
le_tick:
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
    MOV AX, [ES:006Ch]
    POP ES
    RET

; =====================================================================
; FORMATA_TIMER: converte minutos/segundos para ASCII em 'str_timer'
; =====================================================================
formata_timer:
    PUSH AX
    PUSH BX

    MOV AX, [minutos]
    ADD AL, '0'
    MOV [str_timer + 1], AL         ; "0M"

    MOV AX, [segundos]              ; < 60, então AH = 0 e DIV BL é seguro
    MOV BL, 10
    DIV BL                          ; AL = dezenas, AH = unidades
    ADD AL, '0'
    MOV [str_timer + 3], AL
    ADD AH, '0'
    MOV [str_timer + 4], AH

    POP BX
    POP AX
    RET

; =====================================================================
; DESENHA_TIMER: escreve "MM:SS" em branco (sem parâmetros)
; =====================================================================
desenha_timer:
    PUSH BX
    MOV BL, cor_timer
    CALL escreve_timer
    POP BX
    RET

; =====================================================================
; ESCREVE_TIMER: BL = cor (0 apaga, 0Fh branco)
; Linha 3, coluna 37. Garante ES = DS para o INT 10h/AH=13h (ES:BP).
; =====================================================================
escreve_timer:
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH ES

    PUSH DS
    POP ES

    MOV BP, str_timer
    MOV CX, 5
    MOV DH, 3
    MOV DL, 37
    CALL escrever_na_tela

    POP ES
    POP BP
    POP DX
    POP CX
    POP AX
    RET