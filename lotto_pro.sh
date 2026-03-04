#!/bin/bash

# API e Configurações
API_BASE="https://loteriascaixa-api.herokuapp.com/api"
LOTERIA=${1:-lotofacil}
DEZENAS_CARTAO=${2:-15}
ANALISE=${3:-100}
QTD_JOGOS=${4:-10}

# --- Validação de Paridade por Loteria ---
case $LOTERIA in
    "lotofacil") MIN_IMP=7; MAX_IMP=9 ;;
    "megasena")  MIN_IMP=2; MAX_IMP=4 ;;
    "quina")     MIN_IMP=2; MAX_IMP=3 ;;
    *)           MIN_IMP=0; MAX_IMP=$DEZENAS_CARTAO ;;
esac

echo -e "\033[1;34m[SISTEMA DE ANÁLISE E VALIDAÇÃO]\033[0m"
raw_data=$(curl -s --connect-timeout 10 "$API_BASE/$LOTERIA")

if [[ -z "$raw_data" || "$raw_data" == *"error"* ]]; then
    echo "Erro na conexão."; exit 1
fi

# 1. Resultado Oficial do Último Concurso
concurso_num=$(echo "$raw_data" | jq -r ".[0].concurso")
data_sorteio=$(echo "$raw_data" | jq -r ".[0].data")
mapfile -t resultado_oficial < <(echo "$raw_data" | jq -r ".[0].dezenas | .[]" | sort -n)

echo -e "📅 Concurso: \033[1;33m$concurso_num\033[0m ($data_sorteio)"
echo -e "✅ Resultado Oficial: \033[1;32m${resultado_oficial[*]}\033[0m"
echo "--------------------------------------------------"

# 2. Gerando Pool Ponderado (Data Science Logic)
mapfile -t historico < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]")
frequencia=$(printf "%s\n" "${historico[@]}" | sort | uniq -c | sort -nr)

weighted_pool=""
while read -r count num; do
    for ((i=0; i<count; i++)); do weighted_pool+="$num "; done
done <<< "$frequencia"

# 3. Geração, Filtro e Comparação
count_jogos=0
while [ $count_jogos -lt $QTD_JOGOS ]; do
    # Gera o jogo
    jogo_bruto=$(echo $weighted_pool | tr ' ' '\n' | shuf -n 40 | sort -u | shuf -n $DEZENAS_CARTAO | sort -n)
    
    # Validação de Paridade
    impares=0
    for n in $jogo_bruto; do
        [[ $((10#$n % 2)) -ne 0 ]] && ((impares++))
    done

    if [[ $impares -ge $MIN_IMP && $impares -le $MAX_IMP ]]; then
        ((count_jogos++))
        
        # --- Lógica de Comparação (Intersecção de Conjuntos) ---
        acertos=0
        for n in $jogo_bruto; do
            for r in "${resultado_oficial[@]}"; do
                [[ "$n" == "$r" ]] && ((acertos++))
            done
        done

        # Formatação do Output
        printf "\033[1;34mJOGO #%02d:\033[0m %s | \033[1;35mACERTOS: %d\033[0m (Ímpares: %d)\n" \
            "$count_jogos" "$(echo $jogo_bruto | xargs)" "$acertos" "$impares"
    fi
done
echo "--------------------------------------------------"
