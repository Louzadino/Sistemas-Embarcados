; =====================================================================
; ARQUIVO: menu_inicial.asm  (versão corrigida)
; RESUMO: Menu de seleção de cores em duas colunas com círculos coloridos.
;   P1 escolhe via W / S (seta -> à esquerda dos círculos).
;   P2 escolhe via Seta Cima / Seta Baixo (seta <- à direita dos círculos).
;   ENTER confirma (usa a flag 'key_enter', setada pela ISR do teclado).
; Retorna em 'cor_p1' e 'cor_p2' a cor selecionada por cada jogador.
;
; Layout (modo 12h, 640x480, fonte 8x16, y dos círculos contado de baixo):
;   círculo i  -> linha de texto 8 + 3*i  (3 linhas = 48 px = espacamento_y)
;   centro y   -> base_y_circulo - i*48
; =====================================================================

; 0 = os dois jogadores NÃO podem confirmar com a mesma cor
; 1 = cores iguais permitidas
%assign PERMITE_COR_IGUAL 0

; ---------------------------------------------------------------------
; Constantes do layout
; ---------------------------------------------------------------------
pos_x_p1        equ 170     ; X do centro da coluna do P1 (pixels)
pos_x_p2        equ 470     ; X do centro da coluna do P2 (pixels)
base_y_circulo  equ 343     ; Y (de baixo) do centro do círculo 0 = 479 - (8*16+8)
espacamento_y   equ 48      ; 3 linhas de texto (3*16)
raio_disco      equ 16
raio_anel       equ 19      ; anel de seleção (fica fora do disco)
col_seta_p1     equ 17      ; coluna de texto da seta do P1
col_seta_p2     equ 64      ; coluna de texto da seta do P2

segment data
    global cor_p1, cor_p2

    cor_p1          db 10       ; Cor padrão P1 (Verde Claro)  -> índice 1
    cor_p2          db 14       ; Cor padrão P2 (Amarelo)      -> índice 4

    idx_p1          dw 1        ; índice selecionado por P1 (0 a 5)
    idx_p2          dw 4        ; índice selecionado por P2 (0 a 5)
    ult_p1          dw 0FFFFh   ; último índice desenhado (força 1º desenho)
    ult_p2          dw 0FFFFh

    ; 0: 8 (Cinza), 1: 10 (Verde Claro), 2: 11 (Ciano claro),
    ; 3: 13 (Magenta/Rosa claro), 4: 14 (Amarelo), 5: 15 (Branco)
    tabela_cores    db 8, 10, 11, 13, 14, 15

    titulo_menu     db 'ESCOLHA SEU JOGADOR'                    ; 19
    txt_p1          db 'JOGADOR 1'                              ; 9
    txt_p2          db 'JOGADOR 2'                              ; 9
    txt_rodape      db 'PRESSIONE >ENTER< PARA COMECAR A LUTAR' ; 38

    seta_p1         db 0x1A     ; ->
    seta_p2         db 0x1B     ; <-

    ; Travas de navegação (detecção de borda de subida)
    w_travado       db 0
    s_travado       db 0
    up_travado      db 0
    down_travado    db 0

    enter_armado    db 0        ; só aceita ENTER após ele ter sido solto
    cor_salva       db 0        ; backup da variável global 'cor'
    sp_salvo        dw 0        ; backup de SP em torno das chamadas gráficas

segment code
    global MENU_INICIAL

    extern escrever_na_tela, cor
    extern full_circle, circle
    extern key_w, key_s, key_up, key_down, key_enter

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

; ---------------------------------------------------------------------
; Macro: desenha seta + anel de uma coluna para o índice SI.
; idx_var, ptr_seta, coluna_seta, x_circulo
; Selecionado -> branco; os demais -> preto (apaga o que havia antes).
; ---------------------------------------------------------------------
%macro ITEM 4
    MOV BL, 0
    CMP SI, [%1]
    JNE %%nao_sel
    MOV BL, 0Fh
%%nao_sel:
    ; seta: linha = 8 + 3*SI
    MOV AX, SI
    SHL AX, 1
    ADD AX, SI
    ADD AX, 8
    MOV DH, AL
    MOV DL, %3
    MOV BP, %2
    MOV CX, 1
    CALL escreve
    ; anel
    CALL y_do_circulo           ; DX = y
    MOV AX, %4
    MOV CX, raio_anel
    CALL anel
%endmacro

; =====================================================================
; FUNÇÃO CENTRAL: MENU_INICIAL
; =====================================================================
MENU_INICIAL:
    PUSHA
    PUSH ES

    PUSH DS                     ; ES = DS (INT 10h/13h lê a string em ES:BP)
    POP ES

    MOV AL, [cor]               ; guarda a cor global
    MOV [cor_salva], AL

    MOV word [ult_p1], 0FFFFh
    MOV word [ult_p2], 0FFFFh
    MOV byte [enter_armado], 0
    MOV byte [w_travado], 0
    MOV byte [s_travado], 0
    MOV byte [up_travado], 0
    MOV byte [down_travado], 0

    CALL desenha_estatico       ; textos + discos (uma única vez)

loop_menu:
    CALL delay_menu

    CALL processa_input_p1
    CALL processa_input_p2

    ; Só redesenha setas/anéis se alguma seleção mudou
    MOV AX, [idx_p1]
    CMP AX, [ult_p1]
    JNE .redesenha
    MOV AX, [idx_p2]
    CMP AX, [ult_p2]
    JE .sem_mudanca
.redesenha:
    CALL desenha_selecao
.sem_mudanca:

    ; ENTER: precisa ter sido solto ao menos uma vez desde a entrada
    CMP byte [key_enter], 1
    JE .enter_down
    MOV byte [enter_armado], 1
    JMP loop_menu
.enter_down:
    CMP byte [enter_armado], 1
    JNE loop_menu

%if PERMITE_COR_IGUAL = 0
    MOV AX, [idx_p1]
    CMP AX, [idx_p2]
    JE loop_menu                ; mesma cor: ignora o ENTER
%endif

    ; --- Salva as cores escolhidas ---
    MOV BX, [idx_p1]
    MOV AL, [tabela_cores + BX]
    MOV [cor_p1], AL

    MOV BX, [idx_p2]
    MOV AL, [tabela_cores + BX]
    MOV [cor_p2], AL

    CALL apaga_menu

    MOV AL, [cor_salva]         ; restaura a cor global
    MOV [cor], AL

    POP ES
    POPA
    RET

; =====================================================================
; WRAPPERS SEGUROS PARA A BIBLIOTECA GRÁFICA
; (preservam todos os registradores e a pilha, qualquer que seja a
;  convenção de chamada: RET 6 ou cdecl)
; =====================================================================

; escreve: BP=string, CX=tamanho, DH=linha, DL=coluna, BL=cor
escreve:
    PUSHA
    CALL escrever_na_tela
    POPA
    RET

; disco: AX=xc, DX=yc, CX=raio, BL=cor
disco:
    PUSHA
    MOV [cor], BL
    MOV [sp_salvo], SP
    PUSH AX
    PUSH DX
    PUSH CX
    CALL full_circle
    MOV SP, [sp_salvo]
    POPA
    RET

; anel: AX=xc, DX=yc, CX=raio, BL=cor
anel:
    PUSHA
    MOV [cor], BL
    MOV [sp_salvo], SP
    PUSH AX
    PUSH DX
    PUSH CX
    CALL circle
    MOV SP, [sp_salvo]
    POPA
    RET

; y_do_circulo: SI=índice -> DX = base_y_circulo - SI*espacamento_y
y_do_circulo:
    PUSH AX
    MOV AX, SI
    MOV DX, espacamento_y
    MUL DX                      ; DX:AX = AX*DX
    MOV DX, base_y_circulo
    SUB DX, AX
    POP AX
    RET

; =====================================================================
; DESENHO ESTÁTICO (feito uma única vez)
; =====================================================================
desenha_estatico:
    PUSHA

    TEXTO titulo_menu, 19, 3, 30, 0Fh
    TEXTO txt_p1,       9, 6, 17, 0Fh
    TEXTO txt_p2,       9, 6, 55, 0Fh
    TEXTO txt_rodape,  38, 26, 21, 0Fh

    XOR SI, SI
.disco_loop:
    CALL y_do_circulo           ; DX = y
    MOV BL, [tabela_cores + SI]
    MOV CX, raio_disco
    MOV AX, pos_x_p1
    CALL disco
    MOV AX, pos_x_p2
    CALL disco
    INC SI
    CMP SI, 6
    JL .disco_loop

    POPA
    RET

; =====================================================================
; DESENHO DA SELEÇÃO (setas + anéis) — só quando o índice muda
; =====================================================================
desenha_selecao:
    PUSHA

    MOV AX, [idx_p1]
    MOV [ult_p1], AX
    MOV AX, [idx_p2]
    MOV [ult_p2], AX

    XOR SI, SI
.loop:
    ITEM idx_p1, seta_p1, col_seta_p1, pos_x_p1
    ITEM idx_p2, seta_p2, col_seta_p2, pos_x_p2
    INC SI
    CMP SI, 6
    JL .loop

    POPA
    RET

; =====================================================================
; NAVEGAÇÃO DOS JOGADORES (0 a 5)
; =====================================================================
processa_input_p1:
    CMP byte [key_w], 1
    JNE reseta_w_p1
    CMP byte [w_travado], 1
    JE check_s_p1
    MOV byte [w_travado], 1
    CMP word [idx_p1], 0
    JLE check_s_p1
    DEC word [idx_p1]
    JMP check_s_p1
reseta_w_p1:
    MOV byte [w_travado], 0

check_s_p1:
    CMP byte [key_s], 1
    JNE reseta_s_p1
    CMP byte [s_travado], 1
    JE fim_input_p1
    MOV byte [s_travado], 1
    CMP word [idx_p1], 5
    JGE fim_input_p1
    INC word [idx_p1]
    JMP fim_input_p1
reseta_s_p1:
    MOV byte [s_travado], 0
fim_input_p1:
    RET

processa_input_p2:
    CMP byte [key_up], 1
    JNE reseta_up_p2
    CMP byte [up_travado], 1
    JE check_down_p2
    MOV byte [up_travado], 1
    CMP word [idx_p2], 0
    JLE check_down_p2
    DEC word [idx_p2]
    JMP check_down_p2
reseta_up_p2:
    MOV byte [up_travado], 0

check_down_p2:
    CMP byte [key_down], 1
    JNE reseta_down_p2
    CMP byte [down_travado], 1
    JE fim_input_p2
    MOV byte [down_travado], 1
    CMP word [idx_p2], 5
    JGE fim_input_p2
    INC word [idx_p2]
    JMP fim_input_p2
reseta_down_p2:
    MOV byte [down_travado], 0
fim_input_p2:
    RET

; =====================================================================
; Limpa a tela e volta ao modo 640x480
; =====================================================================
apaga_menu:
    PUSH AX
    MOV AH, 00h
    MOV AL, 12h
    INT 10h
    POP AX
    RET

; =====================================================================
; Espera 1 tick do relógio do BIOS (~55 ms), independente da CPU
; =====================================================================
delay_menu:
    PUSH AX
    PUSH ES
    MOV AX, 0040h
    MOV ES, AX
    MOV AX, [ES:006Ch]
.espera:
    CMP AX, [ES:006Ch]
    JE .espera
    POP ES
    POP AX
    RET