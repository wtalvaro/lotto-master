#!/bin/bash

# API de Loterias
API_BASE="https://loteriascaixa-api.herokuapp.com/api"

# Funções de ajuda
usage() {
    echo "--------------------------------------------------"
    echo "Uso: $0 <loteria> <dezenas_no_cartao> <concursos_analisados> <qtd_jogos>"
    echo "--------------------------------------------------"
    echo "LOTERIAS SUPORTADAS:"
    echo " - megasena      - lotofacil     - quina"
    echo " - lotomania     - timemania     - duplasena"
    echo " - diadesorte    - federal       - maismilionaria"
    echo "--------------------------------------------------"
    echo "Exemplo: $0 lotofacil 15 100 5"
    echo "--------------------------------------------------"
    exit 1
}

# 1. Validação de Argumentos
if [ $# -lt 4 ]; then
    usage
fi

LOTERIA=$1
DEZENAS_CARTAO=$2
ANALISE=$3
QTD_JOGOS=$4

# 2. Início do Processamento
echo "--------------------------------------------------"
echo -e "\033[1;34m🔍 LOTERIA:\033[0m ${LOTERIA^^}"
echo -e "\033[1;34m📊 ANALISANDO:\033[0m ÚLTIMOS $ANALISE CONCURSOS"
echo -e "\033[1;34m🎯 OBJETIVO:\033[0m $QTD_JOGOS JOGO(S) DE $DEZENAS_CARTAO NÚMEROS"
echo "--------------------------------------------------"

# 3. Busca de Dados com tratamento de erro
echo "Conectando à API..."
raw_data=$(curl -s --connect-timeout 10 "$API_BASE/$LOTERIA")

if [[ -z "$raw_data" || "$raw_data" == *"Not Found"* || "$raw_data" == *"error"* ]]; then
    echo -e "\033[1;31m[ERRO]\033[0m Não foi possível obter dados para '$LOTERIA'."
    echo "Verifique a conexão ou o nome da loteria."
    exit 1
fi

# 4. Extração e Estatística
mapfile -t dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]" 2>/dev/null)

if [ ${#dezenas[@]} -eq 0 ]; then
    echo -e "\033[1;31m[ERRO]\033[0m Falha ao processar as dezenas. A API pode ter mudado o formato."
    exit 1
fi

# Ranking de Frequência
frequencia=$(printf "%s\n" "${dezenas[@]}" | sort | uniq -c | sort -nr)

# 5. Geração de Jogos Únicos
# Aumentamos o POOL para 25% a mais que o cartão para garantir variação
POOL_SIZE=$(( DEZENAS_CARTAO + (DEZENAS_CARTAO / 4) + 2 ))

echo "Gerando combinações inteligentes..."
echo "--------------------------------------------------"

for ((i=1; i<=QTD_JOGOS; i++)); do
    # Lógica de embaralhamento das dezenas mais frequentes
    jogo=$(echo "$frequencia" | head -n $POOL_SIZE | awk '{print $2}' | shuf | head -n $DEZENAS_CARTAO | sort -n | xargs)
    
    echo -e "\033[1;33mJOGO #$i:\033[0m \033[1;32m$jogo\033[0m"
done

echo "--------------------------------------------------"
top3=$(echo "$frequencia" | head -n 3 | awk '{print $2}' | xargs)
echo -e "\033[1;36m💡 Dica:\033[0m As 3 dezenas mais quentes: $top3"
