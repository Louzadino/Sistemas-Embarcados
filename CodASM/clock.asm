; ========================================================================
; Clarah Abreu & Guilherme Louzada
;
; Sistemas Embarcados I
; Profº. Camilo Diaz
; 
; Desafio Clock Interruption (Int 8h) e keyboard Interruption (Int 9h) 
;
; ========================================================================
;
; Comandos: 
; Q = +1 hora      W = -1 hora
; A = +1 minuto    S = -1 minuto
; Z = +1 segundo   X = -1 segundo
; D = formato 12h  V = formato 24h
; ESC = sai
;
; =======================================================================

segment code
..start:

    mov ax, data    ; Inicializa o registrador de Segmento de Dados DS
    mov ds, ax

    mov ax, stack   ; Inicializa o registrador de Segmento de Pilha SS
    mov ss, ax

    mov sp, stacktop ; Inicializa o apontador de Pilha SP 
    mov ax, 0003h    ; Limpa a tela
    int 10h

    cli             ; Desabilita interrupções externas (hardware)
    xor ax, ax      ; Limpa o registrador AX
    mov es, ax      ; Inicializa o registrador de ES para acessar a região de vetores de interrupção (posição zero de memoria)

    mov ax, [es:20h]    ; Carrega em AX o valor do IP do vetor de interrupção 8
    mov [offset8], ax   ; Salva na variável offset8 o valor do IP do vetor de interrupção 8
    mov ax, [es:22h]    ; Carrega em AX o valor do CS do vetor de interrupção 8
    mov [cs8], ax       ; Salva na variável cs8 o valor do CS do vetor de interrupção 8 

    mov ax, [es:24h]    ; Carrega em AX o valor do IP do vetor de interrupção 9
    mov [offset9], ax   ; Salva na variável offset9 o valor do IP do vetor de interrupção 9
    mov ax, [es:26h]    ; Carrega em AX o valor do CS do vetor de interrupção 9
    mov [cs9], ax       ; Salva na variável cs9 o valor do CS do vetor de interrupção 8

    mov word [es:20h], ClockINT     ; Atualiza o valor do IP do vetor de interrupção 8 com o offset "ClockINT" do programa atual
    mov ax, cs
    mov [es:22h], ax

    mov word [es:24h], TecladoINT   ; Atualiza o valor do IP do vetor de INTerrupção 9 com o offset "TecladoINT" do programa atual
    mov ax, cs
    mov [es:26h], ax

    sti                 ; Habilita interrupções externas (hardware)

principal:
    call LeTecla         ; trata uma tecla do buffer, se houver
    call MostraHora      ; atualiza o relogio na tela

    cmp byte [sair], 0   ; se a flag de saida não foi ligada, o laço se repete
    je principal

    jmp encerra          ; a flag foi ligada, então vai restaurar os vetores e sair

ClockINT:
    push ax      ; Salva contexto na pilha
    push ds
    mov ax, data         ; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
    mov ds, ax           ; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa
    ; O timer gera ~18,2065 tiques/s. Para nao adiantar
    ; 5 segundos = 91 tiques: 18, 18, 18, 18 e 19.
    inc byte [tique]     ; Incremente variável tique toda vez que entra na interrupção
    mov al, 18           ; limite normal: 18 tiques por segundo
    cmp byte [ciclo], 4  ; e o 5o segundo do ciclo (ciclo = 4)?
    jne limite_ok        ; se nao, mantem o limite 18
    mov al, 19           ; se sim, o limite passa a ser 19 tiques
    
limite_ok:
    cmp byte [tique], al ; compara tiques contados com o limite
    jb fim_clock         ; ainda nao chegou ao limite: nada a fazer
    mov byte [tique], 0  ; completou um segundo: zera os tiques

; Avança o ciclo de 5 segundos
    inc byte [ciclo]        ; proximo segundo do ciclo
    cmp byte [ciclo], 5     ; passou de 4?
    jb conta_segundo        ; se ainda esta em 0..4, segue
    mov byte [ciclo], 0     ; reinicia o ciclo

conta_segundo:              ; avanca o relogio em 1 segundo
    inc byte [segundo]      ; segundo + 1
    cmp byte [segundo], 60  ; chegou a 60?
    jb fim_clock            ; nao: terminou
    mov byte [segundo], 0   ; sim: zera os segundos
    inc byte [minuto]       ; minuto + 1
    cmp byte [minuto], 60   ; chegou a 60?
    jb fim_clock            ; nao: terminou
    mov byte [minuto], 0    ; sim: zera os minutos
    inc byte [hora]         ; hora + 1
    cmp byte [hora], 24     ; chegou a 24?
    jb fim_clock            ; nao: terminou
    mov byte [hora], 0      ; sim: volta para 00:00:00

fim_clock:
    pushf
    call far [offset8]   ; chama a INT 8 original (termina com IRET)
    pop ds
    pop ax
    iret

TecladoINT:
    push ax
    push bx
    push dx
    push es
    push ds
    mov ax, data        ; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
    mov ds, ax          ; Atualiza registrador de segmento de dados DS
    in al, 60h          ; le o scancode da porta do teclado
    mov [tecla_u], al   ; guarda o scancode (AL pode ser alterado pela BIOS)
    pushf               ; empilha FLAGS, simulando uma interrupcao
    call far [offset9]  ; chama a INT 9 original da BIOS
    mov ax, 40h         ; Esvazia o buffer de teclado da BIOS (cabeca = cauda) para ele nao encher e emitir bipes
    mov es, ax
    mov ax, [es:1Ah]
    mov [es:1Ch], ax
    mov al, [tecla_u]   ;Recupera o scancode
    test al, 80h        ; Ignora break codes (bit 7 ligado)
    jnz fim_teclado
    mov bl, [p_i]       ; Calcula a proxima posicao de escrita em DL
    mov dl, bl
    inc dl
    and dl, 7
    cmp dl, [p_t]       ; Se a proxima posicao for a de leitura, o buffer esta cheio
    je fim_teclado
    xor bh, bh          ; Grava na posicao ATUAL (bl) e so entao avanca o ponteiro
    mov [tecla+bx], al
    mov [p_i], dl

; fim da rotina do teclado
fim_teclado:
    pop ds
    pop es
    pop dx
    pop bx
    pop ax
    iret

LeTecla:
    push ax
    push bx
    cli                 ; impede a ISR de mexer nos ponteiros durante a consulta
    mov al, [p_t]
    cmp al, [p_i]
    jne tem_tecla       ; se diferente, ha tecla para tratar
    sti                 ; buffer vazio: reabilita interrupcoes
    jmp fim_le_tecla    ; nada a fazer

tem_tecla:
    xor bx, bx   ; ha pelo menos uma tecla no buffer
    mov bl, al
    mov al, [tecla+bx]  ; AL = scancode armazenado
    inc byte [p_t]      ; avanca o indice de leitura
    and byte [p_t], 7   ; da a volta no buffer 
    sti

    cmp al, 01h         ; ESC: encerra
    jne testa_q         ; nao e ESC: testa a proxima tecla
    mov byte [sair], 1  ; liga a flag de saida
    jmp fim_le_tecla

; Q: aumenta uma hora
testa_q:
    cmp al, 10h             ; scancode do Q
    jne testa_w             ; não é Q: testa a proxima
    cli                     ; protege a variavel contra a ISR do timer
    inc byte [hora]         
    cmp byte [hora], 24     ; a hora passou de 23?
    jb libera_hora_mais     ; nao: segue
    mov byte [hora], 0      ; sim: volta para 0
libera_hora_mais:
    sti
    jmp fim_le_tecla

; W: diminui uma hora
testa_w:
    cmp al, 11h             ; scancode do W
    jne testa_a             ; nao é W: testa a proxima
    cli                     ; protege a variavel contra a ISR do timer
    cmp byte [hora], 0      ; A hora ja é 0?
    jne hora_menor          ; nao: pode decrementar direto
    mov byte [hora], 24     ; sim: usa 24 para que o decremento resulte em 23
hora_menor:
    dec byte [hora]
    sti                     ; reabilita interrupcoes
    jmp fim_le_tecla

; A: aumenta um minuto (59 -> 0, sem alterar a hora)
testa_a:
    cmp al, 1Eh                 ; Compara com o scancode da tecla A
    jne testa_s                 ; Se não for, pula para testar a próxima (S)
    cli
    inc byte [minuto]           ; Soma 1 ao valor do minuto
    cmp byte [minuto], 60       ; Verifica se passou do limite (59)
    jb libera_min_mais          ; Se for menor que 60, não precisa zerar
    mov byte [minuto], 0        ; Se chegou a 60, volta para 0
libera_min_mais:
    sti                         
    jmp fim_le_tecla            ; Pula para o fim da verificação de teclas

; S: diminui um minuto (0 -> 59, sem alterar a hora)
testa_s:
    cmp al, 1Fh                 ; Compara com o scancode da tecla S
    jne testa_z                 ; Se não for pula para testar Z
    cli
    cmp byte [minuto], 0        ; Verifica se o minuto já é 0
    jne minuto_menor            ; Se não for 0, pula direto para decrementar
    mov byte [minuto], 60       ; Se for 0, joga para 60 (pois vai subtrair 1 logo abaixo)
minuto_menor:
    dec byte [minuto]           ; Subtrai 1 do minuto (se era 60, vira 59)
    sti                         ; Reabilita interrupções
    jmp fim_le_tecla            ; Vai para o fim

; Z: aumenta um segundo (59 -> 0, sem alterar o minuto)
testa_z:
    cmp al, 2Ch                 ; Compara com o scancode da tecla Z
    jne testa_x                 ; Se não for pula para testar X
    cli                         ; Protege a alteração
    mov byte [tique], 0         ; Zera a contagem de tiques do timer para sincronizar o novo segundo
    inc byte [segundo]          ; Soma 1 ao segundo
    cmp byte [segundo], 60      ; Chegou ao limite?
    jb libera_seg_mais          ; Se menor, apenas segue
    mov byte [segundo], 0       ; Se chegou a 60, zera o segundo
libera_seg_mais:
    sti                         ; Reabilita interrupções
    jmp fim_le_tecla            ; Finaliza a leitura

; X: diminui um segundo (0 -> 59, sem alterar o minuto)
testa_x:
    cmp al, 2Dh                 ; Compara com o scancode da tecla X
    jne testa_d                 ; Se não for, pula para testar D
    cli                         
    mov byte [tique], 0         ; Zera os tiques novamente para precisão
    cmp byte [segundo], 0       ; Verifica se o segundo atual é 0
    jne segundo_menor           ; Se não for 0, só decrementa
    mov byte [segundo], 60      ; Prepara para virar 59 na linha de baixo
segundo_menor:
    dec byte [segundo]          ; Subtrai 1 segundo
    sti                          
    jmp fim_le_tecla            ; Fim do teste

; D: seleciona 12 horas
testa_d:
    cmp al, 20h                 ; Compara com o scancode da tecla D
    jne testa_v                 ; Se não for, testa a última opção (v)
    mov byte [formato], 12      ; Atualiza a flag de formato para 12
    jmp fim_le_tecla            ; Termina a leitura

; V: seleciona 24 horas
testa_v:
    cmp al, 2Fh                 ; Compara com o scancode da tecla V
    jne fim_le_tecla            ; Se não for nenhuma destas teclas, sai sem fazer nada
    mov byte [formato], 24      ; Atualiza a flag de formato para 24

fim_le_tecla:
    pop bx                      ; Restaura os registradores salvos na entrada (não mostrada aqui)
    pop ax
    ret                         ; Retorna da função


; MostraHora - Atualiza a tela
MostraHora:
    ; Salva contexto na pilha
    push ax                     
    push bx
    push dx
    push di

; Copia hora/minuto/segundo
    cli                         ; Desabilita interrupções para não ler uma hora pela metade
    mov al, [hora]              
    mov [hora_exib], al         ; Faz uma cópia da hora atual
    mov al, [minuto]
    mov [min_exib], al          ; Faz uma cópia do minuto
    mov al, [segundo]
    mov [seg_exib], al          ; Faz uma cópia do segundo
    sti                         ; Reabilita

; Posiciona o cursor no inicio da tela
    mov ah, 02h                 ; Função da bios para mover o cursor
    mov bh, 0                   ; Página de vídeo 0
    mov dh, 0                   ; Linha 0 (topo)
    mov dl, 0                   ; Coluna 0 (canto esquerdo)
    int 10h                     ; Chama a interrupção de vídeo da BIOS

; Verifica o formato escolhido
    cmp byte [formato], 12      ; Pergunta qual formato o usuário escolheu
    jne exibe_24                ; Se não for 12, pula para a lógica de 24h

; Formato de 12 horas:
    cmp byte [hora_exib], 12    ; Compara a hora copiada com 12
    jb antes_meio_dia           ; Se for menor que 12, é parte da manhã

    mov byte [periodo], 'P'     ; Sendo 12 ou mais, seta o indicador para 'P' (PM)
    cmp byte [hora_exib], 12    ; Confere se é exatamente 12 (meio-dia)
    je prepara_hora             ; Se for 12, não subtrai, apenas mostra 12 PM
    sub byte [hora_exib], 12    ; Se for > 12 (ex: 13, 14), subtrai 12 para mostrar 1, 2...
    jmp prepara_hora            ; Vai converter a hora

antes_meio_dia:
    mov byte [periodo], 'A'     ; Seta o indicador para A (AM)
    cmp byte [hora_exib], 0     ; Verifica se é meia-noite (0 horas)
    jne prepara_hora            ; Se não for meia-noite, mostra o número normal
    mov byte [hora_exib], 12    ; Se for 0, ajusta visualmente para 12 AM

prepara_hora:
    mov al, [hora_exib]         ; Pega o valor final da hora para exibir
    mov di, mostrador+6         ; Aponta para o local na string onde a hora será escrita
    call Converte               ; Chama função que transforma número binário em texto ASCII

    mov al, [periodo]           ; Pega o caractere A ou P
    mov [mostrador+15], al      ; Joga na posição do sufixo na string
    mov byte [mostrador+16], 'M' ; Completa o M
    mov byte [mostrador+17], ' ' ; Coloca um espaço extra para limpar lixo
    jmp exibe_min_seg           ; Vai desenhar os minutos e segundos

exibe_24:
    mov al, [hora_exib]         ; Pega a hora normal de 0 a 23
    mov di, mostrador+6         ; Aponta para o local na string
    call Converte               ; Converte para texto

    mov byte [mostrador+15], '2' ; Sobrescreve o espaço do AM/PM com 2
    mov byte [mostrador+16], '4' ; Adiciona 4
    mov byte [mostrador+17], 'h' ; Adiciona h ("24h")

exibe_min_seg:
    mov al, [min_exib]          ; Pega os minutos copiados
    mov di, mostrador+9         ; Aponta a memória para o local dos minutos na string
    call Converte               ; Converte

    mov al, [seg_exib]          ; Pega os segundos
    mov di, mostrador+12        ; Aponta para o local dos segundos
    call Converte               ; Converte

; Exibe a string
    mov dx, mostrador           ; Aponta DX para o começo da string completa
    mov ah, 09h                 ; Função do DOS para imprimir string até achar um $
    int 21h                     ; Chama a interrupção do DOS para imprimir na tela

    pop di                      ; Restaura os registradores na ordem inversa que salvou
    pop dx
    pop bx
    pop ax
    ret                         ; Fim da função de desenho


; Converte: AL (0 a 99) -> dois caracteres
; DI aponta para o primeiro caractere
Converte:
    push ax                     ; Salva contexto
    push bx

    xor ah, ah                  ; Limpa AH (parte alta de AX) para preparar a divisão
    mov bl, 10                  ; Vai dividir por 10 para separar as dezenas das unidades
    div bl                      ; Divide AX por BL. AL recebe quociente, AH recebe o resto

; AL = dezena; AH = unidade
    add al, '0'                 ; Soma o valor ASCII do zero (30h) para virar texto
    add ah, '0'                 ; Faz o mesmo com o resto (unidades)

    mov [di], al                ; Guarda o caractere da dezena na string
    mov [di+1], ah              ; Guarda o caractere da unidade na posição seguinte

    pop bx                      ; Restaura registradores
    pop ax
    ret


; Encerra: Restaura os vetores originais
encerra:
    cli                         ; Desliga as interrupções temporariamente
    xor ax, ax                  ; AX = 0
    mov es, ax                  ; ES = 0 (aponta para a base da memória, onde ficam os vetores)

; Restaura INT 8 (Timer)
    mov ax, [offset8]           ; Pega o offset original do DOS salvo antes
    mov [es:20h], ax            ; Devolve para o endereço correspondente (8 * 4 = 32 = 20h)
    mov ax, [cs8]               ; Pega o Segment original
    mov [es:22h], ax            ; Devolve na palavra seguinte

; Restaura INT 9 (Teclado)
    mov ax, [offset9]           ; Pega o offset original do teclado
    mov [es:24h], ax            ; Devolve para o endereço (9 * 4 = 36 = 24h)
    mov ax, [cs9]               ; Pega o Segment original
    mov [es:26h], ax            ; Devolve no lugar certo

    sti                         ; Religa as interrupções de hardware

    mov ax, 4C00h               ; AH = 4C (encerrar programa), AL = 0 (código de erro zero)
    int 21h                     ; Devolve o controle ao DOSBox




segment data

    ; Variaveis do relogio

    tique       db 0        ; tiques dentro do segundo atual
    ciclo       db 0        ; posicao no ciclo de 5 segundos (0 a 4)
    segundo     db 0
    minuto      db 0
    hora        db 0
    formato     db 24       ; 24h ou 12h
    periodo     db 'A'      ; A ou P
    offset8     dw 0
    cs8         dw 0
    offset9     dw 0
    cs9         dw 0
    tecla       times 8 db 0
    p_i         db 0        ; proxima posicao de escrita
    p_t         db 0        ; proxima posicao de leitura
    tecla_u     db 0        ; ultimo scancode lido pela isr
    sair        db 0        ; 1 = encerrar programa
    hora_exib   db 0        ; copias atomicas para exibicao
    min_exib    db 0
    seg_exib    db 0
    mostrador   db 'Hora: 00:00:00 24h   $'  ; Texto mostrado na tela

segment stack stack
    resb 512
stacktop: