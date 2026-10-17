; ARQUIVO: cenario.asm
; OBJETIVO: Desenhar a arena de luta, limites e HUD

segment code
    global desenha_cenario      ; Torna a funcao visivel para o main.asm
    
    extern line                 ; Importa a funcao de desenhar reta do linec.asm
    extern cor                  ; Importa a variavel global de cor do linec.asm

desenha_cenario:
    ; Salva o contexto na pilha (boa pratica para nao corromper registradores)
    PUSH BP
    MOV BP, SP
    PUSH AX

    ; Define a cor dos delimitadores como branco intenso (15)
    MOV byte [cor], 15

    ; 1. Desenhar o Chao (Y=50, indo de X=0 ate X=639)
    MOV AX, 0
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 639
    PUSH AX
    MOV AX, 50
    PUSH AX
    CALL line

    ; 2. Desenhar o Teto (Y=400, indo de X=0 ate X=639)
    MOV AX, 0
    PUSH AX
    MOV AX, 400
    PUSH AX
    MOV AX, 639
    PUSH AX
    MOV AX, 400
    PUSH AX
    CALL line

    ; 3. Desenhar Limite Esquerdo (X=5, indo de Y=50 ate Y=400)
    MOV AX, 5
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 5
    PUSH AX
    MOV AX, 400
    PUSH AX
    CALL line

    ; 4. Desenhar Limite Direito (X=634, indo de Y=50 ate Y=400)
    MOV AX, 634
    PUSH AX
    MOV AX, 50
    PUSH AX
    MOV AX, 634
    PUSH AX
    MOV AX, 400
    PUSH AX
    CALL line

    ; Restaura o contexto e retorna
    POP AX
    POP BP
    RET