; =====================================================================
; ARQUIVO: end_round.asm  (versão corrigida)
; RESUMO: Exibe a tela de encerramento do round.
; Recebe via pilha (stdcall, o próprio módulo limpa com RET 4):
;   PUSH word [num_round]    ; [BP+6]  número do round (1 a 9)
;   PUSH word [vencedor]     ; [BP+4]  0 = Empate, 1 = P1, 2 = P2
;   CALL end_round
; Qualquer outro valor de vencedor (ex.: 3 = Q) NÃO exibe nada.
;
; TEMPORIZAÇÃO: ~2 s medidos em ticks do BIOS (0040:006Ch, IRQ0 do PIT),
; sem laços de atraso por software.
; =====================================================================

; Como apagar os textos ao final:
;   1 = reescreve os mesmos textos em preto (sem flicker; use se o fundo
;       da região central for preto)
;   0 = redesenha cenário + lutadores + HUD (use se o fundo for colorido;
;       exige que desenha_cenario repinte as linhas 11 a 14)
%assign APAGA_COM_PRETO 1

ticks_espera_end    equ 36      ; ~2 s (18,2 Hz * 2)

segment data
    txt_fim_round   db 'FIM DO 1 ROUND'         ; 14 caracteres; o dígito está em +7
    txt_vit_p1      db 'VITORIA DO JOGADOR 1'   ; 20
    txt_vit_p2      db 'VITORIA DO JOGADOR 2'   ; 20
    txt_empate      db 'EMPATE!'                ;  7

    ult_tick_end    dw 0

    ; Parâmetros copiados da pilha (BP é usado pela escrita de texto)
    num_round_val   dw 0
    vencedor_val    dw 0

    ; Segunda mensagem escolhida conforme o vencedor
    msg2_ptr        dw 0
    msg2_len        dw 0
    msg2_col        db 0
    msg2_cor        db 0

segment code
    global end_round
    extern escrever_na_tela, desenha_cenario, render_p1, render_p2
    extern status_jogadores, desenha_timer

; ---------------------------------------------------------------------
; Macro: escreve texto fixo. ptr, tamanho, linha, coluna, cor
; Se DI = 0, escreve em preto (apaga); se DI <> 0, usa a cor pedida.
; ---------------------------------------------------------------------
%macro MSG 5
    MOV BP, %1
    MOV CX, %2
    MOV DH, %3
    MOV DL, %4
    MOV BL, %5
    TEST DI, DI
    JNZ %%com_cor
    XOR BL, BL
%%com_cor:
    CALL escreve
%endmacro

; =====================================================================
; FUNÇÃO CENTRAL: END_ROUND
; =====================================================================
end_round:
    PUSH BP
    MOV BP, SP
    PUSHA
    PUSH ES

    ; 1. Copia os parâmetros ANTES de BP ser reutilizado
    MOV AX, [BP+6]
    MOV [num_round_val], AX
    MOV AX, [BP+4]
    MOV [vencedor_val], AX

    PUSH DS                     ; ES = DS (INT 10h/13h lê a string em ES:BP)
    POP ES

    ; 2. Vencedor inválido (ex.: 3 = Q): não exibe nada
    CMP word [vencedor_val], 2
    JA .fim

    ; 3. Formata "FIM DO N ROUND"
    MOV AX, [num_round_val]
    ADD AL, '0'
    MOV [txt_fim_round + 7], AL

    ; 4. Escolhe a segunda mensagem
    CMP word [vencedor_val], 1
    JE .vit_p1
    CMP word [vencedor_val], 2
    JE .vit_p2

    MOV word [msg2_ptr], txt_empate         ; Empate: vermelho claro
    MOV word [msg2_len], 7
    MOV byte [msg2_col], 36                 ; (80-7)/2 = 36
    MOV byte [msg2_cor], 0Ch
    JMP .mostra
.vit_p1:
    MOV word [msg2_ptr], txt_vit_p1         ; Vitória P1: verde claro
    MOV word [msg2_len], 20
    MOV byte [msg2_col], 30                 ; (80-20)/2 = 30
    MOV byte [msg2_cor], 0Ah
    JMP .mostra
.vit_p2:
    MOV word [msg2_ptr], txt_vit_p2         ; Vitória P2: verde claro
    MOV word [msg2_len], 20
    MOV byte [msg2_col], 30
    MOV byte [msg2_cor], 0Ah

.mostra:
    ; 5. Fundo limpo (cenário, lutadores, HUD e timer)
    CALL redesenha_base_end

    ; 6. Exibe as mensagens
    MOV DI, 1
    CALL desenha_msgs

    ; 7. Mantém na tela por ~2 s (relógio do PC)
    CALL espera_end_round

    ; 8. Apaga as mensagens
%if APAGA_COM_PRETO
    XOR DI, DI
    CALL desenha_msgs
%else
    CALL redesenha_base_end
%endif

.fim:
    POP ES
    POPA
    POP BP
    RET 4                       ; remove os 2 parâmetros (2 * 2 bytes)

; =====================================================================
; DESENHA_MSGS: DI = 1 desenha colorido, DI = 0 apaga (preto)
; Linha 11: "FIM DO N ROUND" (amarelo)   Linha 14: vitória/empate
; =====================================================================
desenha_msgs:
    PUSHA

    MSG txt_fim_round, 14, 11, 33, 0Eh      ; (80-14)/2 = 33

    MOV BP, [msg2_ptr]
    MOV CX, [msg2_len]
    MOV DH, 14
    MOV DL, [msg2_col]
    MOV BL, [msg2_cor]
    TEST DI, DI
    JNZ .com_cor
    XOR BL, BL
.com_cor:
    CALL escreve

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
; REDESENHA_BASE_END: cenário, lutadores, HUD e timer
; =====================================================================
redesenha_base_end:
    PUSHA
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores
    CALL desenha_timer
    POPA
    RET

; =====================================================================
; ESPERA_END_ROUND: 36 ticks completos do BIOS (~2 s). Alinha primeiro
; com a virada de um tick para a espera não ficar curta.
; =====================================================================
espera_end_round:
    PUSHA
    CALL le_tick_end
    MOV BX, AX
.alinha:
    CALL le_tick_end
    CMP AX, BX
    JE .alinha
    MOV [ult_tick_end], AX
.loop_espera:
    CALL le_tick_end
    SUB AX, [ult_tick_end]
    CMP AX, ticks_espera_end
    JB .loop_espera
    POPA
    RET

; AX = word baixa do contador de ticks do BIOS
le_tick_end:
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
    MOV AX, [ES:006Ch]
    POP ES
    RET