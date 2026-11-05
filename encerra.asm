; RESUMO: Módulo responsável por exibir a tela de confirmação de saída.
; Trava a execução (pausa natural), consome as teclas Y e N através das 
; flags do teclado e limpa os buffers para evitar ataques acidentais.

segment data
    global confirmar_saida

    ; Mensagens de confirmação
    msg_confirma1 db 'DESEJA MESMO SAIR?'       ; 18 caracteres
    msg_confirma2 db 'SIM (Y) / NAO (N)'        ; 17 caracteres

segment code
    extern escrever_na_tela
    
    ; Importa flags de teclado e funções do timer
    extern key_y, key_n, key_q
    extern le_tick, ult_tick

; Função: CONFIRMAR_SAIDA
; Retorna: AX = 1 se confirmou saída (Y) | AX = 0 se cancelou (N)
confirmar_saida:
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    ; 1. Desenha os textos de confirmação em amarelo 
    MOV BP, msg_confirma1
    MOV CX, 18
    MOV DH, 13                  ; Linha 13
    MOV DL, 31                  ; Coluna centralizada
    MOV BL, 0Eh                 ; Amarelo
    CALL escrever_na_tela

    MOV BP, msg_confirma2
    MOV CX, 17
    MOV DH, 15                  ; Linha 15
    MOV DL, 31                  
    MOV BL, 0Eh                 
    CALL escrever_na_tela

    ; 2. Loop de pausa (aguarda resposta pelas flags do teclado) 
.aguarda_resposta:
    CMP byte [key_y], 1
    JE .confirmou_sim
    CMP byte [key_n], 1
    JE .cancelou_nao
    JMP .aguarda_resposta       ; Prende o jogo aqui (game loop não avança)

.confirmou_sim:
.espera_y_soltar:
    CMP byte [key_y], 1         
    JE .espera_y_soltar         ; Aguarda soltar a tecla para sair limpo
    MOV AX, 1                   ; Retorna 1 (Sair)
    JMP .fim

.cancelou_nao:
.espera_n_soltar:
    CMP byte [key_n], 1
    JE .espera_n_soltar         ; Aguarda soltar o 'N' completamente

    ; 3. Apaga as mensagens da tela (escreve em preto) 
    MOV BP, msg_confirma1
    MOV CX, 18
    MOV DH, 13
    MOV DL, 31
    MOV BL, 0                   ; Cor Preta
    CALL escrever_na_tela

    MOV BP, msg_confirma2
    MOV CX, 17
    MOV DH, 15
    MOV DL, 31
    MOV BL, 0                   
    CALL escrever_na_tela

    ; 4. FLUSH DE TECLAS E TIMER 
    ; Zera as teclas . Isso garante que a main.asm não veja o 'N'
    ; como um chute do player 2 e que o menu não reabra pelo 'Q'.
    MOV byte [key_n], 0
    MOV byte [key_y], 0
    MOV byte [key_q], 0

    ; Sincroniza o timer para o jogo não descontar todo o tempo que a 
    ; tela de confirmação ficou aberta.
    CALL le_tick
    MOV [ult_tick], AX

    MOV AX, 0                   ; Retorna 0 (Continuar luta)

.fim:
    POP BP
    POP DX
    POP CX
    POP BX
    RET