; =====================================================================
; ARQUIVO: ini_round.asm  (versão corrigida)
; RESUMO: Animação/contagem regressiva de início de round:
;         3... 2... 1... ROUND N!
;
; Parâmetro: AX = número do round (1 a 9). Retorno normal (RET).
;
; TEMPORIZAÇÃO: cada etapa dura 18 ticks do BIOS (0040:006Ch, IRQ0 do
; PIT, ~1 s), sem laços de atraso por software.
; =====================================================================

; Como apagar o texto de cada etapa:
;   1 = reescreve o mesmo texto em preto (rápido, sem flicker; use se o
;       fundo da região central for preto)
;   0 = redesenha cenário + lutadores + HUD (use se o fundo for colorido;
;       exige que desenha_cenario repinte a área central)
%assign APAGA_COM_PRETO 1

linha_msg           equ 14      ; centro vertical (30 linhas de texto)
ticks_espera        equ 18      ; ~1 segundo por etapa (18,2 Hz)

segment data
    num_round_str   db 'ROUND  !'       ; 8 caracteres; o dígito entra em +6
    txt_3           db '3'
    txt_2           db '2'
    txt_1           db '1'
    ult_tick_ini    dw 0

segment code
    global ini_round
    extern escrever_na_tela, desenha_cenario, render_p1, render_p2
    extern status_jogadores, desenha_timer

; ---------------------------------------------------------------------
; Macro: mostra um texto, espera 1 s e apaga.
; ptr, tamanho, coluna, cor
; ---------------------------------------------------------------------
%macro ETAPA 4
    MOV BP, %1
    MOV CX, %2
    MOV DH, linha_msg
    MOV DL, %3
    MOV BL, %4
    CALL escreve
    CALL espera_1_segundo
%if APAGA_COM_PRETO
    MOV BL, 0                   ; mesmo texto, mesma posição, em preto
    CALL escreve
%else
    CALL redesenha_base
%endif
%endmacro

; =====================================================================
; FUNÇÃO CENTRAL: INI_ROUND   (AX = número do round)
; =====================================================================
ini_round:
    PUSHA
    PUSH ES

    PUSH DS                     ; ES = DS (INT 10h/13h lê a string em ES:BP)
    POP ES

    ADD AL, '0'                 ; número do round -> ASCII
    MOV [num_round_str + 6], AL

    ; Estado inicial do cenário, lutadores e HUD
    CALL redesenha_base

    ETAPA txt_3, 1, 39, 0Ch     ; 3  vermelho claro
    ETAPA txt_2, 1, 39, 0Eh     ; 2  amarelo
    ETAPA txt_1, 1, 39, 0Ah     ; 1  verde claro
    ETAPA num_round_str, 8, 36, 0Fh   ; "ROUND N!" branco, (80-8)/2 = 36

    POP ES
    POPA
    RET

; =====================================================================
; ESCREVE: BP=string, CX=tamanho, DH=linha, DL=coluna, BL=cor
; Preserva todos os registradores, independente de escrever_na_tela.
; =====================================================================
escreve:
    PUSHA
    CALL escrever_na_tela
    POPA
    RET

; =====================================================================
; REDESENHA_BASE: cenário, lutadores, HUD e timer
; =====================================================================
redesenha_base:
    PUSHA
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores
    CALL desenha_timer
    POPA
    RET

; =====================================================================
; ESPERA_1_SEGUNDO: 18 ticks completos do BIOS (~1 s), sem laço de delay.
; Primeiro alinha com a virada de um tick, para a espera não ser curta.
; =====================================================================
espera_1_segundo:
    PUSHA
    CALL le_tick_ini
    MOV BX, AX
.alinha:
    CALL le_tick_ini
    CMP AX, BX
    JE .alinha
    MOV [ult_tick_ini], AX      ; base = início exato de um tick
.loop_espera:
    CALL le_tick_ini
    SUB AX, [ult_tick_ini]
    CMP AX, ticks_espera
    JB .loop_espera
    POPA
    RET

; AX = word baixa do contador de ticks do BIOS
le_tick_ini:
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
    MOV AX, [ES:006Ch]
    POP ES
    RET