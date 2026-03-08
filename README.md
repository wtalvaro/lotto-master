# 🎰 LOTOFÁCIL MASTER PRO

**Motor de Análise Estocástica e Engenharia de Dados Nível Industrial**

> *"A loteria deixa de ser um jogo de azar quando a tratamos como um negócio de longo prazo baseado em estatística."*

O **Lotofácil Master Pro** não é um mero gerador de números aleatórios (RNG). É um motor de investimento estatístico de alta performance, desenhado arquiteturalmente para o **Apostador Profissional**. Utilizando algoritmos de força bruta guiada, ele cruza milhares de combinações estocásticas em milissegundos contra a base de dados histórica da Caixa Econômica Federal.

O objetivo primário do motor é cercar matematicamente as faixas de premiação de **11 a 15 pontos**, descartando combinações esdrúxulas ou estatisticamente inviáveis antes mesmo que você gaste seu dinheiro com elas.

---

## 🚀 Arquitetura e Diferenciais de Performance

Este script foi refatorado para operar nos limites da velocidade do interpretador Bash, entregando uma performance comparável a linguagens compiladas como C/C++.

* ⚡ **Zero-Fork Architecture (Eliminação de Subshells):** O maior gargalo de scripts Bash é a criação de processos secundários via `$(...)`. Este motor utiliza **Namerefs (`local -n`)** nativos do Bash 4.3+ para passar arrays complexos por referência de memória. O resultado é a erradicação de syscalls `fork()`, permitindo que loops pesados rodem integralmente no processo pai.
* 🧠 **Indexação em RAM O(1):** O histórico completo de sorteios da Lotofácil é baixado e estruturado em **Arrays Associativos (`declare -A`)**. Isso elimina a latência desastrosa de I/O de disco. A validação de ineditismo de uma aposta ocorre em tempo constante **O(1)**.
* 🛡️ **Circuit Breaker (Disjuntor de Segurança):** Filtros excessivamente rigorosos podem gerar um "Paradoxo Lógico" onde nenhuma combinação matemática é possível. O motor possui uma trava térmica de **500.000 micro-ciclos**. Se o limite for atingido, o sistema aborta a operação graciosamente com `exit 1`, prevenindo loops infinitos e o travamento (starvation) da CPU do seu servidor.

---

## 📊 Filtros Estruturais Ativos

O algoritmo aplica um funil estocástico implacável. Somente as combinações que sobrevivem a **todos** os testes abaixo chegam ao terminal do usuário:

1. **Exclusividade Histórica Estrita:** Bloqueia automaticamente qualquer jogo que já tenha saído nos concursos anteriores. *A história não costuma se repetir 100%.*
2. **O Padrão dos Nove (M9):** O motor monitora as 9 "dezenas mágicas" (`05, 06, 07, 12, 13, 14, 19, 20, 21`). Estatisticamente, elas são os pilares de jogos vencedores. O sistema calibra sua presença dinamicamente (geralmente entre 4 a 6 dezenas).
3. **Análise de Extremidades:** Restrição de *Range*. A estatística dita a regra: a **Bola 1** deve obrigatoriamente iniciar entre `01` e `04`, e a **Bola 15** deve fechar o bilhete entre `22` e `25`.
4. **Filtros Clássicos Modulados:** * **Números Primos:** Apenas jogos contendo de 5 a 7 dezenas do conjunto raiz (`02, 03, 05, 07, 11, 13, 17, 19, 23`).
* **Paridade:** Equilíbrio estrito, forçando a geração de 7 a 9 números ímpares por bilhete.


5. **Dezenas Repetidas (R):** Cruzamento nativo via Regex com o último concurso sorteado, exigindo a retenção da tendência primária (8 a 9 dezenas do concurso anterior).

---

## 💻 UX Clean e Filosofia Unix (CLI)

O motor foi programado respeitando rigorosamente os descritores de arquivo POSIX. Ele implementa o **Smart Output Routing**:

* **Logs e UI (`STDERR / >&2`):** Todas as mensagens de `[INFO]`, avisos de sistema, relatórios visuais coloridos e resumos estocásticos trafegam pela Saída de Erro.
* **Dados Puros (`STDOUT / >1`):** A Saída Padrão emite única e exclusivamente a matriz de resultados estruturada.

Isso garante que você possa canalizar a inteligência gerada para arquivos ou outros softwares sem contaminar seus dados com caracteres ANSI (cores) ou textos de debug.

### Dependências e Requisitos de Sistema

* **OS:** AlmaLinux, Arch Linux, ou qualquer distribuição Unix/Linux moderna.
* **Bash:** Versão 4.4 ou superior (Obrigatório para suporte a *Namerefs* e *Associative Arrays*).
* **Pacotes:** `jq` (para o parsing ultrarrápido do JSON da API) e `curl`.

---

## 🛠️ Exemplo de Execução e Flags

A interface de linha de comando é processada via `getopts`.

**Sintaxe Básica:**

```bash
./lotofacil_magic_9.sh [OPÇÕES] [DEZENAS] [ANALISE] [QTD_JOGOS] [MIN_MEDIA] [REPETIDAS]

```

**Flags Disponíveis:**

* `-a` : Desativa o disjuntor de Exclusividade (Permite gerar jogos passados).
* `-m [VALOR]` : Força a quantidade específica de dezenas do Padrão M9 (ex: `-m 5`).
* `-p [PERFIL]` : Carrega perfis pré-configurados de risco (`explorador` ou `conservador`).
* `-s [ARQUIVO.csv]` : Exportação paralela invisível (Salva os dados brutos no CSV enquanto exibe a interface rica na tela).

**Exemplo de Execução no Terminal (Visualização Rica):**

```bash
./lotofacil_magic_9.sh -p explorador 5

```

**Exemplo de Redirecionamento Estrito para Auditoria (Arquivos limpos):**

```bash
# O terminal exibirá apenas o progresso, mas 'meus_jogos.csv' conterá as planilhas puras
./lotofacil_magic_9.sh -m 5 15 50 10 9.2 "8-9" > meus_jogos.csv

```

---

## ⚖️ Aviso Legal e Responsabilidade

**Este software é uma ferramenta de apoio analítico.** Embora o algoritmo aplique as heurísticas e probabilidades mais avançadas para otimizar os bilhetes gerados (reduzindo o custo com apostas "mortas"), sorteios lotéricos são, por definição, eventos físicos e matematicamente independentes.

**Nenhum software garante vitórias ou prêmios.** Utilize este motor de forma consciente, respeitando as leis locais sobre jogos e atuando estritamente dentro de suas capacidades de gestão financeira de risco. Jogue com responsabilidade.
