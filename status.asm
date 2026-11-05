
segment code

; Exportar todas as funcoes
global status_jogadores
global escrever_na_tela
global barra_de_energia
global quadrado

; Exportar todas as variaveis
global jogador1
global jogador2
global versus
global baseX
global baseY
global xAtual
global yAtual
global contador
global linhaPixel
global colunaPixel

extern vitorias_p1, vitorias_p2

; ==================================================
; FUNCAO: STATUS_JOGADORES
; Desenha os nomes, o VS e as barras de energia
; ==================================================
status_jogadores:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    ; Nome do jogador 1 (centralizado sobre a barra 1)
    MOV BP, jogador1
    MOV CX, 9
    MOV DH, 3               ; linha 3
    MOV DL, 12              ; coluna 12 = pixel 96
    MOV BL, 0Ah
    CALL escrever_na_tela

    ; VS (centro da tela)
    MOV BP, versus
    MOV CX, 2
    MOV DH, 3               ; mesma linha dos nomes
    MOV DL, 39              ; coluna 39 = pixel 312
    MOV BL, 0Ch
    CALL escrever_na_tela

    ; Nome do jogador 2 (centralizado sobre a barra 2)
    MOV BP, jogador2
    MOV CX, 9
    MOV DH, 3               ; mesma linha
    MOV DL, 59              ; coluna 59 = pixel 472
    MOV BL, 0Ah
    CALL escrever_na_tela

    ; Barra do jogador 1 (pixels 35 a 228)
    MOV WORD [baseX], 35
    MOV WORD [baseY], 80
    MOV AX, [energia_p1]
    MOV [energia_atual], AX
    MOV WORD [baseX], 35
    CALL barra_de_energia

    ; Barra do jogador 2 (pixels 412 a 605)
    MOV WORD [baseX], 412
    MOV WORD [baseY], 80
    MOV AX, [energia_p2]
    MOV [energia_atual], AX
    CALL barra_de_energia

    ; Placar P1 (Abaixo do nome do P1, próximo ao centro)
    ; Primeiro Marcador P1
    MOV BP, vazio
    CMP word [vitorias_p1], 0  ; Se tem 0 vitórias, desenha vazio
    JE .r1_p1_vazio
    MOV BP, cheio              ; Se tem 1 ou mais, desenha cheio
.r1_p1_vazio:
    MOV CX, 1
    MOV DH, 6                  ; linha 6 (abaixo da vida)
    MOV DL, 34                 ; Coluna 34 (perto do meio da tela)
    MOV BL, 0Eh                ; Amarelo
    CALL escrever_na_tela

    ; Segundo Marcador P1
    MOV BP, vazio
    CMP word [vitorias_p1], 2  ; Se tem menos de 2 vitórias, desenha vazio
    JL .r2_p1_vazio
    MOV BP, cheio              ; Se tem 2 vitórias, desenha cheio
.r2_p1_vazio:
    MOV CX, 1
    MOV DH, 6                  
    MOV DL, 32                 ; Coluna 32 (à esquerda do primeiro marcador)
    MOV BL, 0Eh
    CALL escrever_na_tela


    ; Placar P2 (Abaixo do nome do P2, simétrico ao P1)
    ; Primeiro Marcador P2
    MOV BP, vazio
    CMP word [vitorias_p2], 0  ; Se tem 0 vitórias, desenha vazio
    JE .r1_p2_vazio
    MOV BP, cheio
.r1_p2_vazio:
    MOV CX, 1
    MOV DH, 6
    MOV DL, 45                 ; Coluna 45
    MOV BL, 0Eh
    CALL escrever_na_tela

    ; Segundo Marcador P2
    MOV BP, vazio
    CMP word [vitorias_p2], 2
    JL .r2_p2_vazio
    MOV BP, cheio
.r2_p2_vazio:
    MOV CX, 1
    MOV DH, 6
    MOV DL, 47                 ; Coluna 47 (à direita do primeiro marcador)
    MOV BL, 0Eh
    CALL escrever_na_tela

    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET


; ==================================================
; FUNCAO: ESCREVER_NA_TELA
; Entrada:
;   BP = endereco do texto
;   CX = quantidade de caracteres
;   DH = linha
;   DL = coluna
;   BL = cor
; ==================================================
escrever_na_tela:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH ES

    MOV AX, DS
    MOV ES, AX              ; ES:BP aponta para o texto

    MOV AH, 13h
    MOV AL, 01h
    MOV BH, 00h
    INT 10h

    POP ES
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET


; ==================================================
; FUNCAO: BARRA_DE_ENERGIA
; Desenha dez quadrados alinhados horizontalmente
; ==================================================
barra_de_energia:
    PUSH AX
    PUSH BX
    PUSH DX                 ; MUL BX altera DX

    MOV WORD [contador], 0

proximo_quadrado:
    CMP WORD [contador], 10     ; Sempre percorre os 10 blocos
    JAE fim_barra

    MOV AX, [contador]
    MOV BX, 20
    MUL BX
    ADD AX, [baseX]
    MOV [xAtual], AX

    MOV AX, [baseY]
    MOV [yAtual], AX

    ; Define cor: Verde (0Ah) se ainda tem vida, Preto (0) se já perdeu
    MOV AX, [contador]
    CMP AX, [energia_atual]
    JAE s_cor_preta
    MOV byte [cor_quadrado], 0Ah 
    JMP s_desenha

s_cor_preta:
    MOV byte [cor_quadrado], 0

s_desenha:
    CALL quadrado
    INC WORD [contador]
    JMP proximo_quadrado

fim_barra:
    POP DX
    POP BX
    POP AX
    RET


; ==================================================
; FUNCAO: QUADRADO
; Desenha um quadrado verde de 13 x 13 pixels
; ==================================================
quadrado:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV WORD [linhaPixel], 0

linha_quadrado:
    MOV AX, [linhaPixel]
    CMP AX, 13
    JAE fim_quadrado

    MOV WORD [colunaPixel], 0

coluna_quadrado:
    MOV AX, [colunaPixel]
    CMP AX, 13
    JAE proxima_linha

    ; X do pixel
    MOV AX, [xAtual]
    ADD AX, [colunaPixel]
    MOV CX, AX

    ; Y do pixel
    MOV AX, [yAtual]
    ADD AX, [linhaPixel]
    MOV DX, AX

    ; Desenhar pixel verde
    MOV AH, 0Ch
    MOV AL, [cor_quadrado]
    MOV BH, 0
    INT 10h

    INC WORD [colunaPixel]
    JMP coluna_quadrado

proxima_linha:
    INC WORD [linhaPixel]
    JMP linha_quadrado

fim_quadrado:
    POP DX
    POP CX
    POP BX
    POP AX
    RET


segment data

global energia_p1, energia_p2
energia_p1 dw 10
energia_p2 dw 10
energia_atual dw 10
cor_quadrado db 0Ah

; Textos
jogador1    db 'JOGADOR 1'
versus      db 'VS'
jogador2    db 'JOGADOR 2'

; Coordenadas das barras
baseX       dw 0
baseY       dw 0

; Coordenadas do quadrado atual
xAtual      dw 0
yAtual      dw 0

; Variáveis para o placar de rounds ganhos
vazio       db 'O'      ; Marcador de round não ganho
cheio       db 'X'      ; Marcador de round ganho

; Variaveis de controle
contador    dw 0
linhaPixel  dw 0
colunaPixel dw 0
