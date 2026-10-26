; OBJETIVO: Loop principal do jogo e controle de video

segment code
..start:
    ; Declarando que vamos usar as funcoes graficas de outro arquivo
    extern plot_xy
    extern line
    extern circle
    extern full_circle
    extern desenha_cenario      
    extern desenha_lutadores
    
    extern cor

    ; Inicializacao dos registradores de segmento
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    ; Salvar modo corrente de video
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL

    ; Alterar modo de video para grafico VGA 640x480 16 cores
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; DESENHO DO CENARIO E LUTADORES
    CALL desenha_cenario        ; Desenha a arena antes de entrar no loop
    CALL desenha_lutadores      ; Também desenha os lutadores

loop_principal:
    ; Ler o teclado para manter o jogo rodando
    MOV AH, 0Bh
    INT 21h                 ; Verifica o buffer do teclado
    CMP AL, 0
    JE loop_principal       ; Se for 0, nenhuma tecla foi pressionada, continua o loop

    MOV AH, 08h
    INT 21h                 ; Le efetivamente o caracter digitado sem ecoar na tela
    CMP AL, 'q'
    JE sair_jogo            ; Se for 's' minusculo, sai do jogo
    CMP AL, 'Q'
    JE sair_jogo            ; Se for 'S' maiusculo, sai do jogo

    JMP loop_principal      ; Se foi outra tecla, ignora e volta pro loop

sair_jogo:
    ; Restaurar o modo de video anterior do sistema
    MOV AH, 0   
    MOV AL, [modo_anterior] 
    INT 10h

    ; Encerrar o programa devolvendo o controle ao DOS
    MOV AX, 4C00h
    INT 21h

; SEGMENTO DE DADOS
segment data
    modo_anterior db 0


; SEGMENTO DE PILHA
segment stack stack
    resb 512
stacktop: