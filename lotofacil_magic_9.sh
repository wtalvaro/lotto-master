#!/bin/bash

# =========================================================
# LOTOFÁCIL MASTER PRO v4.9 - Data Science & Estocástica
# Fusão Híbrida: Posicionais + Backtesting + Filtros + CSV
# Arquitetura Otimizada (Não-Interativa, Getopts, Math Nativa & Regex)
# =========================================================

set -u
: "${SRANDOM:=$RANDOM}"

readonly PRIMES_STR=" 02 03 05 07 11 13 17 19 23 "
readonly MAGIC_9_STR=" 05 06 07 12 13 14 19 20 21 "

# =========================================================
# FUNÇÕES AUXILIARES E DOCUMENTAÇÃO
# =========================================================

sort_array() {
    local -n arr=$1
    local i j tmp
    local size=${#arr[@]}
    
    for ((i = 0; i < size; i++)); do
        for ((j = i + 1; j < size; j++)); do
            if (( 10#${arr[i]} > 10#${arr[j]} )); then
                tmp=${arr[i]}
                arr[i]=${arr[j]}
                arr[j]=$tmp
            fi
        done
    done
}

show_help() {
    local C_CYAN="\033[1;36m"
    local C_GREEN="\033[1;32m"
    local C_YELLOW="\033[1;33m"
    local C_BLUE="\033[1;34m"
    local C_BOLD="\033[1m"
    local C_DIM="\033[90m"
    local C_ITALIC="\033[3m"
    local C_RESET="\033[0m"

    echo -e "$(cat << EOF

${C_CYAN}======================================================================${C_RESET}
${C_GREEN} 🎲 LOTOFÁCIL MASTER PRO - MANUAL DO USUÁRIO & DOCS (v4.9) ${C_RESET}
${C_CYAN}======================================================================${C_RESET}

${C_YELLOW}📌 DESCRIÇÃO GERAL${C_RESET}
  Motor de investimento estatístico voltado para o ${C_BOLD}'Apostador Profissional'${C_RESET}.
  Focado em maximizar prêmios de 11 a 14 pontos através de desdobramentos
  econômicos e filtragem rigorosa de dados históricos da Caixa Econômica.

${C_YELLOW}⚙️  LÓGICA E FUNCIONAMENTO (Filtros Avançados)${C_RESET}
  ${C_BLUE}• Padrão dos Nove Números:${C_RESET} Fixa a base nas dezenas ${C_BOLD}05, 06, 07, 12, 13,
    14, 19, 20 e 21${C_RESET}. O algoritmo permite selecionar subconjuntos (4, 5 ou 6)
    desses números como âncora de segurança para a geração dos jogos.
  ${C_BLUE}• Filtros Estatísticos Estocásticos:${C_RESET}
    - ${C_ITALIC}Equilíbrio Par/Ímpar:${C_RESET} Mantém a proporção harmônica no volante.
    - ${C_ITALIC}Números Primos:${C_RESET} Prioriza a inclusão da zona de ouro (7 primos).
    - ${C_ITALIC}Tendência de Extremidades:${C_RESET} Força a bola 1 a sair entre 01-04
      e a bola 15 a sair obrigatoriamente entre 22-25.
  ${C_BLUE}• Recorrência de Sorteio:${C_RESET} Busca repetir rigorosamente de ${C_BOLD}8 a 9 dezenas${C_RESET}
    do concurso anterior para alinhar-se aos padrões matemáticos de sorteio.

${C_YELLOW}💻 EXEMPLOS DE EXECUÇÃO${C_RESET}

  ${C_GREEN}[1] Execução Padrão (Sem Argumentos):${C_RESET}
  $ ${C_BOLD}$0${C_RESET}
  ${C_DIM}↳ Assume: 15 dezenas, 100 concursos, 10 jogos, média 9.0, 8-10 repetidas.${C_RESET}

  ${C_GREEN}[2] Perfil Conservador (Foco em Histórico Sólido):${C_RESET}
  $ ${C_BOLD}$0 -p conservador${C_RESET}
  ${C_DIM}↳ Assume: 15 dezenas, 100 concursos, 10 jogos, média 9.0, 8-10 repetidas.${C_RESET}

  ${C_GREEN}[3] Perfil Explorador (Busca de Tendências Recentes):${C_RESET}
  $ ${C_BOLD}$0 -p explorador${C_RESET}
  ${C_DIM}↳ Assume: 15 dezenas, 6 concursos, 10 jogos, média 9.2, 8-10 repetidas.${C_RESET}

  ${C_GREEN}[4] Execução Modo Manual (Parâmetros Posicionais):${C_RESET}
  ${C_ITALIC}Ordem:${C_RESET} [DEZENAS] [ANALISE] [QTD_JOGOS] [MIN_MEDIA] [REPETIDAS]
  $ ${C_BOLD}$0 15 50 20 9.2 "8-9"${C_RESET}
  ${C_DIM}↳ Gera 20 jogos com média >= 9.2 nos últimos 50 concursos e cravando
    entre 8 a 9 repetidas do último sorteio.${C_RESET}

  ${C_GREEN}[5] Foco Estatístico (Alta Probabilidade no Padrão dos Nove):${C_RESET}
  $ ${C_BOLD}$0 -m 5${C_RESET}
  ${C_DIM}↳ Justificativa: Padrão de maior frequência histórica e recente (~32%).${C_RESET}

  ${C_GREEN}[6] Execução Híbrida (Flag -m + Modo Manual):${C_RESET}
  $ ${C_BOLD}$0 -m 6 15 80 5 9.1 "9"${C_RESET}
  ${C_DIM}↳ Fixa 6 dezenas do Padrão dos Nove e aplica a ordem manual restante.${C_RESET}

  ${C_GREEN}[7] Ajuda do Sistema:${C_RESET}
  $ ${C_BOLD}$0 -h${C_RESET}
  ${C_DIM}↳ Exibe este manual técnico sem limpar a tela.${C_RESET}

  ${C_GREEN}[8] Modo de Exportação e Auditoria Automática (Não-Interativo):${C_RESET}
  $ ${C_BOLD}$0 -s ./minha_analise.csv${C_RESET}
  ${C_DIM}↳ O script roda de forma contínua e salva o histórico analítico e os 
    jogos gerados diretamente no caminho/arquivo especificado.${C_RESET}

${C_CYAN}======================================================================${C_RESET}
EOF
)"
    
    exit 0
}

print_dynamic_header() {
    echo -e "\n\033[1;36m╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮\033[0m"
    echo -e "\033[1;36m┃\033[0m \033[1;32m📈 MOTOR DE INVESTIMENTO ESTATÍSTICO \033[0m- Iniciando Sessão...        \033[1;36m┃\033[0m"
    echo -e "\033[1;36m╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯\033[0m"
    echo -e " \033[1;33m► STATUS DOS FILTROS ESTRUTURAIS:\033[0m"

    if [[ -n "$MAGIC_9_MODE" ]]; then
        echo -e "   \033[1;34m[✔]\033[0m Padrão dos Nove: \033[1;32mATIVO (Fixado em $MAGIC_9_MODE Dezenas)\033[0m"
    else
        echo -e "   \033[1;34m[✔]\033[0m Padrão dos Nove: \033[1;33mDINÂMICO (Aceitando de 4 a 6 Dezenas)\033[0m"
    fi

    echo -e "   \033[1;34m[✔]\033[0m Equilíbrio Par/Ímpar: \033[1;32mATIVO (Margem de 7 a 9 Ímpares)\033[0m"
    echo -e "   \033[1;34m[✔]\033[0m Números Primos: \033[1;32mATIVO (Exigindo de 5 a 7 Primos)\033[0m"
    echo -e "   \033[1;34m[✔]\033[0m Extremidades: \033[1;32mATIVO (Início: 01-04 | Fim: 22-25)\033[0m"
    
    if [[ -n "$MODO_PERFIL" && "$MODO_PERFIL" != "manual" ]]; then
        echo -e "   \033[1;34m[✔]\033[0m Perfil Operacional: \033[1;35m${MODO_PERFIL^^} (Análise: $ANALISE concursos)\033[0m"
    else
        echo -e "   \033[1;34m[✔]\033[0m Perfil Operacional: \033[1;35mMANUAL AVANÇADO (Análise: $ANALISE concursos)\033[0m"
    fi

    if [[ "$EXPORTAR" -eq 1 ]]; then
        echo -e "   \033[1;34m[✔]\033[0m Exportação Ativa: \033[1;32mSalvando em $ARQUIVO_CSV\033[0m"
    fi

    echo -e "\033[1;36m───────────────────────────────────────────────────────────────────────\033[0m"
    echo -e " \033[3mPreparando matriz estocástica. Tratando jogo como investimento...\033[0m"
    echo -e "\033[1;36m───────────────────────────────────────────────────────────────────────\033[0m\n"
}

# =========================================================
# PARSING DE ARGUMENTOS COM GETOPTS E POSICIONAIS
# =========================================================

DEZENAS_CARTAO=15
ANALISE=100
QTD_JOGOS=10
MIN_MEDIA=9.0
ALVO_REPETIDAS="8-10"
MODO_PERFIL="default"
MAGIC_9_MODE=""
EXPORTAR=0
ARQUIVO_CSV=""

# Suporte alternativo para --help
for arg in "$@"; do
    if [[ "$arg" == "--help" ]]; then show_help; fi
done

while getopts "hm:p:s:" opt; do
    case $opt in
        h)
            show_help
            ;;
        m)
            MAGIC_9_MODE=$OPTARG
            if [[ "$MAGIC_9_MODE" != "4" && "$MAGIC_9_MODE" != "5" && "$MAGIC_9_MODE" != "6" ]]; then
                echo -e "\033[1;31mErro:\033[0m O padrão -m aceita apenas os valores 4, 5 ou 6 com base em frequências estatísticas."
                exit 1
            fi
            ;;
        p)
            MODO_PERFIL=$OPTARG
            ;;
        s)
            EXPORTAR=1
            ARQUIVO_CSV=$OPTARG
            ;;
        \?)
            echo -e "\033[1;31m[ERRO]\033[0m Opção inválida."
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

if [[ "$MODO_PERFIL" == "explorador" || "$MODO_PERFIL" == "exp" ]]; then
    MODO_PERFIL="explorador"
    ANALISE=6
    MIN_MEDIA=9.2
    QTD_JOGOS=${1:-10}
elif [[ "$MODO_PERFIL" == "conservador" ]]; then
    ANALISE=100
    MIN_MEDIA=9.0
    QTD_JOGOS=${1:-10}
elif [[ $# -gt 0 ]]; then
    DEZENAS_CARTAO=${1:-15}
    ANALISE=${2:-100}
    QTD_JOGOS=${3:-10}
    MIN_MEDIA=${4:-9.0}
    ALVO_REPETIDAS=${5:-"8-10"}
    MODO_PERFIL="manual"
fi

# =========================================================
# 1. VALIDAÇÃO DE INPUTS GERAIS (Segurança Total)
# =========================================================

if ! [[ "$DEZENAS_CARTAO" =~ ^[0-9]+$ ]] || ! [[ "$ANALISE" =~ ^[0-9]+$ ]] || ! [[ "$QTD_JOGOS" =~ ^[0-9]+$ ]]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m Parâmetros inválidos! [DEZENAS], [ANALISE] e [QTD_JOGOS] devem ser números inteiros."
    exit 1
fi

# 1.1 Validação de Média Decimal (Aceita "9", "9.2" ou "9,2")
if ! [[ "$MIN_MEDIA" =~ ^[0-9]+([.,][0-9]+)?$ ]]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m Parâmetro [MIN_MEDIA] inválido. Utilize um número inteiro ou decimal (ex: 9.0)."
    exit 1
fi

# 1.2 Validação de Repetidas (Aceita "9" ou intervalo "8-10")
if ! [[ "$ALVO_REPETIDAS" =~ ^[0-9]+(-[0-9]+)?$ ]]; then
    echo -e "\033[1;31m[ERRO FATAL]\033[0m Parâmetro [REPETIDAS] inválido. Utilize um número (ex: 9) ou intervalo (ex: 8-10)."
    exit 1
fi

# Processamento pós-validação
if [[ "$ALVO_REPETIDAS" == *"-"* ]]; then
    MIN_REP=$(echo "$ALVO_REPETIDAS" | cut -d'-' -f1)
    MAX_REP=$(echo "$ALVO_REPETIDAS" | cut -d'-' -f2)
else
    MIN_REP=$ALVO_REPETIDAS
    MAX_REP=$ALVO_REPETIDAS
fi

print_dynamic_header

# =========================================================
# COLETOR DA API E PROCESSAMENTO ESTATÍSTICO
# =========================================================
API_BASE="https://loteriascaixa-api.herokuapp.com/api/lotofacil"

echo "📡 Conectando à base de dados da Caixa..."

raw_data=$(curl -s --retry 3 --retry-delay 2 --connect-timeout 10 -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64)" "$API_BASE")

if [[ -z "$raw_data" || "$raw_data" == *"error"* ]]; then
    echo -e "\033[1;31m[ERRO]\033[0m Falha ao conectar na API. Verifique sua conexão."; exit 1
fi

total_concursos_api=$(echo "$raw_data" | jq length)
idx_antigo=$((ANALISE - 1))
if (( idx_antigo >= total_concursos_api )); then
    idx_antigo=$((total_concursos_api - 1))
    ANALISE=$total_concursos_api
fi

concurso_atual=$(echo "$raw_data" | jq -r ".[0].concurso")
concurso_antigo=$(echo "$raw_data" | jq -r ".[$idx_antigo].concurso")
data_sorteio=$(echo "$raw_data" | jq -r ".[0].data")

mapfile -t resultado_oficial < <(echo "$raw_data" | jq -r ".[0].dezenas | .[]" | sort -n)
mapfile -t historico_dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | join(\" \")")

echo -e "✅ \033[1;36mBASE SINCRONIZADA:\033[0m Concurso $concurso_atual ($data_sorteio)"
echo -e "📌 \033[1;36mÚLTIMO SORTEIO:\033[0m ${resultado_oficial[*]}"
echo "--------------------------------------------------"

# =========================================================
# MÓDULO DE EXPORTAÇÃO E AUDITORIA (NÃO-INTERATIVO)
# =========================================================

if [[ $EXPORTAR -eq 1 ]]; then
    echo -e "\033[1;33m[ EXPORTAÇÃO DE DADOS ]\033[0m"
    # Cria o diretório alvo, caso não exista
    mkdir -p "$(dirname "$ARQUIVO_CSV")"
    
    echo "=== DADOS_DA_ANALISE ===" > "$ARQUIVO_CSV"
    echo "CONCURSO,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15" >> "$ARQUIVO_CSV"
    echo "$raw_data" | jq -r ".[0:$ANALISE] | .[] | [.concurso] + .dezenas | join(\",\")" >> "$ARQUIVO_CSV"
    
    printf "\n=== JOGOS_GERADOS ===\n" >> "$ARQUIVO_CSV"
    echo "ID_JOGO,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,MEDIA_HIST,REPETIDAS,IMPARES,PRIMOS,M9" >> "$ARQUIVO_CSV"
    
    echo -e "📝 \033[3mHistórico de $ANALISE concursos e jogos será gravado em: $ARQUIVO_CSV\033[0m"
    echo "--------------------------------------------------"
fi

# =========================================================
# CONSTRUÇÃO DO POOL
# =========================================================
weighted_pool=""
mapfile -t todas_dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]")
frequencia=$(printf "%s\n" "${todas_dezenas[@]}" | sort | uniq -c | sort -nr)

while read -r count num; do
    for ((i=0; i<count; i++)); do weighted_pool+="$num "; done
done <<< "$frequencia"

for d in "${resultado_oficial[@]}"; do
    for i in {1..5}; do weighted_pool+="$d "; done
done

declare -a weighted_array=($weighted_pool)
pool_size=${#weighted_array[@]}

declare -A jogos_gerados
count_jogos=0
tentativas=0

MIN_MEDIA="${MIN_MEDIA//,/.}"
MIN_MEDIA_INT=$(awk -v m="$MIN_MEDIA" 'BEGIN { printf "%.0f", m * 100 }')

# =========================================================
# MOTOR ESTOCÁSTICO FUNDIDO
# =========================================================
while [ $count_jogos -lt $QTD_JOGOS ]; do
    
    ((tentativas++))
    if (( tentativas > 500000 )); then
        echo -e "\n\033[1;31m[ERRO CRÍTICO]\033[0m Paradoxo Estatístico detectado! Os filtros exigidos são restritivos demais e impossibilitam a geração matemática. Operação abortada."
        break
    fi
    
    declare -a candidate=()
    declare -A candidate_map=()
    
    while ((${#candidate[@]} < DEZENAS_CARTAO)); do
        idx=$((SRANDOM % pool_size))
        num=${weighted_array[$idx]}
        if [[ -z "${candidate_map[$num]:-}" ]]; then
            candidate_map[$num]=1
            candidate+=("$num")
        fi
    done
    
    sort_array candidate
    
    if (( 10#${candidate[0]} > 4 || 10#${candidate[DEZENAS_CARTAO-1]} < 22 )); then continue; fi
    
    impares=0
    primos=0
    m9_count=0
    acertos_ult=0
    
    for n in "${candidate[@]}"; do
        (( 10#$n % 2 != 0 )) && ((impares++))
        [[ "$PRIMES_STR" =~ " $n " ]] && ((primos++))
        [[ "$MAGIC_9_STR" =~ " $n " ]] && ((m9_count++))
        [[ " ${resultado_oficial[*]} " =~ " $n " ]] && ((acertos_ult++))
    done
    
    if [[ $impares -lt 7 || $impares -gt 9 ]]; then continue; fi
    if [[ $primos -lt 5 || $primos -gt 7 ]]; then continue; fi
    
    if [[ -n "$MAGIC_9_MODE" ]]; then
        if [[ $m9_count -ne $MAGIC_9_MODE ]]; then continue; fi
    else
        if [[ $m9_count -lt 4 || $m9_count -gt 6 ]]; then continue; fi
    fi
    
    if [[ "$acertos_ult" -lt "$MIN_REP" || "$acertos_ult" -gt "$MAX_REP" ]]; then continue; fi
    
    jogo_formatado="${candidate[*]}"
    
    if [[ -z "${jogos_gerados["$jogo_formatado"]:-}" ]]; then
        soma_acertos=0
        for dez_concurso in "${historico_dezenas[@]}"; do
            acertos_n=0
            for n in "${candidate[@]}"; do
                [[ " $dez_concurso " =~ " $n " ]] && ((acertos_n++))
            done
            soma_acertos=$((soma_acertos + acertos_n))
        done

        media_historica_int=$(( (soma_acertos * 100) / ANALISE ))

        if (( media_historica_int >= MIN_MEDIA_INT )); then
            jogos_gerados["$jogo_formatado"]=1
            ((count_jogos++))

            cor_acertos="\033[1;33m"
            [ "$acertos_ult" -ge 9 ] && cor_acertos="\033[1;32m"

            media_historica_display=$(printf "%.2f" "$((media_historica_int))e-2")

            printf "\033[1;34m[JOGO %02d]\033[0m %s | \033[1;35mMédia: %s\033[0m | Rep: ${cor_acertos}%02d\033[0m | Ímp: %d | Pri: %d | M9: %d\n" \
                "$count_jogos" "$jogo_formatado" "$media_historica_display" "$acertos_ult" "$impares" "$primos" "$m9_count"
            
            if [[ $EXPORTAR -eq 1 ]]; then
                dezenas_csv=$(echo "$jogo_formatado" | tr ' ' ',')
                echo "$count_jogos,$dezenas_csv,$media_historica_display,$acertos_ult,$impares,$primos,$m9_count" >> "$ARQUIVO_CSV"
            fi
        fi
    fi
done

echo "--------------------------------------------------"
echo -e "Motor exigiu \033[1m$tentativas\033[0m micro-ciclos de força bruta guiada."

# =========================================================
# RELATÓRIO DE INTELIGÊNCIA
# =========================================================
echo ""
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e " 🧠 \033[1;33mRELATÓRIO DE INTELIGÊNCIA - DEZENAS DE FERRO\033[0m"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

todos_numeros_gerados="${!jogos_gerados[@]}"
frequencia_gerados=$(echo "$todos_numeros_gerados" | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | sort -nr)

dez_100=""
dez_altas=""

while read -r count dezena; do
    perc_int=$(( (count * 100) / QTD_JOGOS ))

    if [[ $perc_int -eq 100 ]]; then
        dez_100+="$dezena "
    elif [[ $perc_int -ge 80 ]]; then
        dez_altas+="$dezena (${perc_int}%) "
    fi
done <<< "$frequencia_gerados"

if [ -n "$dez_100" ]; then
    echo -e "\033[1;32m🔥 wtalvaro, as dezenas [ $dez_100] apareceram em 100% dos jogos gerados!\033[0m"
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
