#!/bin/bash

# ==============================================================================
# LOTOFÁCIL MASTER PRO - Motor Estocástico Nível Industrial (v10.0)
# Arquitetura: Alta Performance O(1), Matriz de Metadados, Strict STDOUT Routing
# ==============================================================================

set -u
: "${SRANDOM:=$RANDOM}"

# ==============================================================================
# CONSTANTES E VARIÁVEIS GLOBAIS
# ==============================================================================
readonly PRIMES_STR=" 02 03 05 07 11 13 17 19 23 "
readonly MAGIC_9_STR=" 05 06 07 12 13 14 19 20 21 "
readonly CACHE_FILE="$HOME/.lotofacil_cache.json"
readonly API_BASE="https://loteriascaixa-api.herokuapp.com/api/lotofacil"
readonly MAX_RETRY=500000

# Variáveis de Estado (CLI)
ALLOW_REPEATED=0
MAGIC_9_MODE=""
EXPORTAR=0
ARQUIVO_CSV=""
MODO_PERFIL="default"

# Parâmetros Estocásticos Padrão
DEZENAS_CARTAO=15
ANALISE=100
QTD_JOGOS=10
MIN_MEDIA=9.0
ALVO_REPETIDAS="8-10"
MIN_REP=8
MAX_REP=10

# Arrays Associativos (Tabelas Hash em RAM O(1))
declare -A map_exclusividade
declare -A jogos_gerados_sessao

# ==============================================================================
# ALGORITMOS NATIVOS E LOGGING (STDERR >&2)
# ==============================================================================
log_info()    { printf "\033[1;36m[INFO]\033[0m %s\n" "$1" >&2; }
log_success() { printf "\033[1;32m[SUCESSO]\033[0m %s\n" "$1" >&2; }
log_error()   { printf "\033[1;31m[ERRO]\033[0m %s\n" "$1" >&2; }

sort_numeric_array() {
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
    cat << EOF >&2
Uso: $0 [OPÇÕES] [DEZENAS] [ANALISE] [QTD_JOGOS] [MIN_MEDIA] [REPETIDAS]

FILTROS ATIVOS POR PADRÃO:
  - Tendência de Extremidades: ATIVO (01-04 | 22-25)
  - Exclusividade Histórica: ATIVO (Bloqueio de repetidos)

OPÇÕES:
  -a          Desativa o bloqueio de exclusividade.
  -m [VALOR]  Fixa a quantidade de dezenas do Padrão dos Nove (4, 5 ou 6).
  -p [PERFIL] Carrega perfil de aposta (explorador | conservador).
  -s [ARQ]    Salva dados brutos no CSV de forma independente.
  -h          Exibe este menu de ajuda.

EXEMPLO MANUAL E REDIRECIONAMENTO UNIX (Auditoria):
  $0 -m 5 15 50 20 9.2 "8-9" > relatorio_auditoria.txt
EOF
    exit 0
}

# ==============================================================================
# PARSING DE ARGUMENTOS CLI
# ==============================================================================
parse_arguments() {
    while getopts "ahm:p:s:" opt; do
        case $opt in
            a) ALLOW_REPEATED=1 ;;
            h) show_help ;;
            m) 
                MAGIC_9_MODE=$OPTARG
                if [[ "$MAGIC_9_MODE" != "4" && "$MAGIC_9_MODE" != "5" && "$MAGIC_9_MODE" != "6" ]]; then
                    log_error "O padrão -m aceita apenas os valores 4, 5 ou 6."
                    exit 1
                fi
                ;;
            p) MODO_PERFIL=$OPTARG ;;
            s) EXPORTAR=1; ARQUIVO_CSV=$OPTARG ;;
            \?) log_error "Opção inválida."; exit 1 ;;
        esac
    done

    shift $((OPTIND - 1))

    if [[ "$MODO_PERFIL" == "explorador" ]]; then
        ANALISE=6; MIN_MEDIA=9.2; QTD_JOGOS=${1:-10}
    elif [[ "$MODO_PERFIL" == "conservador" ]]; then
        ANALISE=100; MIN_MEDIA=9.0; QTD_JOGOS=${1:-10}
    elif [[ $# -gt 0 ]]; then
        DEZENAS_CARTAO=${1:-15}
        ANALISE=${2:-100}
        QTD_JOGOS=${3:-10}
        MIN_MEDIA=${4:-9.0}
        ALVO_REPETIDAS=${5:-"8-10"}
        MODO_PERFIL="manual"
    fi
}

validate_inputs() {
    if ! [[ "$DEZENAS_CARTAO" =~ ^[0-9]+$ ]] || ! [[ "$ANALISE" =~ ^[0-9]+$ ]] || ! [[ "$QTD_JOGOS" =~ ^[0-9]+$ ]]; then
        log_error "Parâmetros [DEZENAS], [ANALISE] e [QTD_JOGOS] devem ser inteiros."
        exit 1
    fi
    if [[ "$ALVO_REPETIDAS" == *"-"* ]]; then
        MIN_REP=$(echo "$ALVO_REPETIDAS" | cut -d'-' -f1)
        MAX_REP=$(echo "$ALVO_REPETIDAS" | cut -d'-' -f2)
    else
        MIN_REP=$ALVO_REPETIDAS
        MAX_REP=$ALVO_REPETIDAS
    fi
}

# ==============================================================================
# BOOTSTRAP: INDEXAÇÃO DE DADOS O(1) EM RAM
# ==============================================================================
bootstrap_data() {
    log_info "Sincronizando base de dados da Lotofácil..."

    local raw_data=""
    raw_data=$(curl -s --retry 2 --connect-timeout 5 -H "User-Agent: Mozilla/5.0" "$API_BASE" || true)

    if [[ -n "$raw_data" && "$raw_data" == *"concurso"* ]]; then
        echo "$raw_data" > "$CACHE_FILE"
    elif [[ -f "$CACHE_FILE" ]]; then
        raw_data=$(cat "$CACHE_FILE")
    else
        log_error "Falha de rede e Cache Local inexistente."
        exit 1
    fi

    local total_api=$(echo "$raw_data" | jq length)
    local idx_antigo=$((ANALISE - 1))
    (( idx_antigo >= total_api )) && idx_antigo=$((total_api - 1))
    
    local concurso_atual=$(echo "$raw_data" | jq -r ".[0].concurso")
    local data_sorteio=$(echo "$raw_data" | jq -r ".[0].data")
    
    mapfile -t RESULTADO_OFICIAL < <(echo "$raw_data" | jq -r ".[0].dezenas | sort | .[]")
    mapfile -t HISTORICO_CORTE < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | sort | join(\" \")")

    log_info "Base Sincronizada: Concurso $concurso_atual ($data_sorteio)"
    log_info "Último Sorteio: ${RESULTADO_OFICIAL[*]}"
    log_info "Indexando Hash Map de Integridade Estrita em RAM..."

    mapfile -t historico_completo < <(echo "$raw_data" | jq -r '.[].dezenas | sort | join(" ")')
    
    for sorteio in "${historico_completo[@]}"; do
        map_exclusividade["$sorteio"]=1
    done

    mapfile -t todas_dezenas < <(echo "$raw_data" | jq -r ".[0:$ANALISE] | .[].dezenas | .[]")
    local frequencia=$(printf "%s\n" "${todas_dezenas[@]}" | sort | uniq -c | sort -nr)
    
    WEIGHTED_POOL=""
    while read -r count num; do
        for ((i=0; i<count; i++)); do WEIGHTED_POOL+="$num "; done
    done <<< "$frequencia"
    
    for d in "${RESULTADO_OFICIAL[@]}"; do
        for i in {1..5}; do WEIGHTED_POOL+="$d "; done
    done
    
    POOL_ARRAY=($WEIGHTED_POOL)
}

# ==============================================================================
# MOTOR ESTOCÁSTICO PRINCIPAL
# ==============================================================================
generate_engine() {
    local pool_size=${#POOL_ARRAY[@]}
    local count_jogos=0
    local tentativas=0 
    
    local min_media_clean="${MIN_MEDIA//,/.}"
    local min_media_int=$(awk -v m="$min_media_clean" 'BEGIN { printf "%.0f", m * 100 }')

    local status_exc="Exclusividade Histórica"
    [[ $ALLOW_REPEATED -eq 1 ]] && status_exc="Permite Repetidos"
    
    local status_m9="Dinâmico 4-6"
    [[ -n "$MAGIC_9_MODE" ]] && status_m9="$MAGIC_9_MODE"
    
    log_info "Filtros ativos: Extremidades | $status_exc | Padrão 9 ($status_m9 dezenas) | Primos (5-7) | Paridade (7-9 ímpares)."
    log_info "Perfil Operacional carregado: ${MODO_PERFIL^^} (Análise: $ANALISE concursos)."
    log_info "Iniciando processamento estocástico guiado..."

    if [[ $EXPORTAR -eq 1 ]]; then
        mkdir -p "$(dirname "$ARQUIVO_CSV")"
        echo "ID_JOGO,D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,MEDIA_HIST,REPETIDAS,IMPARES,PRIMOS,M9" > "$ARQUIVO_CSV"
    fi

    while [ $count_jogos -lt $QTD_JOGOS ]; do
        
        ((tentativas++))
        if (( tentativas > MAX_RETRY )); then
            log_error "Paradoxo Lógico - Filtros excessivamente restritivos esgotaram $MAX_RETRY buscas."
            exit 1
        fi
        
        local -a candidate=()
        local -A candidate_map=()
        
        while ((${#candidate[@]} < DEZENAS_CARTAO)); do
            local idx=$((SRANDOM % pool_size))
            local num=${POOL_ARRAY[$idx]}
            if [[ -z "${candidate_map[$num]:-}" ]]; then
                candidate_map[$num]=1
                candidate+=("$num")
            fi
        done
        
        sort_numeric_array candidate
        
        if (( 10#${candidate[0]} > 4 || 10#${candidate[DEZENAS_CARTAO-1]} < 22 )); then 
            continue
        fi
        
        local impares=0 primos=0 m9_count=0 acertos_ult=0
        
        for n in "${candidate[@]}"; do
            (( 10#$n % 2 != 0 )) && ((impares++))
            [[ "$PRIMES_STR" =~ " $n " ]] && ((primos++))
            [[ "$MAGIC_9_STR" =~ " $n " ]] && ((m9_count++))
            [[ " ${RESULTADO_OFICIAL[*]} " =~ " $n " ]] && ((acertos_ult++))
        done
        
        if [[ $impares -lt 7 || $impares -gt 9 ]]; then continue; fi
        if [[ $primos -lt 5 || $primos -gt 7 ]]; then continue; fi
        if [[ -n "$MAGIC_9_MODE" ]]; then
            if [[ $m9_count -ne $MAGIC_9_MODE ]]; then continue; fi
        else
            if [[ $m9_count -lt 4 || $m9_count -gt 6 ]]; then continue; fi
        fi
        if [[ "$acertos_ult" -lt "$MIN_REP" || "$acertos_ult" -gt "$MAX_REP" ]]; then continue; fi
        
        local jogo_formatado="${candidate[*]}"

        if [[ $ALLOW_REPEATED -eq 0 && -n "${map_exclusividade["$jogo_formatado"]:-}" ]]; then
            continue
        fi

        if [[ -z "${jogos_gerados_sessao["$jogo_formatado"]:-}" ]]; then
            local soma_acertos=0
            for dez_concurso in "${HISTORICO_CORTE[@]}"; do
                local acertos_n=0
                for n in "${candidate[@]}"; do
                    [[ " $dez_concurso " =~ " $n " ]] && ((acertos_n++))
                done
                (( soma_acertos += acertos_n ))
            done

            local media_historica_int=$(( (soma_acertos * 100) / ANALISE ))

            if (( media_historica_int >= min_media_int )); then
                jogos_gerados_sessao["$jogo_formatado"]=1
                ((count_jogos++))

                local media_historica_display=$(printf "%.2f" "$((media_historica_int))e-2")
                local media_formatada="${media_historica_display/./,}"
                local pares=$(( 15 - impares ))
                
                # Salvamento de Dados Brutos Isolado (CSV Background)
                if [[ $EXPORTAR -eq 1 ]]; then
                    local dezenas_csv=$(echo "$jogo_formatado" | tr ' ' ',')
                    local linha_csv="$count_jogos,$dezenas_csv,$media_historica_display,$acertos_ult,$impares,$primos,$m9_count"
                    echo "$linha_csv" >> "$ARQUIVO_CSV"
                fi

                # ==============================================================
                # STDOUT: SAÍDA PRINCIPAL (Matriz de Auditoria)
                # Smart Routing: Envia limpo para arquivos ou colorido no terminal
                # ==============================================================
                if [[ ! -t 1 ]]; then
                    # Sem ANSI (para arquivos de log limpos ex: > auditoria.txt)
                    printf "[JOGO %02d] → %s | Méd: %s | P: %d | I/P: %d/%d | M9: %d | R: %d\n" \
                        "$count_jogos" "$jogo_formatado" "$media_formatada" "$primos" "$impares" "$pares" "$m9_count" "$acertos_ult"
                else
                    # Com ANSI (para leitura visual destacada no Terminal)
                    printf "\033[1;32m[JOGO %02d]\033[0m → %s | \033[1mMéd:\033[0m %s | \033[1mP:\033[0m %d | \033[1mI/P:\033[0m %d/%d | \033[1mM9:\033[0m %d | \033[1mR:\033[0m %d\n" \
                        "$count_jogos" "$jogo_formatado" "$media_formatada" "$primos" "$impares" "$pares" "$m9_count" "$acertos_ult"
                fi
            fi
        fi
    done

    # ==============================================================================
    # MÉTRICAS FINAIS DE SUCESSO E PERFORMANCE (Via STDERR)
    # ==============================================================================
    log_success "Motor exigiu $tentativas micro-ciclos de força bruta guiada." >&2
    log_success "Processamento estocástico concluído: $QTD_JOGOS jogos gerados."
}

# ==============================================================================
# FLUXO DE EXECUÇÃO
# ==============================================================================
parse_arguments "$@"
validate_inputs
bootstrap_data
generate_engine
