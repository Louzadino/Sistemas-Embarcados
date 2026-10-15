segment code
..start:
        CLI									; Deshabilita INTerrupções por harDWare - pin INTR NÃO atende INTerrupções externas
		XOR 	AX, AX						; Limpa o registrador AX, é equivALente a fazer "MOV AX,0"
		MOV 	ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [ES:08h*4]				; Carrega em AX o vALor do IP do vector de INTerrupção 8
		MOV     [offset_dos_8], AX    		; Salva na variável offset_dos o vALor do IP do vector de INTerrupção 8
		MOV     AX, [ES:INTr*4+2]   		; Carrega em AX o vALor do CS do vector de INTerrupção 8
		MOV     [cs_dos], AX  				; Salva na variável cs_dos o vALor do CS do vector de INTerrupção 8   
		MOV     [ES:INTr*4+2], CS			; Atualiza o valor do CS do vector de INTerrupção 8 com o CS do programa atuAL
		MOV     WORD [ES:INTr*4],ClockINT	; Atualiza o valor do IP do vector de INTerrupção 8 com o offset "ClockINT" do programa atuAL
		STI									; Habilita INTerrupções por harDWare - pin INTR SIM atende INTerrupções externas

        CLI									; Deshabilita INTerrupções por harDWare - pin INTR NÃO atende INTerrupções externas
		XOR 	AX, AX						; Limpa o registrador AX, é equivALente a fazer "MOV AX,0"
		MOV 	ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [ES:09h*4]				; Carrega em AX o vALor do IP do vector de INTerrupção 9
		MOV     [offset_dos_9], AX    		; Salva na variável offset_dos o vALor do IP do vector de INTerrupção 9
		MOV     AX, [ES:INTr*4+2]   		; Carrega em AX o vALor do CS do vector de INTerrupção 9
		MOV     [cs_dos_9], AX  				; Salva na variável cs_dos o vALor do CS do vector de INTerrupção 9   
		MOV     [ES:INTr*4+2], CS			; Atualiza o valor do CS do vector de INTerrupção 9 com o CS do programa atuAL
		MOV     WORD [ES:INTr*4],ClockINT	; Atualiza o valor do IP do vector de INTerrupção 9 com o offset "ClockINT" do programa atuAL
		STI									; Habilita INTerrupções por harDWare - pin INTR SIM atende INTerrupções externas

fim:										; Ao sair do programa temos que restaurar o CS:IP da Interrupção 8 e 9
		CLI									; Deshabilita Interrupções por harDWare - pin INTR NÃO atende Interrupções externas							
		XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
		MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [cs_dos_8]				; Carrega em AX o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     [ES:08h*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     AX, [offset_dos_8]			; Carrega em AX o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos				
		MOV     [ES:08h*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos
		MOV     AH, 4Ch						; Carrega em AH o valor de 4Ch, parametro para INT 21h
		INT     21h							; Chama Interrupção 21h para RETornar o controle ao sistema operacional -> sai de forma segura da execução do programa

		CLI									; Deshabilita Interrupções por harDWare - pin INTR NÃO atende Interrupções externas							
		XOR     AX, AX						; Limpa o registrador AX, é equivalente a fazer "MOV AX,0"
		MOV     ES, AX						; Inicializa o registrador de Segmento Extra ES para acessar à região de vetores de INTerrupção (posição zero de memoria)
		MOV     AX, [cs_dos_9]				; Carrega em AX o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     [ES:09h*4+2], AX			; Atualiza o valor do CS do vector de INTerrupção 8 que foi salvo na variável cs_dos
		MOV     AX, [offset_dos_9]			; Carrega em AX o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos				
		MOV     [ES:09h*4], AX 			; Atualiza o valor do IP do vector de INTerrupção 8 que foi salvo na variável offset_dos
		MOV     AH, 4Ch						; Carrega em AH o valor de 4Ch, parametro para INT 21h
		INT     21h							; Chama Interrupção 21h para RETornar o controle ao sistema operacional -> sai de forma segura da execução do programa

ClockINT:									; Este segmento de código só será executado se um pulso de relojio está ativo, ou seja, se a INT 8h for acionada!
		PUSH	AX							; Salva contexto na pilha							
		PUSH	DS
		MOV     AX,data						; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data"
		MOV     DS,AX						; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!	
    
		INC		byte [tique]				; Incremente variável tique toda vez que entra na interrupção
		CMP		byte[tique], 18				; Compara variável "teique" com 18, isso para alterar os valores do relogio a cada segundo -> 18/18.2 ~1 segundo!
		JB		Fimrel						; Se for menor que 18 pula para Fimrel
		MOV 	byte [tique], 0				; Se não, limpa variável tique e  
		INC 	byte [segundo]				; Incrementa variável segundo
		CMP 	byte [segundo], 60			; Compara variável "segundo" com 60
		JB   	Fimrel						; Se segundo for menor do que 60, pula para Fimrel
		MOV 	byte [segundo], 0			; Se não, limpa segundo e
		INC 	byte [minuto]				; Incrementa variável minuto
		CMP 	byte [minuto], 60			; Compara variável "minuto" com 60
		JB   	Fimrel						; Se minuto for menor do que 60, pula para Fimrel
		MOV 	byte [minuto], 0			; Se não, limpa minuto e
		INC 	byte [hora]					; Incrementa variável hora
		CMP 	byte [hora], 24				; Compara variável "hora" com 24
		JB   	Fimrel						; Se hora for menor do que 24, pula para Fimrel
		MOV 	byte [hora], 0				; Se não, limpa hora	

keyINT:									; Este segmento de código só será executado se uma tecla for presionada, ou seja, se a INT 9h for acionada!
        PUSH    AX						; Salva contexto na pilha
        PUSH    BX
        PUSH    DS
 ;       MOV     AX,data					; Carrega em AX o endereço de "data" -> Região do código onde encontra-se o segemeto de dados "Segment data" 			
 ;       MOV     DS,AX					; Atualiza registrador de segmento de dados DS, isso pode ser feito no inicio do programa!
        IN      AL, kb_data				; Le a porta 60h, que é onde está o byte do Make/Break da tecla. Esse valor é fornecido pelo chip "8255 PPI"
        INC     WORD [p_i]				; Incrementa p_i para indicar no loop principal que uma tecla foi acionada!
        AND     WORD [p_i],7			
        MOV     BX,[p_i]				; Carrega p_i em BX
        MOV     [BX+tecla],al			; Transfere o valor Make/Break da tecla armacenado em AL "linha 84" para o segmento de dados com offset DX, na variável "tecla"
        IN      AL, kb_ctl				; Le porta 61h, pois o bit mais significativo "bit 7" 
        OR      AL, 80h					; Faz operação lógica OR com o bit mais significativo do registrador AL (1XXXXXXX) -> Valor lido da porta 61h 
        OUT     kb_ctl, AL				; Seta o bit mais significativo da porta 61h
        AND     AL, 7Fh					; Restablece o valor do bit mais significativo do registrador AL (0XXXXXXX), alterado na linha 90 	
        OUT     kb_ctl, AL				; Reinicia o registrador de dislocamento 74LS322 e Livera a interrupção "CLR do flip-flop 7474". O 8255 - Programmable Peripheral Interface (PPI) fica pronto para recever um outro código da tecla https://es.wikipedia.org/wiki/INTel_8255
        MOV     AL, eoi					; Carrega o AL com a byte de End of Interruption, -> 20h por default
        OUT     pictrl, AL				; Livera o PIC
        
		POP     DS						; Reestablece os registradores salvos na linha 79 
        POP     BX
        POP     AX
        IRET							; Retorna da interrupção

segment data
        ; Para o PIC
        pictrl  EQU 20h					; PORTA DO PIC DE TECLADO
        eoi     EQU 20h					; Byte de final de interrupção 

        ; Para o teclado
        kb_data EQU 60h  				; PORTA DE LEITURA DE TECLADO
        kb_ctl  EQU 61h  				; PORTA DE RESET PARA PEDIR NOVA 

        ; Números das interrupções
        INT8    EQU 08h                 ; Interrupção por hardware do timer
        INT9    EQU 09h					; Interrupção por hardware do teclado

        ; Backup da interrupções originais
        offset_dos_8    DW 0
        cs_dos_8        DW 0
        offset_dos_9    DW 0
        cd_dos_9        DW 0

        ; Variáveis para controle do tempo
        tique		DB  0					; Variável de 2 bytes que é incrementada a cada tick do clock ~54.9 ms 
        segundo		DB  0					; Variável para os segundos
        minuto 		DB  0					; Variável para os minutos
        hora 		DB  0					; Variável para as horas
        
        modo_12h DB 0                   ; Para controlar se a exibição será em 12h ou 24h
        horario		DB  0,0,':',0,0,':',0,0,' ','A','M', 13,'$' ; Variável typo string para printar o relogio
        