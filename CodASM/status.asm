; RESUMO: Módulo responsável pela interface de texto e HUD (Heads-Up Display)
; do jogo. Gerencia a exibição dos nomes dos lutadores ("JOGADOR 1", "VS", 
; "JOGADOR 2") e desenha as barras de energia em tempo real com base nos 
; pontos de vida atuais de cada jogador, utilizando primitivas de pixels 
; e interrupções de vídeo da BIOS.

segment code

; Exportar todas as funções do módulo
global status_jogadores
global escrever_na_tela
global barra_de_energia
global quadrado

; Exportar variáveis globais de texto e controle de coordenadas/desenho
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

; FUNÇÃO: STATUS_JOGADORES
; Desenha os nomes, o marcador "VS" e atualiza as barras 
; de energia de ambos os jogadores na tela.
status_jogadores:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    ; Escreve o nome do Jogador 1 
    MOV BP, jogador1
    MOV CX, 9               ; Quantidade de caracteres da string
    MOV DH, 3               ; Linha 3 da tela de texto
    MOV DL, 12              ; Coluna 12 (equivalente ao pixel 96)
    MOV BL, 0Ah             ; Atributo de cor (verde claro)
    CALL escrever_na_tela

    ; Escreve o marcador "VS" no centro da tela 
    MOV BP, versus
    MOV CX, 2               ; 2 caracteres
    MOV DH, 3               ; Mesma linha dos nomes
    MOV DL, 39              ; Coluna 39 (centro da tela / pixel 312)
    MOV BL, 0Ch             ; Atributo de cor (vermelho claro)
    CALL escrever_na_tela

    ; Escreve o nome do Jogador 2 
    MOV BP, jogador2
    MOV CX, 9
    MOV DH, 3               ; Mesma linha
    MOV DL, 59              ; Coluna 59 (equivalente ao pixel 472)
    MOV BL, 0Ah             ; Verde claro
    CALL escrever_na_tela

    ; Renderiza a barra de energia do Jogador 1 
    MOV WORD [baseX], 35    ; Posição horizontal inicial da barra 1
    MOV WORD [baseY], 80    ; Posição vertical da barra
    MOV AX, [energia_p1]
    MOV [energia_atual], AX
    MOV WORD [baseX], 35
    CALL barra_de_energia

    ; Renderiza a barra de energia do Jogador 2 
    MOV WORD [baseX], 412   ; Posição horizontal inicial da barra 2
    MOV WORD [baseY], 80    ; Posição vertical da barra
    MOV AX, [energia_p2]
    MOV [energia_atual], AX
    CALL barra_de_energia

    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET


; FUNÇÃO: ESCREVER_NA_TELA
; Utiliza a interrupção de vídeo da BIOS para escrever strings formatadas.
; Entrada (via registradores):
;   BP = Endereço da string na memória
;   CX = Quantidade de caracteres
;   DH = Linha
;   DL = Coluna
;   BL = Atributo/Cor do texto
escrever_na_tela:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP
    PUSH ES

    MOV AX, DS
    MOV ES, AX              ; ES:BP aponta corretamente para o texto no segmento de dados

    MOV AH, 13h             ; Função da BIOS para escrever string
    MOV AL, 01h             ; Modo de escrita (atualiza cursor e usa atributo de BL)
    MOV BH, 00h             ; Página de vídeo 0
    INT 10h                 ; Chama a interrupção gráfica/texto da BIOS

    POP ES
    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET


; FUNÇÃO: BARRA_DE_ENERGIA
; Desenha dez blocos (quadrados) alinhados horizontalmente 
; representando a vida restante do lutador.
barra_de_energia:
    PUSH AX
    PUSH BX
    PUSH DX                 ; A instrução MUL altera o registrador DX

    MOV WORD [contador], 0  ; Inicia o contador do bloco 0 ao 9

proximo_quadrado:
    CMP WORD [contador], 10     ; Verifica se já desenhou os 10 blocos da barra
    JAE fim_barra

    ; Calcula a posição X do quadrado atual (baseX + contador * 20 pixels de espaçamento)
    MOV AX, [contador]
    MOV BX, 20
    MUL BX
    ADD AX, [baseX]
    MOV [xAtual], AX

    MOV AX, [baseY]
    MOV [yAtual], AX

    ; Define a cor do bloco: Verde (0Ah) se ainda tem vida, Preto (0) se já perdeu
    MOV AX, [contador]
    CMP AX, [energia_atual]
    JAE s_cor_preta
    MOV byte [cor_quadrado], 0Ah 
    JMP s_desenha

s_cor_preta:
    MOV byte [cor_quadrado], 0      ; Bloco apagado (vazio)

s_desenha:
    CALL quadrado                   ; Desenha o quadrado individual na tela
    INC WORD [contador]
    JMP proximo_quadrado

fim_barra:
    POP DX
    POP BX
    POP AX
    RET


; FUNÇÃO: QUADRADO
; Desenha um bloco sólido de 13 x 13 pixels na tela gráfica
; utilizando a cor especificada em [cor_quadrado].
quadrado:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV WORD [linhaPixel], 0

linha_quadrado:
    MOV AX, [linhaPixel]
    CMP AX, 13              ; Altura total do quadrado (13 pixels)
    JAE fim_quadrado

    MOV WORD [colunaPixel], 0

coluna_quadrado:
    MOV AX, [colunaPixel]
    CMP AX, 13              ; Largura total do quadrado (13 pixels)
    JAE proxima_linha

    ; Calcula a coordenada X absoluta do pixel atual
    MOV AX, [xAtual]
    ADD AX, [colunaPixel]
    MOV CX, AX

    ; Calcula a coordenada Y absoluta do pixel atual
    MOV AX, [yAtual]
    ADD AX, [linhaPixel]
    MOV DX, AX

    ; Desenha o pixel na tela gráfica usando a BIOS (INT 10h / AH=0Ch)
    MOV AH, 0Ch
    MOV AL, [cor_quadrado]  ; Cor do pixel
    MOV BH, 0               ; Página de vídeo
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
energia_p1 dw 10            ; Pontos de energia iniciais do Jogador 1 (10 rounds/hits)
energia_p2 dw 10            ; Pontos de energia iniciais do Jogador 2
energia_atual dw 10
cor_quadrado db 0Ah

; Strings estáticas de texto da HUD
jogador1    db 'JOGADOR 1'
versus      db 'VS'
jogador2    db 'JOGADOR 2'

; Coordenadas de posicionamento das barras na tela
baseX       dw 0
baseY       dw 0

; Coordenadas dinâmicas do bloco atual sendo desenhado
xAtual      dw 0
yAtual      dw 0

; Variáveis auxiliares de controle de loops internos
contador    dw 0
linhaPixel  dw 0
colunaPixel dw 0