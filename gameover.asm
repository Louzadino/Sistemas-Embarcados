; =====================================================================
; ARQUIVO: game_over.asm  (versão corrigida)
; RESUMO: Tela de confirmação de saída / Game Over.
;   Chamada pela main somente quando a tecla 'Q' é pressionada.
;   Lê as teclas 'Y' (Sim) e 'N' (Não) pelas flags da ISR do teclado.
; Retorno em AX:
;   1 = Confirmou saída (encerrar o jogo)
;   0 = Cancelou saída  (a tela foi limpa: a MAIN deve REDESENHAR o jogo)
;
; Layout (modo 12h, texto 80x30, tudo centralizado e igual à imagem):
;   linha 11:  X  GAME OVER  X      (X vermelho, texto branco)
;   linha 15:  TEM CERTEZA QUE DESEJA SAIR?
;   linha 19:  Y - SIM
;   linha 21:  N - NAO
; =====================================================================

segment data
    txt_x           db 'X'
    txt_titulo      db 'GAME OVER'                      ;  9
    txt_pergunta    db 'TEM CERTEZA QUE DESEJA SAIR?'   ; 28
    txt_opcao_y     db 'Y - SIM'                        ;  7
    txt_opcao_n     db 'N - NAO'                        ;  7
    resultado       dw 0

segment code
    global game_over
    extern escrever_na_tela
    extern key_y, key_n, key_q         ; flags setadas pela ISR do teclado

; ---------------------------------------------------------------------
; Macro: escreve texto. ptr, tamanho, linha, coluna, cor
; ---------------------------------------------------------------------
%macro TEXTO 5
    MOV BP, %1
    MOV CX, %2
    MOV DH, %3
    MOV DL, %4
    MOV BL, %5
    CALL escreve
%endmacro

; =====================================================================
; FUNÇÃO CENTRAL: GAME_OVER
; =====================================================================
game_over:
    PUSHA
    PUSH ES

    PUSH DS                     ; ES = DS (INT 10h/13h lê a string em ES:BP)
    POP ES

    ; 1. Limpa a tela (modo gráfico VGA 640x480)
    MOV AX, 0012h
    INT 10h

    ; 2. Desenha a interface
    CALL desenha_interface_game_over

    ; 3. Espera Y e N serem soltas (ignora tecla que já estava pressionada)
.espera_soltar:
    CMP byte [key_y], 0
    JNE .espera_soltar
    CMP byte [key_n], 0
    JNE .espera_soltar

    ; 4. Espera a escolha
.loop_espera_tecla:
    CMP byte [key_y], 1
    JE .confirmou_saida
    CMP byte [key_n], 1
    JE .cancelou_saida
    JMP .loop_espera_tecla

.confirmou_saida:
    MOV word [resultado], 1
    JMP .fim

.cancelou_saida:
    MOV AX, 0012h               ; Limpa a tela
    INT 10h
    
    MOV byte [key_q], 0         ; Reseta a flag key_q antes de retornar para a main
    MOV word [resultado], 0

.fim:
    ; Esvazia o buffer de teclado do BIOS (evita eco/beep após a saída)
.flush:
    MOV AH, 01h
    INT 16h
    JZ .flush_ok
    MOV AH, 00h
    INT 16h
    JMP .flush
.flush_ok:

    POP ES
    POPA
    MOV AX, [resultado]         ; POPA restaurou AX; carrega o retorno agora
    RET

; =====================================================================
; ROTINA: DESENHA_INTERFACE_GAME_OVER
; =====================================================================
desenha_interface_game_over:
    PUSHA

    ; "X  GAME OVER  X" = 15 colunas -> começa na coluna 32
    TEXTO txt_x,      1, 11, 32, 0Ch    ; X vermelho (esquerda)
    TEXTO txt_titulo, 9, 11, 35, 0Fh    ; GAME OVER branco
    TEXTO txt_x,      1, 11, 46, 0Ch    ; X vermelho (direita)

    ; 28 colunas -> começa na coluna 26
    TEXTO txt_pergunta, 28, 15, 26, 0Fh

    ; 7 colunas -> começa na coluna 36
    TEXTO txt_opcao_y, 7, 19, 36, 0Fh
    TEXTO txt_opcao_n, 7, 21, 36, 0Fh

    POPA
    RET

; ---------------------------------------------------------------------
; escreve: BP=string, CX=tamanho, DH=linha, DL=coluna, BL=cor
; Preserva todos os registradores, independente de escrever_na_tela.
; ---------------------------------------------------------------------
escreve:
    PUSHA
    CALL escrever_na_tela
    POPA
    RET
