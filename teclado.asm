; RESUMO: Módulo responsável pelo tratamento de hardware do teclado 
; através da interrupção INT 9h (substituindo a leitura padrão por software).

segment data
    ; Exportação das variáveis globais de estado das teclas (1 = pressionada, 0 = solta)
    global key_a, key_d, key_left, key_right, key_q
    global key_t, key_m, key_n, key_r
    global key_w, key_s, key_up, key_down
    global key_enter                      ; <-- 1. NOVO: Exporta a flag da tecla Enter
    global key_y

    key_a        db 0
    key_d        db 0
    key_left     db 0
    key_right    db 0
    key_q        db 0
    key_t        db 0
    key_m        db 0
    key_n        db 0
    key_r        db 0
    key_w        db 0
    key_s        db 0
    key_up       db 0
    key_down     db 0
    key_enter    db 0                      
    key_y        db 0

    ; Armazenamento do vetor original da interrupção de teclado do DOS
    velho_isr_off dw 0
    velho_isr_seg dw 0

segment code
    global instala_teclado, restaura_teclado

; FUNÇÃO: INSTALA_TECLADO
instala_teclado:
    PUSH AX
    PUSH BX
    PUSH ES
    XOR AX, AX
    MOV ES, AX                      ; Aponta para a IVT (Segmento 0)
    
    MOV BX, [ES:24h]
    MOV [velho_isr_off], BX
    MOV BX, [ES:26h]
    MOV [velho_isr_seg], BX
    
    CLI                             ; Desativa interrupções
    MOV word [ES:24h], nova_int9    ; Insere a nova rotina
    MOV word [ES:26h], CS
    STI                             ; Reativa interrupções
    
    POP ES
    POP BX
    POP AX
    RET

; FUNÇÃO: RESTAURA_TECLADO
restaura_teclado:
    PUSH AX
    PUSH BX
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    
    CLI
    MOV BX, [velho_isr_off]
    MOV [ES:24h], BX                ; Restaura o offset original
    MOV BX, [velho_isr_seg]
    MOV [ES:26h], BX                ; Restaura o segmento original
    STI
    
    POP ES
    POP BX
    POP AX
    RET

; ROTINA DE INTERRUPÇÃO DE HARDWARE (INT 9h)
nova_int9:
    PUSH AX
    PUSH DS
    MOV AX, data
    MOV DS, AX                      ; Configura o segmento de dados local
    
    IN AL, 60h                      ; Lê o scancode da porta 60h

    CMP AL, 0E0h                    ; Ignora códigos de prefixo estendido
    JNE continua
    JMP fim_int9
continua:

    ; MOVIMENTO P1 (Teclas A e D) 
    CMP AL, 1Eh         ; Make A
    JNE continua_reseta_a
    JMP seta_a
continua_reseta_a:
    CMP AL, 9Eh         ; Break A
    JNE continua_seta_d
    JMP reseta_a
continua_seta_d:
    CMP AL, 20h         ; Make D
    JNE continua_reseta_d
    JMP seta_d
continua_reseta_d:
    CMP AL, 0A0h        ; Break D
    JNE continua_seta_left
    JMP reseta_d

    ; MOVIMENTO P2 (Setas Esquerda/Direita e teclas J/L) 
continua_seta_left:
    CMP AL, 4Bh         ; Seta Esquerda (Make)
    JNE continua_seta_left_j
    JMP seta_left
continua_seta_left_j:
    CMP AL, 24h         ; Tecla J (Make)
    JNE continua_reseta_left
    JMP seta_left
continua_reseta_left:
    CMP AL, 0CBh        ; Seta Esquerda (Break)
    JNE continua_reseta_left_j
    JMP reseta_left
continua_reseta_left_j:
    CMP AL, 0A4h        ; Tecla J (Break)
    JNE continua_seta_right
    JMP reseta_left

continua_seta_right:
    CMP AL, 4Dh         ; Seta Direita (Make)
    JNE continua_seta_right_l
    JMP seta_right
continua_seta_right_l:
    CMP AL, 26h         ; Tecla L (Make)
    JNE continua_reseta_right
    JMP seta_right
continua_reseta_right:
    CMP AL, 0CDh        ; Seta Direita (Break)
    JNE continua_reseta_right_l
    JMP reseta_right
continua_reseta_right_l:
    CMP AL, 0A6h        ; Tecla L (Break)
    JNE continua_seta_t
    JMP reseta_right

    ; SOCOS (Teclas T e M) 
continua_seta_t:
    CMP AL, 14h         ; Make T
    JNE continua_reseta_t
    JMP seta_t
continua_reseta_t:
    CMP AL, 94h         ; Break T
    JNE continua_seta_m
    JMP reseta_t
continua_seta_m:
    CMP AL, 32h         ; Make M
    JNE continua_reseta_m
    JMP seta_m
continua_reseta_m:
    CMP AL, 0B2h        ; Break M
    JNE continua_seta_n
    JMP reseta_m

    ; CHUTES (Teclas N e R) 
continua_seta_n:
    CMP AL, 31h         ; Make N
    JNE continua_reseta_n
    JMP seta_n
continua_reseta_n:
    CMP AL, 0B1h        ; Break N
    JNE continua_seta_r
    JMP reseta_n
continua_seta_r:
    CMP AL, 13h         ; Make R
    JNE continua_reseta_r
    JMP seta_r
continua_reseta_r:
    CMP AL, 93h         ; Break R
    JNE continua_seta_q
    JMP reseta_r

    ; SAIR DO JOGO (Tecla Q) 
continua_seta_q:
    CMP AL, 10h         ; Make Q
    JNE continua_seta_w
    JMP seta_q

    ; PULOS E DEFESAS P1 (Teclas W e S) 
continua_seta_w:
    CMP AL, 11h         ; Make W
    JNE continua_reseta_w
    JMP seta_w
continua_reseta_w:
    CMP AL, 91h         ; Break W
    JNE continua_seta_s
    JMP reseta_w
continua_seta_s:
    CMP AL, 1Fh         ; Make S
    JNE continua_reseta_s
    JMP seta_s
continua_reseta_s:
    CMP AL, 9Fh         ; Break S
    JNE continua_seta_up
    JMP reseta_s

    ; PULOS E DEFESAS P2 (Setas Cima/Baixo e teclas I/K) 
continua_seta_up:
    CMP AL, 48h         ; Seta Cima (Make)
    JNE continua_seta_up_i
    JMP seta_up
continua_seta_up_i:
    CMP AL, 17h         ; Tecla I (Make)
    JNE continua_reseta_up
    JMP seta_up
continua_reseta_up:
    CMP AL, 0C8h        ; Seta Cima (Break)
    JNE continua_reseta_up_i
    JMP reseta_up
continua_reseta_up_i:
    CMP AL, 97h         ; Tecla I (Break)
    JNE continua_seta_down
    JMP reseta_up
continua_seta_down:
    CMP AL, 50h         ; Seta Baixo (Make)
    JNE continua_seta_down_k
    JMP seta_down
continua_seta_down_k:
    CMP AL, 25h         ; Tecla K (Make)
    JNE continua_reseta_down
    JMP seta_down
continua_reseta_down:
    CMP AL, 0D0h        ; Seta Baixo (Break)
    JNE continua_reseta_down_k
    JMP reseta_down
continua_reseta_down_k:
    CMP AL, 0A5h        ; Tecla K (Break)
    JNE continua_seta_enter           ; <-- 2. NOVO: Desvia para testar a tecla Enter
    JMP reseta_down 

continua_seta_enter:    ; TECLA ENTER (Scancode 1Ch / Break 9Ch)
    CMP AL, 1Ch         ; Scancode Make da tecla Enter (Pressionada)
    JNE continua_reseta_enter
    JMP seta_enter
continua_reseta_enter:
    CMP AL, 9Ch         ; Scancode Break da tecla Enter (Solta)
    JNE continua_seta_y
    JMP reseta_enter
continua_seta_y:        ; TECLA Y (Scancode Make 15h / Break 95h)
    CMP AL, 15h         ; Scancode Make da tecla Y (Pressionada)
    JNE continua_reseta_y
    JMP seta_y
continua_reseta_y:
    CMP AL, 95h         ; Scancode Break da tecla Y (Solta)
    JNE continua_final  ; Ou desvia para a próxima verificação (ex: continua_seta_enter)
    JMP reseta_y
continua_final:
    JMP fim_int9

; MANIPULADORES DE ESTADO DAS TECLAS (FLAGS)
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
seta_t:       
    MOV byte [key_t], 1
    JMP fim_int9
reseta_t:     
    MOV byte [key_t], 0
    JMP fim_int9
seta_m:       
    MOV byte [key_m], 1
    JMP fim_int9
reseta_m:     
    MOV byte [key_m], 0
    JMP fim_int9
seta_n:       
    MOV byte [key_n], 1
    JMP fim_int9
reseta_n:     
    MOV byte [key_n], 0
    JMP fim_int9
seta_r:       
    MOV byte [key_r], 1
    JMP fim_int9
reseta_r:     
    MOV byte [key_r], 0
    JMP fim_int9
seta_w:       
    MOV byte [key_w], 1
    JMP fim_int9
reseta_w:     
    MOV byte [key_w], 0
    JMP fim_int9
seta_s:       
    MOV byte [key_s], 1
    JMP fim_int9
reseta_s:     
    MOV byte [key_s], 0
    JMP fim_int9
seta_up:      
    MOV byte [key_up], 1
    JMP fim_int9
reseta_up:    
    MOV byte [key_up], 0
    JMP fim_int9
seta_down:    
    MOV byte [key_down], 1
    JMP fim_int9
reseta_down:  
    MOV byte [key_down], 0
    JMP fim_int9
seta_enter:
    MOV byte [key_enter], 1
    JMP fim_int9
reseta_enter:
    MOV byte [key_enter], 0
    JMP fim_int9
seta_y:
    MOV byte [key_y], 1
    JMP fim_int9
reseta_y:
    MOV byte [key_y], 0
    JMP fim_int9

; FIM DA INTERRUPÇÃO
fim_int9:
    IN AL, 61h
    OR AL, 80h
    OUT 61h, AL
    AND AL, 7Fh
    OUT 61h, AL
    MOV AL, 20h
    OUT 20h, AL
    POP DS
    POP AX
    IRET