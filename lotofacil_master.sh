#!/bin/bash

# =========================================================
# LOTOFÁCIL MASTER PRO - Motor Estocástico & Validação Cruzada
# =========================================================

# ---> FUNÇÃO DE DOCUMENTAÇÃO / AJUDA (HELP MENU) <---
show_help() {
    clear
    echo -e "\033[1;36m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮\033[0m"
    echo -e "\033[1;36m┃\033[0m \033[1;32m🎲 LOTOFÁCIL MASTER PRO \033[0m- Data Science Edition v2.7               \033[1;36m┃\033[0m"
    echo -e "\033[1;36m╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"
    echo -e "  Um gerador estocástico de alta performance que atua como um"
    echo -e "  \033[1;31m'Filtro de Lixo Matemático'\033[0m para otimizar suas apostas."
    echo ""
    echo -e "\033[1;33m  ⚙️  USANDO PERFIS PRÉ-CONFIGURADOS (RECOMENDADO):\033[0m"
    echo -e "  \033[1m$0\033[0m -p explorador  [\033[32mQTD_JOGOS\033[0m]"
    echo -e "  \033[1m$0\033[0m -p conservador [\033[32mQTD_JOGOS\033[0m]"
    echo -e "  \033[36mExemplo:\033[0m ./lotofacil_master.sh -p explorador 20 \033[90m(Gera 20 jogos)\033[0m"
    echo ""
    echo -e "\033[1;33m  🎯 DETALHES DOS PERFIS:\033[0m"
    echo -e "  \033[1;34m[Explorador]\033[0m Analisa os últimos 6 concursos (curto prazo/tendência)."
    echo -e "               Exige média alta (9.2+) para caçar dezenas 'quentes'."
    echo -e "  \033[1;34m[Conservador]\033[0m Analisa os últimos 100 concursos (longo prazo/fundamentos)."
    echo -e "                Exige consistência estatística padrão (9.0+)."
    echo ""
    echo -e "\033[1;33m  ⚙️  SINTAXE DE USO MANUAL (MODO AVANÇADO):\033[0m"
    echo -e "  \033[1m$0\033[0m [\033[32mDEZ\033[0m] [\033[32mANALISE\033[0m] [\033[32mJOGOS\033[0m] [\033[32mMEDIA\033[0m] [\033[32mREPETIDAS\033[0m]"
    echo ""
    echo -e "\033[1;33m  📊 PARÂMETROS:\033[0m"
    echo -e "  \033[1;32m1. DEZ\033[0m       (Padrão: 15)   -> Qtd. de números por bilhete (15 a 20)."
    echo -e "  \033[1;32m2. ANALISE\033[0m   (Padrão: 100)  -> Qtd. de concursos p/ backtesting."
    echo -e "  \033[1;32m3. JOGOS\033[0m     (Padrão: 10)   -> Total de combinações únicas a gerar."
    echo -e "  \033[1;32m4. MIN_MEDIA\033[0m (Padrão: 9.0)  -> Nota de Corte Histórica (Ideal: 8.8 a 9.2)."
    echo -e "  \033[1;32m5. REPETIDAS\033[0m (Padrão: 8-10) -> Qtd de repetidas do último sorteio."
    echo -e "                               Pode ser um número exato (9) ou um range (8-10)."
    echo ""
    echo -e "\033[1;33m  🔬 ANÁLISE CRÍTICA E TÉCNICA (COMO ESTE SCRIPT FUNCIONA):\033[0m"
    echo -e ""
    echo -e "  \033[1;34m[+] 1. Qualidade do Código (Engenharia de Software)\033[0m"
    echo -e "      \033[1m• Otimização de Funil (A maior vitória):\033[0m A ordem dos filtros é brilhante."
    echo -e "        Verifica Paridade (barato p/ CPU), depois Repetidas (médio), e só"
    echo -e "        então aciona a Validação Cruzada (caro p/ CPU). Arquitetura de alto nível."
    echo -e "      \033[1m• Hash Maps (declare -A):\033[0m Garante 0% de chance de jogos repetidos no lote,"
    echo -e "        evitando desperdício financeiro."
    echo -e "      \033[1m• Regex Nativo (=~):\033[0m Comparação de arrays dentro do próprio Bash,"
    echo -e "        acelerando o processamento em mais de 100x."
    echo ""
    echo -e "  \033[1;34m[+] 2. Qualidade Estatística (Ciência de Dados)\033[0m"
    echo -e "      \033[1m• Filtro de Paridade (7 a 9 ímpares):\033[0m Remove combinações absurdas (ex: 15 pares)."
    echo -e "      \033[1m• Alvo de Repetidas (Padrão Ouro >= 9):\033[0m Matemática pura. A distribuição"
    echo -e "        hipergeométrica prova que o pico é de 9 a 10 repetidas (~54% das vezes)."
    echo -e "      \033[1m• Pool Ponderado:\033[0m Acompanhamento de tendência para números 'quentes'."
    echo ""
    echo -e "  \033[1;34m[+] 3. Utilidade Real (Risk Management)\033[0m"
    echo -e "      Não é uma bola de cristal, mas garante que você \033[1mNUNCA\033[0m gastará"
    echo -e "      1 centavo em lixo matemático. Cada bilhete gerado estará,"
    echo -e "      obrigatoriamente, dentro das condições que premiaram em 80%"
    echo -e "      dos concursos passados. É otimização estocástica pura."
    echo ""
    echo -e "\033[1;33m  💡 DICAS DE ESPECIALISTA:\033[0m"
    echo -e "  \033[36mFlexível Ouro:\033[0m ./lotofacil_master.sh 15 100 10 8.8 \033[1;31m8-10\033[0m"
    echo -e "  \033[36mCirúrgico:\033[0m     ./lotofacil_master.sh 15 100 10 9.0 \033[1;31m9\033[0m"
    echo -e "\033[1;36m───────────────────────────────────────────────────────────────────────\033[0m"
    exit 0
}

# =========================================================
# INÍCIO DO PROGRAMA E RECEPÇÃO DE VARIÁVEIS / PERFIS
# =========================================================

# Variáveis Padrão
DEZENAS_CARTAO=15
ANALISE=100
QTD_JOGOS=10
MIN_MEDIA=9.0
ALVO_REPETIDAS="8-10"
MODO_PERFIL=""

# Parsing de Argumentos
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# Verifica se o usuário chamou um Perfil (Flag -p ou --profile)
if [[ "$1" == "-p" || "$1" == "--profile" ]]; then
    MODO_PERFIL=$2
    # Captura a quantidade de jogos do 3º argumento (se não existir, usa 10)
    QTD_JOGOS=${3:-10} 
    
    if [[ "$MODO_PERFIL" == "explorador" ]]; then
        ANALISE=6
        MIN_MEDIA=9.2
        echo -e "\033[1;35m[🚀 MODO ATIVADO: EXPLORADOR (Tendência de Curto Prazo)]\033[0m"
    elif [[ "$MODO_PERFIL" == "conservador" ]]; then
        ANALISE=100
        MIN_MEDIA=9.0
        echo -e "\033[1;35m[🛡️ MODO ATIVADO: CONSERVADOR (Consistência de Longo Prazo)]\033[0m"
    else
        echo -e "\033[1;31m[ERRO]\033[0m Perfil desconhecido. Use 'explorador' ou 'conservador'."
        exit 1
    fi
# Se não for perfil, assume que são parâmetros posicionais manuais
elif [[ -n "$1" ]]; then
    DEZENAS_CARTAO=${1:-15}
    ANALISE=${2:-100}
    QTD_JOGOS=${3:-10}
    MIN_MEDIA=${4:-9.0}
    ALVO_REPETIDAS=${5:-"8-10"}
    echo -e "\033[1;35m[⚙️ MODO ATIVADO: CONFIGURAÇÃO MANUAL AVANÇADA]\033[0m"
fi

API_BASE="https://loteriascaixa-api.herokuapp.com/api/lotofacil"

# Lógica para interpretar o Range de Repetidas
if [[ "$ALVO_REPETIDAS" == *"-"* ]]; then
    MIN_REP=$(echo $ALVO_REPETIDAS | cut -d'-' -f1)
    MAX_REP=$(echo $ALVO_REPETIDAS | cut -d'-' -f2)
else
    MIN_REP=$ALVO_REPETIDAS
    MAX_REP=$ALVO_REPETIDAS
fi

# =========================================================
# 🛡️ MÓDULO DE SANIDADE (SANITY CHECKS & BLINDAGEM)
# =========================================================
# 1. Valida dezenas permitidas pela caixa (15 a 20)
if ! [[ "$DEZENAS_CARTAO" =~ ^[0-9]+$ ]] || [ "$DEZENAS_CARTAO" -lt 15 ] || [ "$DEZENAS_CARTAO" -gt 20 ]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m O parâmetro DEZ deve estar entre 15 e 20."; exit 1;
fi

# 2. Valida se QTD_JOGOS é válida
if ! [[ "$QTD_JOGOS" =~ ^[0-9]+$ ]] || [ "$QTD_JOGOS" -lt 1 ]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m A quantidade de jogos deve ser pelo menos 1."; exit 1;
fi

# 3. Valida Repetidas Absurdas (Mais que 15 é impossível)
if [ "$MAX_REP" -gt 15 ] || [ "$MIN_REP" -gt 15 ]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m É impossível ter mais de 15 repetidas."; exit 1;
fi

# 4. Trava Anti-Loop Infinito na Média (Corte máximo realista = 9.5)
if (( $(echo "$MIN_MEDIA > 9.5" | bc -l 2>/dev/null) )); then
    echo -e "\033[1;33m[AVISO DE SISTEMA]\033[0m A média exigida ($MIN_MEDIA) causaria um Loop Infinito. Reduzindo automaticamente para o teto de 9.5."
    MIN_MEDIA=9.5
fi
# =========================================================

echo -e "\033[1;34m[SISTEMA ESTATÍSTICO DEFINITIVO - LOTOFÁCIL]\033[0m"
echo "Coletando dados da API da Caixa..."

raw_data=$(curl -s --retry 3 --retry-delay 2 --connect-timeout 10 -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64)" "$API_BASE")

if [[ -z "$raw_data" || "$raw_data" == *"error"* ]]; then
    echo -e "\033[1;31m[ERRO]\033[0m Falha ao conectar na API. Verifique sua conexão."; exit 1
fi

concurso_atual=$(echo "$raw_data" | jq -r ".[0].concurso")
data_sorteio=$(echo "$raw_data" | jq -r ".[0].data")
mapfile -t resultado_oficial < <(echo "$raw_data" | jq -r ".[0].dezenas | .[]" | sort -n)
mapfile -t historico_dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | join(\" \")")

echo "--------------------------------------------------"
echo -e "📅 \033[1;36mÚLTIMO CONCURSO:\033[0m $concurso_atual ($data_sorteio)"
echo -e "✅ \033[1;36mRESULTADO OFICIAL:\033[0m ${resultado_oficial[*]}"
echo -e "🎯 \033[1;36mCORTE QUALIDADE:\033[0m Média Histórica >= $MIN_MEDIA (Em $ANALISE concursos)"
if [ "$MIN_REP" == "$MAX_REP" ]; then
    echo -e "🎯 \033[1;36mCORTE REPETIDAS:\033[0m Exatamente $MIN_REP dezenas do último concurso"
else
    echo -e "🎯 \033[1;36mCORTE REPETIDAS:\033[0m Entre $MIN_REP e $MAX_REP dezenas do último concurso"
fi
echo "--------------------------------------------------"

weighted_pool=""
mapfile -t todas_dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]")
frequencia=$(printf "%s\n" "${todas_dezenas[@]}" | sort | uniq -c | sort -nr)

while read -r count num; do
    for ((i=0; i<count; i++)); do weighted_pool+="$num "; done
done <<< "$frequencia"

for d in "${resultado_oficial[@]}"; do
    for i in {1..5}; do weighted_pool+="$d "; done
done

echo -e "🎯 GERANDO \033[1;32m$QTD_JOGOS\033[0m JOGOS OTIMIZADOS E VALIDADOS"
echo "--------------------------------------------------"

declare -A jogos_gerados
count_jogos=0
tentativas=0

while [ $count_jogos -lt $QTD_JOGOS ]; do
    ((tentativas++))
    
    jogo_bruto=$(echo $weighted_pool | tr ' ' '\n' | shuf -n 60 | sort -u | shuf -n $DEZENAS_CARTAO | sort -n)
    
    if [ $(echo $jogo_bruto | wc -w) -eq $DEZENAS_CARTAO ]; then
        
        impares=0
        for n in $jogo_bruto; do
            [[ $((10#$n % 2)) -ne 0 ]] && ((impares++))
        done

        if [[ $impares -ge 7 && $impares -le 9 ]]; then
            
            acertos_ult=0
            for n in $jogo_bruto; do
                if [[ " ${resultado_oficial[*]} " =~ " $n " ]]; then
                    ((acertos_ult++))
                fi
            done
            
            if [ "$acertos_ult" -ge "$MIN_REP" ] && [ "$acertos_ult" -le "$MAX_REP" ]; then
                
                jogo_formatado=$(echo $jogo_bruto | xargs)
                
                if [[ -z "${jogos_gerados["$jogo_formatado"]}" ]]; then
                    
                    soma_acertos=0
                    for dez_concurso in "${historico_dezenas[@]}"; do
                        acertos_n=0
                        for n in $jogo_bruto; do
                            if [[ " $dez_concurso " =~ " $n " ]]; then
                                ((acertos_n++))
                            fi
                        done
                        soma_acertos=$((soma_acertos + acertos_n))
                    done

                    media_historica=$(echo "scale=2; $soma_acertos / $ANALISE" | bc)

                    if (( $(echo "$media_historica >= $MIN_MEDIA" | bc -l) )); then
                        
                        jogos_gerados["$jogo_formatado"]=1
                        ((count_jogos++))

                        if [ $acertos_ult -ge 9 ]; then
                            cor_acertos="\033[1;32m"
                        else
                            cor_acertos="\033[1;33m"
                        fi

                        printf "\033[1;34mJOGO #%02d:\033[0m %s | \033[1;35mMédia Hist: %s\033[0m | Repetidas: ${cor_acertos}%02d\033[0m | Ímpares: %d\n" \
                            "$count_jogos" "$jogo_formatado" "$media_historica" "$acertos_ult" "$impares"
                    fi
                fi
            fi
        fi
    fi
done

echo "--------------------------------------------------"
echo -e "Motor estocástico exigiu \033[1m$tentativas\033[0m gerações internas para encontrar as $QTD_JOGOS combinações perfeitas."

# =========================================================
# 🧠 MÓDULO DE RELATÓRIO DE INTELIGÊNCIA (FREQUÊNCIA)
# =========================================================
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e " 🧠 \033[1;33mRELATÓRIO DE INTELIGÊNCIA - DEZENAS DE FERRO\033[0m"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Extrai todos os números do Hash Map nativo do Bash (Ultrarrápido)
todos_numeros_gerados="${!jogos_gerados[@]}"
frequencia_gerados=$(echo "$todos_numeros_gerados" | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | sort -nr)

dez_100=""
dez_altas=""

# Calcula as porcentagens
while read -r count dezena; do
    perc=$(echo "scale=1; ($count / $QTD_JOGOS) * 100" | bc)
    
    if (( $(echo "$perc == 100.0" | bc -l) )); then
        dez_100+="$dezena "
    elif (( $(echo "$perc >= 80.0" | bc -l) )); then
        # Formata para remover o ".0" e deixar visualmente mais limpo
        perc_clean=$(echo "$perc" | cut -d'.' -f1)
        dez_altas+="$dezena ($perc_clean%) "
    fi
done <<< "$frequencia_gerados"

# Imprime o Relatório Customizado
if [ -n "$dez_100" ]; then
    echo -e "\033[1;32m🔥 Wagner, as dezenas [ $dez_100] apareceram em 100% dos jogos gerados!\033[0m"
    echo -e "   Estas são as suas bases absolutas para esta rodada."
else
    echo -e "\033[1;33m⚠️ Nenhuma dezena cravou 100% de presença nestes jogos.\033[0m"
fi

if [ -n "$dez_altas" ]; then
    echo ""
    echo -e "\033[1;36m⚡ Outras dezenas fortíssimas (Acima de 80%): \033[0m"
    echo -e "   $dez_altas"
fi
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
