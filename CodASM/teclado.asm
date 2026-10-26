; =====================================================================
; ARQUIVO: teclado.asm
; OBJETIVO: Tratar a interrupcao de hardware do teclado (INT 9h)
; SEM UTILIZAR A INT 21h (Manipulacao direta da Tabela de Vetores - IVT)
; =====================================================================

segment data
    global key_a, key_d, key_left, key_right, key_q
    key_a       db 0
    key_d       db 0
    key_left    db 0
    key_right   db 0
    key_q       db 0
    
    velho_isr_off dw 0
    velho_isr_seg dw 0

segment code
    global instala_teclado, restaura_teclado
        
instala_teclado:
    PUSH AX
    PUSH BX
    PUSH ES

    ; Zera ES para acessar o inicio da memoria (Tabela de Vetores de Interrupcao - IVT)
    XOR AX, AX
    MOV ES, AX

    ; O vetor da INT 9h fica no endereco 0000:0024 (9 * 4 = 36 = 24h)
    ; 1. Salvar o vetor original (Offset em 24h, Segmento em 26h)
    MOV BX, [ES:24h]
    MOV [velho_isr_off], BX
    MOV BX, [ES:26h]
    MOV [velho_isr_seg], BX

    ; 2. Instalar o novo vetor
    CLI                     ; Desabilita interrupcoes por seguranca
    MOV word [ES:24h], nova_int9
    MOV word [ES:26h], CS   ; Aponta para o nosso Segmento de Codigo
    STI                     ; Reabilita interrupcoes

    POP ES
    POP BX
    POP AX
    RET

restaura_teclado:
    PUSH AX
    PUSH BX
    PUSH ES
    
    XOR AX, AX
    MOV ES, AX

    CLI
    ; Restaura o vetor original lido anteriormente (Requisito 9)
    MOV BX, [velho_isr_off]
    MOV [ES:24h], BX
    MOV BX, [velho_isr_seg]
    MOV [ES:26h], BX
    STI

    POP ES
    POP BX
    POP AX
    RET

nova_int9:
    PUSH AX
    PUSH DS

    MOV AX, data
    MOV DS, AX

    IN AL, 60h          ; Le o scancode

    CMP AL, 0E0h        ; Ignora prefixo estendido de teclas especiais (como setas)
    JE fim_int9

    ; --- JOGADOR 1 (A e D) ---
    CMP AL, 1Eh         ; Pressionou A
    JE seta_a
    CMP AL, 9Eh         ; Soltou A
    JE reseta_a
    CMP AL, 20h         ; Pressionou D
    JE seta_d
    CMP AL, 0A0h        ; Soltou D
    JE reseta_d

    ; --- JOGADOR 2 (Setas ou J e L) ---
    CMP AL, 4Bh         ; Pressionou Seta Esquerda
    JE seta_left
    CMP AL, 24h         ; Pressionou J
    JE seta_left
    CMP AL, 0CBh        ; Soltou Seta Esquerda
    JE reseta_left
    CMP AL, 0A4h        ; Soltou J
    JE reseta_left

    CMP AL, 4Dh         ; Pressionou Seta Direita
    JE seta_right
    CMP AL, 26h         ; Pressionou L
    JE seta_right
    CMP AL, 0CDh        ; Soltou Seta Direita
    JE reseta_right
    CMP AL, 0A6h        ; Soltou L
    JE reseta_right

    ; --- SAIR DO JOGO (Q) ---
    CMP AL, 10h         ; Pressionou Q
    JE seta_q

    JMP fim_int9

seta_a:
    MOV byte [key_a], 1
    JMP fim_int9
reseta_a:
    MOV byte [key_a], 0
    JMP fim_int9
seta_d:
    MOV byte [key_d], 1
    JMP fim_int9
reseta_d:
    MOV byte [key_d], 0
    JMP fim_int9
seta_left:
    MOV byte [key_left], 1
    JMP fim_int9
reseta_left:
    MOV byte [key_left], 0
    JMP fim_int9
seta_right:
    MOV byte [key_right], 1
    JMP fim_int9
reseta_right:
    MOV byte [key_right], 0
    JMP fim_int9
seta_q:
    MOV byte [key_q], 1
    JMP fim_int9

fim_int9:
    IN AL, 61h          ; Reconhece a leitura no controlador de teclado
    OR AL, 80h
    OUT 61h, AL
    AND AL, 7Fh
    OUT 61h, AL
    
    MOV AL, 20h         ; Envia End of Interrupt (EOI) para o PIC
    OUT 20h, AL
    
    POP DS
    POP AX
    IRET