; RESUMO: Controla a flag global de pausa e exibe a mensagem "PAUSED"
; no centro da tela.

segment data
    global jogo_pausado, p_travado
    
    jogo_pausado db 0           ; 0 = Rodando, 1 = Pausado
    p_travado    db 0           ; Flag para evitar múltiplos toggles seguidos
    
    txt_pausa    db 'PAUSED'    ; 6 caracteres

segment code
    global render_pausa, apaga_pausa
    extern escrever_na_tela

; Função que desenha o texto "PAUSED" no centro da tela (Linha 15, Coluna 37)
render_pausa:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    MOV BP, txt_pausa
    MOV CX, 6
    MOV DH, 15                  ; Linha do meio da tela
    MOV DL, 37                  ; Coluna central
    MOV BL, 0Eh                 ; Cor amarela
    CALL escrever_na_tela

    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET

apaga_pausa:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH BP

    MOV BP, txt_pausa
    MOV CX, 6
    MOV DH, 15                  
    MOV DL, 37                  
    MOV BL, 0                   ; Cor 0 = Preto (apaga)
    CALL escrever_na_tela

    POP BP
    POP DX
    POP CX
    POP BX
    POP AX
    RET