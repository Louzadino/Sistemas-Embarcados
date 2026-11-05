; RESUMO: Arquivo principal do jogo de luta. É responsável por gerenciar
; a inicialização do sistema, configuração de vídeo, laço principal 
; (game loop), chamadas de renderização, física, colisões e encerramento.

segment code
..start:
    ; Importação de funções gráficas e de cenário de outros módulos
    extern desenha_cenario, desenha_lutadores, apaga_lutadores
    extern desenha_p1_normal, desenha_p2_normal
    extern desenha_p1_agachado, desenha_p2_agachado
    extern desenha_p1_andando, desenha_p2_andando
    extern desenha_soco_p1, desenha_soco_p2

    ; Importação de variáveis de status e posições
    extern status_jogadores
    extern energia_p1, energia_p2
    extern p1_x, p2_x, p1_y, p2_y
    
    ; Importação de estados e módulos externos (física e colisões)
    extern p1_estado, p2_estado
    extern atualiza_movimento
    extern verifica_ataques

    ; Importação de rotinas de hardware de teclado e teclas mapeadas
    extern instala_teclado, restaura_teclado
    extern key_q, key_a, key_d, key_left, key_right

    ; Importação da função de menu inicial (seleção de cores dos lutadores)
    extern MENU_INICIAL, cor_p1, cor_p2, cor

    ; Importação da função timer e utilitários
    extern timer, le_tick, reset_timer
    extern ult_tick

    ; Importação para a tela de pausa
    extern jogo_pausado, render_pausa, apaga_pausa

    ; Importação para a tela de encerramento manual e rounds
    extern confirmar_saida
    extern check_fim_round, exibe_game_over, reseta_partida

    ; Importação para tela de morte súbita (caso empate)
    extern verifica_timeout, msg_morte_subita
    extern escrever_na_tela

    ; INICIALIZAÇÃO DO SISTEMA E VÍDEO
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    ; Instala a nova interrupção de teclado (INT 9h)
    CALL instala_teclado

inicia_jogo:
    ; Salva o modo de vídeo atual e configura o modo gráfico 640x480 (16h / 12h)
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; EXECUTA O MENU INTERATIVO DE SELEÇÃO DE CORES
    CALL MENU_INICIAL

    ; Aplica as cores
    MOV AL, [cor_p1]
    MOV byte [cor], AL
    MOV AL, [cor_p2]
    MOV byte [cor], AL

novo_round:
    MOV byte [em_morte_subita], 0   ; Desliga FLAG Round morte súbita logo no início

    ; Limpa a tela para o novo round
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; Reseta as posições e energias
    MOV word [p1_x], 260     
    MOV word [p1_y], 115
    MOV word [p2_x], 380     
    MOV word [p2_y], 115
    MOV word [energia_p1], 10
    MOV word [energia_p2], 10
    
    ; Reseta o tempo
    CALL reset_timer

    ; Inicia o cenário e renderiza
    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores

    ; Sincroniza o timer ao começar a luta
    CALL le_tick
    MOV [ult_tick], AX

    ; LAÇO PRINCIPAL DO JOGO (GAME LOOP)
loop_principal:
    CALL delay

    ; Verifica se quer sair do jogo 
    CMP byte [key_q], 1
    JNE continua_game_loop
    
    ; Chama a tela de confirmação (Y/N)
    CALL confirmar_saida
    CMP AX, 1
    JNE continua_loop_principal  ; Se AX = 1, o jogador apertou Y e o jogo deve fechar
    JMP sair_jogo
continua_loop_principal:
    MOV byte [key_q], 0          ; Se não, reseta a flag do Q e volta pro jogo
    JMP loop_principal           ; Recomeça o loop para não pular a física atual

continua_game_loop:
    ; VERIFICAÇÃO DE PAUSA 
    CMP byte [jogo_pausado], 1
    JNE continua_game_loop2      ; Se estiver 1, vai pro render de pausa
    JMP modo_pausa

continua_game_loop2:
    ; Verifica se acabou de sair da pausa (transição 1 -> 0)
    CMP byte [estado_anterior_pausa], 1
    JNE .luta_normal
    ; Se sim, apaga o texto "PAUSED" da tela e atualiza a flag
    CALL apaga_pausa
    MOV byte [estado_anterior_pausa], 0

.luta_normal:
    ; 1. Processa colisões e ataques
    CALL verifica_ataques
    
    ; 2. Apaga rastro e atualiza física
    CALL apaga_lutadores
    CALL atualiza_movimento

    ; 3. Renderiza o quadro atual
    CALL render_p1
    CALL render_p2
    CALL desenha_cenario 
    CALL status_jogadores
    
    ; 4. Atualiza o Timer
    CALL timer
    CMP AX, 1                  ; O timer zerou?
    JNE executa_check_fim_round    

    CMP byte [em_morte_subita], 1 ; Nós já estamos na morte súbita?
    JE executa_check_fim_round    ; Se sim, pula a verificação de empate e continua a luta

    ; Se zerou, chama a lógica do rounds.asm
    CALL verifica_timeout
    CMP AX, 3                  ; Retornou 3? Então é Morte Súbita
    JE morte_subita

executa_check_fim_round:
    ; 5. Verifica fim de round (vida zero)
    CALL check_fim_round
    CMP AX, 1
    JNE continua_luta_normal     ; Se AX=1, reinicia o próximo round
    JMP novo_round
continua_luta_normal: 
    CMP AX, 2
    JE tela_game_over            ; Se AX=2, Game Over
    
    JMP loop_principal

morte_subita:
    MOV byte [em_morte_subita], 1  ; LIGA A FLAG DE MORTE SÚBITA

    ; Limpa a tela
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; Escreve a mensagem de Morte Súbita
    MOV BP, msg_morte_subita
    MOV CX, 21
    MOV DH, 14
    MOV DL, 29
    MOV BL, 0Ch                 ; Vermelho claro
    CALL escrever_na_tela
    
    CALL delay
    CALL delay
    CALL delay
    CALL delay

    ; Limpa a tela novamente
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; Reseta apenas posições (as vidas já foram setadas para 1 no rounds.asm)
    MOV word [p1_x], 260     
    MOV word [p1_y], 115
    MOV word [p2_x], 380     
    MOV word [p2_y], 115
    
    ;CALL reset_timer

    CALL desenha_cenario
    CALL render_p1
    CALL render_p2
    CALL status_jogadores

    CALL le_tick
    MOV [ult_tick], AX

    JMP loop_principal

modo_pausa:
    MOV byte [estado_anterior_pausa], 1  ; Registra que o jogo está pausado
    ; Durante a pausa, renderiza apenas o aviso
    CALL render_pausa
    
    ; Chama le_tick e sincroniza ult_tick para o timer nao avançar rapidamente
    CALL le_tick
    MOV [ult_tick], AX          

    JMP loop_principal

tela_game_over:
    CALL exibe_game_over
    CMP AX, 1
    JNE continua_game_over      ; Se retornou 1 (Y), volta pro menu inicial
    JMP inicia_jogo
continua_game_over:
    JMP sair_jogo               ; Se retornou 0 (N), sai pro DOS

; FUNÇÕES DE RENDERIZAÇÃO
; Decidem qual sprite do lutador desenhar com base 
; na física (se está pulando, agachando ou andando)
global render_p1, render_p2

; A função 'extern key_t' já foi declarada no começo do arquivo pelo seu código, 
; então só precisamos usá-la aqui embaixo.
extern key_t   ; (Garante que enxerga a variável exportada pelo teclado.asm)

render_p1:
    CMP byte [key_t], 1     ; 1. Verifica se o P1 está atacando (Prioridade máxima visual)
    JE r_soco_p1

    CMP byte [p1_estado], 1 ; 2. Verifica se está agachado      
    JE r_agachado_p1

    CMP word [p1_y], 115    ; 3. Verifica se está no ar (pulando)
    JG r_normal_p1      

    CMP byte [key_a], 1     ; 4. Verifica se está andando 
    JE r_check_passo_p1
    CMP byte [key_d], 1          
    JE r_check_passo_p1
r_normal_p1:
    CALL desenha_p1_normal       
    RET
r_soco_p1:
    CALL desenha_soco_p1         
    RET
r_check_passo_p1:
    MOV AX, [p1_x]
    TEST AX, 0010h               
    JZ r_normal_p1
    CALL desenha_p1_andando      
    RET
r_agachado_p1:
    CALL desenha_p1_agachado     
    RET
render_p2:
    CMP byte [p2_estado], 1      ; Verifica se o P2 está agachado
    JE r_agachado_p2
    CMP word [p2_y], 115         ; Verifica se o P2 está no ar
    JG r_normal_p2      
    CMP byte [key_left], 1       ; Verifica se está andando para esquerda
    JE r_check_passo_p2
    CMP byte [key_right], 1      ; Verifica se está andando para direita
    JE r_check_passo_p2
r_normal_p2:
    CALL desenha_p2_normal       ; Desenha pose padrão em pé
    RET
r_check_passo_p2:
    MOV AX, [p2_x]
    TEST AX, 0010h               ; Alterna sprite de passo do P2
    JZ r_normal_p2
    CALL desenha_p2_andando      ; Desenha pose andando
    RET
r_agachado_p2:
    CALL desenha_p2_agachado     ; Desenha pose agachada
    RET

; ROTINA DE ENCERRAMENTO E RESTAURAÇÃO DO SISTEMA
sair_jogo:
    MOV AH, 0   
    MOV AL, [modo_anterior]      ; Restaura o modo de vídeo original do DOS
    INT 10h
    CALL restaura_teclado        ; Restaura a interrupção original do teclado
    MOV AX, 4C00h                ; Encerra o programa com segurança
    INT 21h

; ROTINA DE DELAY (ATRASO POR SOFTWARE)
delay:
    PUSH CX
    MOV CX, 0080h       
del2:
    PUSH CX
    MOV CX, 0400h       
del1:
    LOOP del1
    POP CX
    LOOP del2
    POP CX
    RET

segment data
    modo_anterior db 0           ; Armazena o modo de vídeo anterior
    estado_anterior_pausa db 0   ; Variável para saber quando apagar a msg "PAUSED"
    em_morte_subita db 0         ; FLAG (0 = Round normal | 1 = Morte Súbita)

segment stack stack
    resb 512
stacktop: