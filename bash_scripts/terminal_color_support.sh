#!/bin/bash

#
# Função: check_terminal_color_support
#
# Descição:
#   Verifica o nível de suporte a cores do terminal atual e exibe o resultado.
#   A verificação é feita na seguinte ordem:
#   1. True Color (24-bit) - via variável $COLORTERM
#   2. 256 Cores (8-bit)   - via comando 'tput'
#   3. 8/16 Cores (Básico) - via comando 'tput'
#   4. Sem suporte a cores
#
# Uso:
#   Basta chamar a função no seu terminal: check_terminal_color_support
#
function check_terminal_color_support() {
  echo -e "\n🔎  \e[1mVerificando o suporte de cores do seu terminal...\e[0m\n"

  # --- Passo 1: Teste de True Color (24-bit) ---
  # A forma mais confiável é verificar a variável de ambiente $COLORTERM.
  # Terminais modernos a definem como 'truecolor' ou '24bit'.
  if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
    echo -e "✅  \e[1;38;2;66;133;244mNível de Suporte: True Color (24-bit)\e[0m"
    echo -e "   Seu terminal pode exibir mais de 16 milhões de cores."
    echo -e "   Exemplo: \e[48;2;178;34;34m\e[38;2;255;255;255m Texto em True Color \e[0m"
    return 0
  fi

  # --- Passo 2: Teste de 256 Cores (8-bit) ---
  # Se não for True Color, usamos 'tput' para checar o número de cores
  # que o terminal diz suportar.
  if command -v tput &>/dev/null; then
    local ncolors
    ncolors=$(tput colors)

    if [[ -n "$ncolors" && "$ncolors" -ge 256 ]]; then
      echo -e "✅  \e[1;38;5;154mNível de Suporte: 256 Cores (8-bit)\e[0m"
      echo -e "   Seu terminal suporta a paleta de cores estendida."
      echo -e "   Exemplo: \e[48;5;208m\e[38;5;232m Texto em 256 cores \e[0m"
      return 0
    fi

    # --- Passo 3: Teste de 8/16 Cores (Básico) ---
    # Se não suportar 256, verificamos o suporte básico.
    if [[ -n "$ncolors" && "$ncolors" -ge 8 ]]; then
      echo -e "✅  \e[1;92mNível de Suporte: 8/16 Cores (Básico)\e[0m"
      echo -e "   Seu terminal suporta as cores ANSI básicas e de alta intensidade."
      echo -e "   Exemplo: \e[41m\e[97m Texto em 8/16 cores \e[0m"
      return 0
    fi
  fi

  # --- Passo 4: Sem Suporte a Cores ---
  # Se nenhum dos testes acima passar.
  echo -e "❌  \e[1;31mNível de Suporte: Sem Cores\e[0m"
  echo "   Seu terminal não parece suportar cores ou o comando 'tput' não está"
  echo "   disponível ou configurado corretamente (verifique a variável \$TERM)."
  return 1
}

# --- Chamada da função para execução ---
#check_terminal_color_support