; RESUMO: Gere o sistema de melhor de 3 rounds, registra as vitórias,
; exibe as mensagens de fim de round e a tela de game over.

segment data
    global vitorias_p1, vitorias_p2, round_atual
    global msg_morte_subita

    vitorias_p1     dw 0
    vitorias_p2     dw 0
    round_atual     dw 1

    ; Mensagens de Round
    msg_r1_p1       db 'ROUND 1 - VITORIA DO PLAYER 1'   ; 29 chars
    msg_r1_p2       db 'ROUND 1 - VITORIA DO PLAYER 2'   ; 29 chars
    msg_r2_p1       db 'ROUND 2 - VITORIA DO PLAYER 1'   ; 29 chars
    msg_r2_p2       db 'ROUND 2 - VITORIA DO PLAYER 2'   ; 29 chars
    msg_r3_p1       db 'ROUND 3 - VITORIA DO PLAYER 1'   ; 29 chars
    msg_r3_p2       db 'ROUND 3 - VITORIA DO PLAYER 2'   ; 29 chars
    
    ; Mensagens de Game Over
    msg_go_titulo   db 'X GAME OVER X'                   ; 13 chars
    msg_go_p1       db 'v VITORIA DO JOGADOR 1 v'        ; 24 chars (use 'v' minúsculo caso não tenha emoji de fogo na sua fonte do DOS)
    msg_go_p2       db 'v VITORIA DO JOGADOR 2 v'        ; 24 chars
    
    msg_go_menu     db 'JOGAR NOVAMENTE?'                ; 16 chars
    msg_go_y        db 'Y - SIM'                         ; 7 chars
    msg_go_n        db 'N - NAO'                         ; 7 chars

    ; Mensagem round de empate
    msg_morte_subita db 'EMPATE - MORTE SUBITA'

segment code
    global check_fim_round, exibe_game_over, reseta_partida
    global verifica_timeout
    
    extern energia_p1, energia_p2
    extern escrever_na_tela
    extern key_y, key_n
    extern le_tick, ult_tick
    extern desenha_vencedor_go

; Verifica se algum jogador ficou sem vida.
; Retorna: AX=0 (Luta continua), AX=1 (Round acabou), AX=2 (Game Over)
check_fim_round:
    PUSH BX
    PUSH CX
    PUSH DX

    ; Verifica se P1 perdeu
    CMP word [energia_p1], 0
    JE .vitoria_p2
    
    ; Verifica se P2 perdeu
    CMP word [energia_p2], 0
    JE .vitoria_p1
    
    ; Ninguém perdeu ainda
    MOV AX, 0
    JMP .fim_check

.vitoria_p1:
    INC word [vitorias_p1]
    CALL mostra_msg_round_p1
    JMP .avalia_vitoria

.vitoria_p2:
    INC word [vitorias_p2]
    CALL mostra_msg_round_p2
    
.avalia_vitoria:
    ; Verifica se alguém atingiu 2 vitórias
    CMP word [vitorias_p1], 2
    JE .fim_partida
    CMP word [vitorias_p2], 2
    JE .fim_partida
    
    ; Prepara próximo round
    INC word [round_atual]
    MOV AX, 1                   ; Sinaliza que o round acabou (mas a partida continua)
    JMP .fim_check

.fim_partida:
    MOV AX, 2                   ; Sinaliza Game Over

.fim_check:
    POP DX
    POP CX
    POP BX
    RET

; Mostra a tela final e espera Y ou N
; Retorna: AX=1 (Reiniciar Jogo) | AX=0 (Sair)
exibe_game_over:
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    ; LIMPA A TELA (último frame não vai atrapalhar a mensagem de campeão)
    MOV AL, 12h
    MOV AH, 0
    INT 10h
    
    ; Escreve GAME OVER
    MOV BP, msg_go_titulo
    MOV CX, 13
    MOV DH, 3                   
    MOV DL, 33                  
    MOV BL, 0Fh                 ; Branco
    CALL escrever_na_tela

    ; Verifica quem ganhou para mostrar a mensagem certa e desenhar o lutador
    CMP word [vitorias_p1], 2
    JE .campeao_p1
    MOV BP, msg_go_p2
    MOV AX, 2                   ; Passamos 2 no AX para a função de desenho saber quem ganhou
    JMP .imprime_campeao
.campeao_p1:
    MOV BP, msg_go_p1
    MOV AX, 1                   ; Passamos 1 no AX para a função de desenho saber quem ganhou
.imprime_campeao:
    MOV CX, 24
    MOV DH, 6                   
    MOV DL, 28
    MOV BL, 0Fh                 ; Branco
    CALL escrever_na_tela

    ; DESENHA O BONECO VENCEDOR NO MEIO DA TELA
    CALL desenha_vencedor_go

    ; Mostra opções de Menu
    MOV BP, msg_go_menu
    MOV CX, 16
    MOV DH, 20                  
    MOV DL, 32
    MOV BL, 0Fh                 ; Branco
    CALL escrever_na_tela

    MOV BP, msg_go_y
    MOV CX, 7
    MOV DH, 23                  
    MOV DL, 36
    MOV BL, 0Fh                 
    CALL escrever_na_tela

    MOV BP, msg_go_n
    MOV CX, 7
    MOV DH, 25                  
    MOV DL, 36
    MOV BL, 0Fh                 
    CALL escrever_na_tela

.aguarda_go:
    CMP byte [key_y], 1
    JE .reinicia
    CMP byte [key_n], 1
    JE .encerra
    JMP .aguarda_go

.reinicia:
    MOV byte [key_y], 0
    CALL reseta_partida
    MOV AX, 1                   ; Retorna 1 (Reiniciar)
    JMP .fim_go
    
.encerra:
    MOV AX, 0                   ; Retorna 0 (Sair)

.fim_go:
    POP BP
    POP DX
    POP CX
    POP BX
    RET

; Zera as variáveis de rounds para um novo jogo
reseta_partida:
    MOV word [vitorias_p1], 0
    MOV word [vitorias_p2], 0
    MOV word [round_atual], 1
    RET

; Rotinas auxiliares de impressão de Round
mostra_msg_round_p1:
    PUSH AX
    CMP word [round_atual], 1
    JE .r1
    CMP word [round_atual], 2
    JE .r2
    MOV BP, msg_r3_p1
    JMP .imprime
.r1:
    MOV BP, msg_r1_p1
    JMP .imprime
.r2:
    MOV BP, msg_r2_p1
.imprime:
    CALL print_round_msg
    POP AX
    RET

mostra_msg_round_p2:
    PUSH AX
    CMP word [round_atual], 1
    JE .r1
    CMP word [round_atual], 2
    JE .r2
    MOV BP, msg_r3_p2
    JMP .imprime
.r1:
    MOV BP, msg_r1_p2
    JMP .imprime
.r2:
    MOV BP, msg_r2_p2
.imprime:
    CALL print_round_msg
    POP AX
    RET

print_round_msg:
    MOV CX, 29
    MOV DH, 14
    MOV DL, 25
    MOV BL, 0Fh                 ; Branco
    CALL escrever_na_tela
    CALL delay_round            ; Deixa a mensagem na tela um tempo
    RET

delay_round:
    ; Delay leve e direto baseado em contadores simples de loop (cerca de 2 a 3 segundos)
    PUSH CX
    MOV CX, 0200h       
.del2:
    PUSH CX
    MOV CX, 8000h       
.del1:
    LOOP .del1
    POP CX
    LOOP .del2
    POP CX
    RET

; Verifica quem ganhou por timeout ou aciona Morte Súbita
; Retorna: AX=1 (Alguém ganhou), AX=3 (Morte Súbita)
verifica_timeout:
    MOV CX, [energia_p1]
    CMP CX, [energia_p2]
    JG .p1_ganhou_tempo
    JL .p2_ganhou_tempo
    
    ; Se chegou aqui, vidas são iguais. Prepara morte súbita
    MOV word [energia_p1], 1
    MOV word [energia_p2], 1
    MOV AX, 3                   ; Retorna código 3 (Empate)
    RET

.p1_ganhou_tempo:
    MOV word [energia_p2], 0    ; Zera a vida do P2 para check_fim_round processar
    MOV AX, 1                   ; Retorna código 1 (Desempate resolvido)
    RET

.p2_ganhou_tempo:
    MOV word [energia_p1], 0    ; Zera a vida do P1 para check_fim_round processar
    MOV AX, 1                   ; Retorna código 1 (Desempate resolvido)
    RET