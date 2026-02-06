# Fibonacci Iterativo em Assembly x86-64 (NASM)

Implementação em Assembly (sintaxe Intel x86-64) para cálculo do n-ésimo número de Fibonacci de forma **iterativa**, conforme requisitos acadêmicos da atividade.

## 📚 Contexto da Atividade

A proposta consiste em:

- Construir um código **iterativo** (sem recursão)
- Utilizar sintaxe Intel x86-64
- Receber entrada via teclado (ASCII)
- Validar entrada (máximo 2 dígitos)
- Converter ASCII para inteiro
- Calcular fibonacci iterativamente
- Gerar um arquivo binário no formato:

fib(n).bin


Contendo o resultado armazenado diretamente em formato binário (8 bytes).


## ⚙️ Funcionamento do Programa

### 🔹 Entrada

- O usuário informa `n`
- Entrada aceita:
  - 1 ou 2 dígitos numéricos
  - Finalizada com ENTER
- Casos inválidos:
  - `n = 0`
  - Mais de 2 dígitos
  - Valores que excedam limite de representação em 64 bits
- Em caso de erro:
  - Mensagem genérica exibida
  - Buffer limpo
  - Programa encerrado
  - Nenhum arquivo gerado


### 🔹 Conversão ASCII → Inteiro

O programa converte os caracteres ASCII manualmente:

'0' = 0x30
'1' = 0x31
...
'9' = 0x39


Utilizando subtração de '0' e notação posicional:

Exemplo:
"34" → (10 * 3) + 4 = 34


### 🔹 Cálculo Iterativo

A sequência é calculada conforme:

fib(0) = 0
fib(1) = 1
fib(i) = fib(i-1) + fib(i-2)


Sem uso de recursividade.

A implementação utiliza registradores de 64 bits para armazenar os valores.


### 🔹 Geração do Arquivo

Após cálculo:

- O nome do arquivo é construído dinamicamente:
fib(n).bin


- O valor é gravado em formato binário (8 bytes)
- Não há conversão para ASCII
- O arquivo pode ser visualizado com editor hexadecimal

Exemplo de saída esperada (visualizado em hex editor):

0x0000000000006FF1


## 🛠 Compilação e Execução

nasm -f elf64 fib.asm -o fib.o

ld fib.o -o fib.x

./fib.x
