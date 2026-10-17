; =====================================================================
; ARQUIVO: main.asm
; OBJETIVO: Loop principal do Jogo de Luta e controle de video
; =====================================================================

segment code
..start:
    ; Declarando que vamos usar as funcoes graficas de outro arquivo (linec.asm)
    extern plot_xy
    extern line
    extern circle
    extern full_circle
    
    ; Declarando que vamos usar a variavel global de cor definida no linec.asm
    extern cor

    ; 1. Inicializacao dos registradores de segmento
    MOV AX, data
    MOV DS, AX
    MOV AX, stack
    MOV SS, AX
    MOV SP, stacktop

    ; 2. Salvar modo corrente de video (para nao bugar o DOSBox ao sair)
    MOV AH, 0Fh
    INT 10h
    MOV [modo_anterior], AL

    ; 3. Alterar modo de video para grafico VGA 640x480 16 cores
    MOV AL, 12h
    MOV AH, 0
    INT 10h

    ; =================================================================
    ; TESTE DE DESENHO: O Chao da Arena
    ; =================================================================
    MOV byte [cor], 15      ; 15 corresponde a branco intenso no Linec

    ; Passagem de parametros para desenhar a reta (y=400, x vai de 0 a 639)
    MOV AX, 0
    PUSH AX                 ; x1 = 0
    MOV AX, 400
    PUSH AX                 ; y1 = 400
    MOV AX, 639
    PUSH AX                 ; x2 = 639
    MOV AX, 400
    PUSH AX                 ; y2 = 400
    CALL line               ; Chama a funcao do arquivo linec.asm
    ; =================================================================

loop_principal:
    ; 4. Ler o teclado para manter o jogo rodando ate pedir para sair
    ; Nota: Estamos usando a INT 21h temporariamente apenas para este teste inicial.
    ; Mais tarde, o projeto exige que isso seja substituido pela INT 9h.
    MOV AH, 0Bh
    INT 21h                 ; Verifica o buffer do teclado
    CMP AL, 0
    JE loop_principal       ; Se for 0, nenhuma tecla foi pressionada, continua o loop

    MOV AH, 08h
    INT 21h                 ; Le efetivamente o caracter digitado sem ecoar na tela
    CMP AL, 's'
    JE sair_jogo            ; Se for 's' minusculo, sai do jogo
    CMP AL, 'S'
    JE sair_jogo            ; Se for 'S' maiusculo, sai do jogo

    JMP loop_principal      ; Se foi outra tecla, ignora e volta pro loop

sair_jogo:
    ; 5. Restaurar o modo de video anterior do sistema
    MOV AH, 0   
    MOV AL, [modo_anterior] 
    INT 10h

    ; 6. Encerrar o programa devolvendo o controle ao DOS
    MOV AX, 4C00h
    INT 21h

; =====================================================================
; SEGMENTO DE DADOS
; =====================================================================
segment data
    modo_anterior db 0

; =====================================================================
; SEGMENTO DE PILHA
; =====================================================================
segment stack stack
    resb 512
stacktop: