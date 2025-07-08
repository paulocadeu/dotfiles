#!/bin/bash

# ============================================================================= #
#                           CUSTOM BASH PROMPT GUIDE                           #
# ============================================================================= #

# Este arquivo explica o prompt customizado usado no bashrc.sh
# Não execute este arquivo - ele é apenas documentação e exemplos

# ========================== ANÁLISE DO PROMPT ATUAL ========================= #

# O prompt atual é composto por várias partes:
# 1. Função para detectar branch do Git
# 2. Sistema de limpeza de prompt avançado
# 3. Configuração visual com cores
# 4. Layout em duas linhas

# ========================== FUNÇÃO GIT BRANCH =============================== #

# Função original do bashrc.sh:
parse_git_branch() {
  # Verifica se o comando git existe antes de tudo
  command -v git >/dev/null 2>&1 || return

  # Se estiver em um repositório git, mostra o branch. Caso contrário, não mostra nada.
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo "branch:$(git symbolic-ref --short HEAD)"
}

# Versão melhorada com mais informações:
parse_git_branch_enhanced() {
  # Verifica se git está disponível
  command -v git >/dev/null 2>&1 || return

  # Verifica se está em um repositório git
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  local status=""

  # Verifica se há mudanças não commitadas
  if ! git diff --quiet 2>/dev/null; then
    status="${status}*"
  fi

  # Verifica se há arquivos não rastreados
  if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
    status="${status}+"
  fi

  # Verifica se há commits para push
  local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
  if [ -n "$ahead" ] && [ "$ahead" -gt 0 ]; then
    status="${status}↑$ahead"
  fi

  # Verifica se há commits para pull
  local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)
  if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
    status="${status}↓$behind"
  fi

  echo "branch:${branch}${status}"
}

# ========================== SISTEMA DE CORES ================================ #

# Códigos de cores usados no prompt atual:
# \e[38;5;153m  - Azul claro (usuário)
# \e[38;5;150m  - Verde claro (host)
# \e[38;5;214m  - Laranja (diretório)
# \e[38;5;39m   - Azul (símbolo $)
# \033[0;91m    - Vermelho claro (git branch)
# \e[m          - Reset de cor

# Paleta de cores disponíveis (256 cores):
show_color_palette() {
    echo "Paleta de cores 256:"
    for i in {0..255}; do
        printf "\e[38;5;${i}m%3d\e[0m " "$i"
        if (( i % 16 == 15 )); then
            echo
        fi
    done
    echo
}

# ========================== COMPONENTES DO PROMPT =========================== #

# Prompt atual decomposto:
# PS1="\[\e[38;5;153m\]\u\[\e[m\] at \[\e[38;5;150m\]\h\[\e[m\] in \[\e[38;5;214m\]\w\[\e[m\] $GIT_PROMPT\n\[\e[38;5;39m\]\$ \[\e[m\]"

# Componentes:
# \u = usuário
# \h = hostname
# \w = diretório atual (caminho completo)
# \W = diretório atual (apenas nome)
# \$ = $ para usuário normal, # para root
# \n = nova linha

# ========================== VARIAÇÕES DE PROMPT ========================== #

# Prompt simples colorido:
SIMPLE_PROMPT="\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "

# Prompt com timestamp:
TIME_PROMPT="\[\e[90m\][\t]\[\e[0m\] \[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "

# Prompt minimalista:
MINIMAL_PROMPT="\[\e[36m\]\W\[\e[0m\] \$ "

# Prompt com status do último comando:
STATUS_PROMPT='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]$([ $? = 0 ] && echo "\[\e[32m\] ✓" || echo "\[\e[31m\] ✗")\[\e[0m\]\$ '

# Prompt estilo powerline (requer fonte com símbolos):
POWERLINE_PROMPT="\[\e[48;5;240m\]\[\e[38;5;250m\] \u \[\e[48;5;236m\]\[\e[38;5;240m\]\[\e[38;5;250m\] \h \[\e[48;5;234m\]\[\e[38;5;236m\]\[\e[38;5;250m\] \w \[\e[0m\]\[\e[38;5;234m\]\[\e[0m\] "

# ========================== SISTEMA DE LIMPEZA AVANÇADO ================== #

# O bashrc.sh usa um sistema sofisticado para limpar o prompt:

# Função que captura o último comando:
function lastcommand {
    history | tail -1 | cut -c 8-
}

# Função que deleta o prompt anterior:
function deleteprompt {
    n=${PS1@P}                    # Expande o PS1
    n=${n//[^$'\n']}             # Conta quebras de linha
    n=${#n}                      # Número de linhas
    tput cuu $((n + 1))          # Move cursor para cima
    tput ed                      # Limpa da posição atual até o fim
}

# PS0 é executado antes de cada comando:
PS0='\[$(deleteprompt)\]\$ $(lastcommand)\n\[${PS1:0:$((EXPS0=1,0))}\]'

# PROMPT_COMMAND é executado após cada comando:
PROMPT_COMMAND='[ "$EXPS0" = 0 ] && deleteprompt && echo -e "\$" || EXPS0=0'

# ========================== FUNÇÕES UTILITÁRIAS ========================== #

# Aplicar um prompt específico:
apply_prompt() {
    local prompt_name="$1"
    case "$prompt_name" in
        "simple")
            PS1="$SIMPLE_PROMPT"
            ;;
        "time")
            PS1="$TIME_PROMPT"
            ;;
        "minimal")
            PS1="$MINIMAL_PROMPT"
            ;;
        "status")
            PS1="$STATUS_PROMPT"
            ;;
        "powerline")
            PS1="$POWERLINE_PROMPT"
            ;;
        "original")
            # Restaura o prompt original do bashrc.sh
            GIT_PROMPT="\033[0;91m\$(parse_git_branch)\[\e[m\]"
            PS1="\[\e[38;5;153m\]\u\[\e[m\] at \[\e[38;5;150m\]\h\[\e[m\] in \[\e[38;5;214m\]\w\[\e[m\] $GIT_PROMPT\n\[\e[38;5;39m\]\$ \[\e[m\]"
            ;;
        *)
            echo "Prompts disponíveis: simple, time, minimal, status, powerline, original"
            return 1
            ;;
    esac
    echo "Prompt '$prompt_name' aplicado!"
}

# Testar cores:
test_colors() {
    echo -e "\e[31mVermelho\e[0m"
    echo -e "\e[32mVerde\e[0m"
    echo -e "\e[33mAmarelo\e[0m"
    echo -e "\e[34mAzul\e[0m"
    echo -e "\e[35mMagenta\e[0m"
    echo -e "\e[36mCiano\e[0m"
    echo -e "\e[37mBranco\e[0m"
    echo -e "\e[90mCinza\e[0m"
}

# Mostrar informações do prompt atual:
prompt_info() {
    echo "=== INFORMAÇÕES DO PROMPT ATUAL ==="
    echo "PS1: $PS1"
    echo "PS0: $PS0"
    echo "PROMPT_COMMAND: $PROMPT_COMMAND"
    echo
    echo "=== VARIÁVEIS DE AMBIENTE ==="
    echo "USER: $USER"
    echo "HOSTNAME: $HOSTNAME"
    echo "PWD: $PWD"
    echo "HOME: $HOME"
}

# ========================== EXEMPLOS DE USO ============================== #

# Para usar este arquivo:
# 1. source ./scripts/prompt.sh
# 2. apply_prompt simple
# 3. test_colors
# 4. show_color_palette
# 5. prompt_info

# ========================== DOCUMENTAÇÃO ADICIONAL ======================= #

# Escape sequences importantes:
# \[ e \] - Delimitam sequências não-imprimíveis (cores)
# \e ou \033 - Início de sequência de escape
# \e[0m - Reset de formatação
# \e[1m - Negrito
# \e[4m - Sublinhado
# \e[7m - Inverso

# Códigos de cor básicos:
# 30-37: Cores de texto (preto, vermelho, verde, amarelo, azul, magenta, ciano, branco)
# 40-47: Cores de fundo
# 90-97: Cores de texto brilhantes
# 100-107: Cores de fundo brilhantes

# Para cores 256: \e[38;5;NUMm (texto) ou \e[48;5;NUMm (fundo)
# Para cores RGB: \e[38;2;R;G;Bm (texto) ou \e[48;2;R;G;Bm (fundo)

# echo "Arquivo de documentação do prompt customizado carregado!"
# echo "Use 'apply_prompt <nome>' para testar diferentes prompts"
# echo "Prompts disponíveis: simple, time, minimal, status, powerline, original"
