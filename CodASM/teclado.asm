; =====================================================================
; ARQUIVO: teclado.asm
; =====================================================================

segment data
    global key_a, key_d, key_left, key_right, key_q
    global key_t, key_m, key_n, key_r
    global key_w, key_s, key_up, key_down
    
    key_a       db 0
    key_d       db 0
    key_left    db 0
    key_right   db 0
    key_q       db 0
    key_t       db 0
    key_m       db 0
    key_n       db 0
    key_r       db 0
    key_w       db 0
    key_s       db 0
    key_up      db 0
    key_down    db 0
    
    velho_isr_off dw 0
    velho_isr_seg dw 0

segment code
    global instala_teclado, restaura_teclado
        
instala_teclado:
    PUSH AX
    PUSH BX
    PUSH ES
    XOR AX, AX
    MOV ES, AX
    MOV BX, [ES:24h]
    MOV [velho_isr_off], BX
    MOV BX, [ES:26h]
    MOV [velho_isr_seg], BX
    CLI
    MOV word [ES:24h], nova_int9
    MOV word [ES:26h], CS
    STI
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
    IN AL, 60h

    CMP AL, 0E0h
    JNE continua
    JMP fim_int9
continua:

    ; --- MOVIMENTO P1 ---
    CMP AL, 1Eh         ; A (Make)
    JNE continua_reseta_a
    JMP seta_a
continua_reseta_a:
    CMP AL, 9Eh         ; A (Break)
    JNE continua_seta_d
    JMP reseta_a
continua_seta_d:
    CMP AL, 20h         ; D (Make)
    JNE continua_reseta_d
    JMP seta_d
continua_reseta_d:
    CMP AL, 0A0h        ; D (Break)
    JNE continua_seta_left
    JMP reseta_d

    ; --- MOVIMENTO P2 ---
continua_seta_left:
    CMP AL, 4Bh         ; Seta Esq
    JNE continua_seta_left_j
    JMP seta_left
continua_seta_left_j:
    CMP AL, 24h         ; J (Make)
    JNE continua_reseta_left
    JMP seta_left
continua_reseta_left:
    CMP AL, 0CBh        ; Seta Esq Break
    JNE continua_reseta_left_j
    JMP reseta_left
continua_reseta_left_j:
    CMP AL, 0A4h        ; J (Break)
    JNE continua_seta_right
    JMP reseta_left

continua_seta_right:
    CMP AL, 4Dh         ; Seta Dir
    JNE continua_seta_right_l
    JMP seta_right
continua_seta_right_l:
    CMP AL, 26h         ; L (Make)
    JNE continua_reseta_right
    JMP seta_right
continua_reseta_right:
    CMP AL, 0CDh        ; Seta Dir Break
    JNE continua_reseta_right_l
    JMP reseta_right
continua_reseta_right_l:
    CMP AL, 0A6h        ; L (Break)
    JNE continua_seta_t
    JMP reseta_right

    ; --- SOCOS ---
continua_seta_t:
    CMP AL, 14h         ; T (Soco P1 Make)
    JNE continua_reseta_t
    JMP seta_t
continua_reseta_t:
    CMP AL, 94h         ; T (Soco P1 Break)
    JNE continua_seta_m
    JMP reseta_t
continua_seta_m:
    CMP AL, 32h         ; M (Soco P2 Make)
    JNE continua_reseta_m
    JMP seta_m
continua_reseta_m:
    CMP AL, 0B2h        ; M (Soco P2 Break)
    JNE continua_seta_n
    JMP reseta_m

    ; --- CHUTES ---
continua_seta_n:
    CMP AL, 31h         ; N (Chute P1 Make)
    JNE continua_reseta_n
    JMP seta_n
continua_reseta_n:
    CMP AL, 0B1h        ; N (Chute P1 Break)
    JNE continua_seta_r
    JMP reseta_n
continua_seta_r:
    CMP AL, 13h         ; R (Chute P2 Make)
    JNE continua_reseta_r
    JMP seta_r
continua_reseta_r:
    CMP AL, 93h         ; R (Chute P2 Break)
    JNE continua_seta_q
    JMP reseta_r

    ; --- SAIR ---
continua_seta_q:
    CMP AL, 10h         ; Q (Sair)
    JNE continua_seta_w
    JMP seta_q

    ; --- PULOS E DEFESAS P1 ---
continua_seta_w:
    CMP AL, 11h         ; W (Make)
    JNE continua_reseta_w
    JMP seta_w
continua_reseta_w:
    CMP AL, 91h         ; W (Break)
    JNE continua_seta_s
    JMP reseta_w
continua_seta_s:
    CMP AL, 1Fh         ; S (Make)
    JNE continua_reseta_s
    JMP seta_s
continua_reseta_s:
    CMP AL, 9Fh         ; S (Break)
    JNE continua_seta_up
    JMP reseta_s

    ; --- PULOS E DEFESAS P2 ---
continua_seta_up:
    CMP AL, 48h         ; UP
    JNE continua_seta_up_i
    JMP seta_up
continua_seta_up_i:
    CMP AL, 17h         ; I (Backup UP)
    JNE continua_reseta_up
    JMP seta_up
continua_reseta_up:
    CMP AL, 0C8h        ; UP Break
    JNE continua_reseta_up_i
    JMP reseta_up
continua_reseta_up_i:
    CMP AL, 97h         ; I Break
    JNE continua_seta_down
    JMP reseta_up
continua_seta_down:
    CMP AL, 50h         ; DOWN
    JNE continua_seta_down_k
    JMP seta_down
continua_seta_down_k:
    CMP AL, 25h         ; K (Backup DOWN)
    JNE continua_reseta_down
    JMP seta_down
continua_reseta_down:
    CMP AL, 0D0h        ; DOWN Break
    JNE continua_reseta_down_k
    JMP reseta_down
continua_reseta_down_k:
    CMP AL, 0A5h        ; K Break
    JNE continua_final
    JMP reseta_down

continua_final:
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