; montar   - nasm -f elf64 fib.asm
; ligar    - ld fbib.o -o fib.x
; executar - ./fib.x

%define maxChars 3    ; max de caracteres lidos
%define openrw  2102o ; abertura de arquivo para leitura, escrita e append
%define userWR 644o   ; permissoes de usuario
; section .data - dados inicializados
section .data 
    msg  : db "Informe o n-essimo numero Fibonacci buscado:", 10, 0 ; string, \n, \0
    msgL : equ $  - msg                                             ; tamanho da string em bytes

    msg_erro     : db "[ERRO] - Argumentos Invalidos!", 10, 0 ; string, \n, \0
    size_msgerro : equ $ - msg_erro                           ; tamanho da string em bytes

    buffer       : db 100          ; 100 bytes para 0ah
    
    prefixo      : db "fib("       ; prefixo para inicio do nome do arquivo - 4 Bytes 
    size_prefixo : equ $ - prefixo ; tamanho do prefixo em bytes
    
    sufixo       : db ").bin", 0   ; sufixo para final do nome do arquivo - 5 Bytes
    size_sufixo  : equ $ - sufixo  ; tamanho do sufixo em bytes

; section .bss - dados nao-inicializados
section .bss
    numero       : resb maxChars ; entrada lida armazenada - 3 bytes, 24 bits, (2 digitos + enter)
    numero_size  : resd 1        ; numero de caracteres lido, dualword, 4 Bytes, 32 bits

    inteiro      : resq 1        ; armazena digito ASCII convertido para inteiro, quadword, 8 Bytes, 64 bits 
    ;inteiroL     : resq 1

    nome_arquivo : resb 255      ; 255 bytes para nome do arquivo
    fileHandle   : resd 1        ; 4 bytes para referencia temporaria ao arquivo

    valor        : resq 1        ; 8 bytes para armazenar no arquivo
; section .text - instrucoes
section .text
    global _start

; _start - execucoes, main()
_start:
    ; zerando todos os registradores para evitar conflitos
    xor rax, rax
    xor rdi, rdi
    xor rax, rax
    xor rsi, rsi
    xor edx, edx
    xor rdx, rdx
    xor ebx, ebx

; string mensagem que solicita o n-essimo numero Fibonacci
escrever_pergunta:
    mov rax, 1     ; chamada de sistema write
    mov rdi, 1     ; define saida padrao
    lea rsi, [msg] ; endereco de memoria da string que sera exibida na tela
    mov edx, msgL  ; comprimento da string
    syscall        ; chamada de sistema para execucao

; leitura do numero informado pelo usuario
leitura_numero:
    mov rax, 0             ; chama de sistema read
    mov rdi, 1             ; define a entrada padrao
    lea rsi, [numero]      ; endereco de memoria do valor que sera lido
    mov edx, maxChars      ; numero maximo de caracteres a serem lidos
    syscall                ; chamada de sistema para execucao
    mov [numero_size], eax ; numero de caracteres lidos da entrada

; concatencao de strings fib(n).bin = prefixo + n + sufixo
; abertura de arquivo binario para leitura e escrita
; converter o digito numerio ASCII para um inteiro equivalente
converter_string_inteiro:
    jmp verifica_1digito     ; verifica a existencia de apenas 1 digito
    converter1:              ; converte apenas unidade
        xor rax, rax         ; zera rax para armazenar o digito numerico ASCII convertido
        mov al, [numero]     ; movimento o primeiro digito de 8 bits
        sub al, "0"          ; converte para inteiro   
        mov [inteiro], rax   ; movimenta o novo valor 64 bits
        cmp rax, 0           ; verifica se o numero é == 0
        je mensagem_erro     ; executa mensagem de erro se numero for == 0
        jmp fibonacci        ; jump para executar a sequencia fibonacci
    converter2:              ; converte unidade e dezena
        xor rax, rax         ; zera rax para armazenar o digito numerico ASCII convertido
        mov al, [numero]     ; movimenta o primeiro digito de 8 bits
        mov bl, [numero + 1] ; movimenta o segundo digito de 8 bits
        sub al, "0"          ; converte o primeiro digito
        sub bl, "0"          ; converte o segundo digito
        imul rax, 10         ; multiplica o segundo digito para dezena
        add al, bl           ; soma os numeros inteiros convertidos
        mov [inteiro], rax   ; movimenta o novo valor 64 bits
        cmp rax, 93          ; verificacao do limite de representacao 2^n > 64 bits
        jg mensagem_erro     ; se rax > 93 entao dispara mensagem de erro
        jmp fibonacci        ; jump para executar a sequencia fibonacci

; verificar se o usuario inreriou apenas 1 digito
verifica_1digito:
    lea esi , [numero]           ; endereco de memoria do valor lido
    mov bl, [esi + 1]            ; movimena para bl o 2 byte de esi
    cmp bl, 10                   ; compara se o 2 byte é igual a \n indicando assim apenas 1 digito
    jne verificar_2digitos       ; verifica a existencia de 2 digitos
    jmp converter1               ; converte apenas a unidade

; verificar se o usuario inseriu 2 digitos apenas
verificar_2digitos:
    lea esi, [numero]            ; endereco de memoria do valor lido
    mov cl, [esi + 2]            ; movimenta para cl o 3 byte de esi
    cmp cl, 10                   ; compara se o 3 byte é igual a \n indicando assim apenas 2 digitos
    jne mensagem_erro            ; cmp == 0 prossegue, caso not equal entao encerra programa com mensagem de erro
    jmp converter2               ; converte a unidade e dezena   
fibonacci:
    xor r9, r9          ; r9 == 0, contador
    xor r13, r13        ; fib(0) == 0
    mov r14, 0x0001     ; fib(1) == 1
    Loop:
    mov r15, r14        ; fib(2) = fib(1)
    add r15, r13        ; fib(2) = fib(0)  
    mov r13, r14        ; fib(0) = fib(1) - r13 possui o valor fibonacci final
    mov r14, r15        ; fib(1) = fib(2)
    inc r9              ; incrementa contador
    cmp r9b, [inteiro]  ; compara os 8 primeiro bits de r9 contador com o valor lido
    jne Loop            ; loop enquanto r9 != valor

; concatenacao  das strings + abertura do arquivo binario
arquivo_binario:    
    xor r15, r15 ; zera para armazenar prefixo fib(
    xor r14, r14 ; zera para armazenar n
    xor r11, r11 ; zera para armazenar sufixo ).bin
    xor eax, eax ; zera para armazenar bytes de n e descartar \n
    
    mov r14, qword [numero]       ; movimenta numero para r14
    mov r15, qword [prefixo]      ; movimenta fib( para r15
    mov r11, qword [sufixo]       ; movimenta ).bin para r11
    mov eax, 4                    ; movimenta quatidade de bytes de fib( para eax
    mov [nome_arquivo], r15       ; concatena fib( para o nome do arquivo
    mov [nome_arquivo + eax], r14 ; concatena o n\n ao final de fib(
    add eax, [numero_size]        ; adiciona bytes de n ao total de bytes ficando fib(n\n o tamanho total
    dec eax                       ; subtrai o byte de \n
    mov [nome_arquivo + eax], r11 ; concatena sufixo ).bin ao restante do nome, ficando fib(n).bin

    mov rax, 2            ; abertura do arquivo      
    lea rdi, [nome_arquivo]    ; nome do arquivo que sera aberto
    mov esi, openrw       ; modo de abertura 
    mov edx, userWR       ; permissoes do usuario
    syscall 
    mov [fileHandle], eax ; descritor do arquivo para referencia ao mesmo

; escrever no arquivo binario o valor fib
escreve_arquivo: 
    mov qword[valor], r13 ; movimenta o valor fib para o endereco de memoria apontado
    mov rax, 1            ; operacao de escrita no arquivo
    mov edi, [fileHandle] ; referencia ao arquivo aberto
    lea rsi, [valor]      ; carrega o endereco do valor que sera escrito no arquivo
    mov edx, 8            ; tamanha em bytes do dado que sera escrito
    syscall           

; fechamento do arquivo binario
fecha:
    mov rax, 3            ; operacao de fechamento do arquivo
    mov edi, [fileHandle] ; referencia ao arquivo que deve ser fechado
    syscall
    jmp fim

; mensagem de erro generica
mensagem_erro:
    mov rax, 1             ; chamada de sistema write
    mov rdi, 1             ; define saida padrao
    lea rsi, [msg_erro]    ; endereco de memoria da string que sera exibida na tela
    mov edx, size_msgerro  ; comprimento da string
    syscall                ; chamada de sistema para execucao

; limpeza do buffer antes de encerrar o programa
limpeza_buffer:
    xor eax, eax    ; zera eax
    mov al, 0ah     ; caractere de limpeza de buffer, \n
    mov ecx, 100    ; armazena o valor do buffer, 100 bytes
    mov edi, buffer ; ponteiro para o endereco do inicio do buffer
    rep stosb       ; preenche buffer com 0ah, repete store string ate zerar ecn
; return 0
fim:
    mov rax, 60 ; chamada de sistema exit
    mov rdi, 0  ; codigo de retorno de execucao com sucesso
    syscall     ; chamada de sistema para execucao
