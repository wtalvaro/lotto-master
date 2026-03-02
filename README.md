# 🎰 Lotto Master Shell Script

Um utilitário em Bash para análise estatística e geração de jogos baseados nos resultados reais das Loterias Caixa via API.

## 🚀 Funcionalidades
- Integração com API REST para busca de resultados históricos.
- Ranking de frequência (números "quentes") usando `sort`, `uniq` e `awk`.
- Geração de combinações inteligentes com embaralhamento aleatório (`shuf`).
- Suporte a múltiplas modalidades (Mega-Sena, Lotofácil, Quina, etc).

## 🛠️ Pré-requisitos
Certifique-se de ter os seguintes pacotes instalados (comuns em distribuições como **AlmaLinux** ou **Arch**):
- `curl`: Para requisições na API.
- `jq`: Para processamento de JSON no terminal.

## 📂 Instalação e Uso
1. Clone o repositório:
   ```bash
   git clone [https://github.com/seu-usuario/lotto-master.git](https://github.com/seu-usuario/lotto-master.git)
   cd lotto-master
