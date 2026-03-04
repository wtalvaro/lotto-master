#!/bin/bash

# =========================================================
# LOTOFÁCIL MASTER - Gerador Estatístico com Validação
# =========================================================

API_BASE="https://loteriascaixa-api.herokuapp.com/api/lotofacil"

# Argumentos (Padrão: 15 dezenas, 100 concursos de análise, 10 jogos)
DEZENAS_CARTAO=${1:-15}
ANALISE=${2:-100}
QTD_JOGOS=${3:-10}

echo -e "\033[1;34m[SISTEMA ESTATÍSTICO DEFINITIVO - LOTOFÁCIL]\033[0m"
echo "Coletando dados da API da Caixa..."

# -> NOVA LINHA COM PROTEÇÃO ANTI-BLOQUEIO (Retry e User-Agent) <-
raw_data=$(curl -s --retry 3 --retry-delay 2 --connect-timeout 10 -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64)" "$API_BASE")

if [[ -z "$raw_data" || "$raw_data" == *"error"* ]]; then
    echo -e "\033[1;31m[ERRO]\033[0m Falha ao conectar na API. Verifique sua conexão."; exit 1
fi

# 1. Coleta do Concurso Atual
concurso_atual=$(echo "$raw_data" | jq -r ".[0].concurso")
data_sorteio=$(echo "$raw_data" | jq -r ".[0].data")
mapfile -t resultado_oficial < <(echo "$raw_data" | jq -r ".[0].dezenas | .[]" | sort -n)

echo "--------------------------------------------------"
echo -e "📅 \033[1;36mÚLTIMO CONCURSO:\033[0m $concurso_atual ($data_sorteio)"
echo -e "✅ \033[1;36mRESULTADO OFICIAL:\033[0m ${resultado_oficial[*]}"
echo "--------------------------------------------------"

# 2. Coleta do Histórico Geral
echo "Analisando histórico de $ANALISE concursos para ponderação..."
mapfile -t historico < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]")
frequencia=$(printf "%s\n" "${historico[@]}" | sort | uniq -c | sort -nr)

# 3. Construção do Pool Ponderado
weighted_pool=""

# A) Adiciona números baseados na frequência geral
while read -r count num; do
    for ((i=0; i<count; i++)); do weighted_pool+="$num "; done
done <<< "$frequencia"

# B) Aplica o multiplicador (5x) nas dezenas do último sorteio (Efeito Memória)
for d in "${resultado_oficial[@]}"; do
    for i in {1..5}; do weighted_pool+="$d "; done
done

# 4. Motor de Geração, Filtros e Comparação
echo "--------------------------------------------------"
echo -e "🎯 GERANDO \033[1;32m$QTD_JOGOS\033[0m JOGOS OTIMIZADOS"
echo "--------------------------------------------------"

count_jogos=0
while [ $count_jogos -lt $QTD_JOGOS ]; do
    
    # Extrai uma amostra larga do pool, pega os únicos, mistura de novo e corta nas dezenas do cartão
    jogo_bruto=$(echo $weighted_pool | tr ' ' '\n' | shuf -n 60 | sort -u | shuf -n $DEZENAS_CARTAO | sort -n)
    
    # Validação de integridade (garante a quantidade exata de dezenas)
    if [ $(echo $jogo_bruto | wc -w) -eq $DEZENAS_CARTAO ]; then
        
        # Filtro de Paridade
        impares=0
        for n in $jogo_bruto; do
            [[ $((10#$n % 2)) -ne 0 ]] && ((impares++))
        done

        # Regra de Ouro da Lotofácil: 7 a 9 ímpares
        if [[ $impares -ge 7 && $impares -le 9 ]]; then
            ((count_jogos++))
            
            # Comparação com o Último Resultado (Cálculo de Acertos)
            acertos=0
            for n in $jogo_bruto; do
                for r in "${resultado_oficial[@]}"; do
                    if [[ "$n" == "$r" ]]; then
                        ((acertos++))
                        break
                    fi
                done
            done

            # Formatação visual para destacar pontuações altas (11 ou mais)
            if [ $acertos -ge 11 ]; then
                cor_acertos="\033[1;32m" # Verde para prêmios
            else
                cor_acertos="\033[1;33m" # Amarelo para normais
            fi

            # Impressão do Jogo
            printf "\033[1;34mJOGO #%02d:\033[0m %s | Acertos: ${cor_acertos}%02d\033[0m | Ímpares: %d\n" \
                "$count_jogos" "$(echo $jogo_bruto | xargs)" "$acertos" "$impares"
        fi
    fi
done

echo "--------------------------------------------------"
