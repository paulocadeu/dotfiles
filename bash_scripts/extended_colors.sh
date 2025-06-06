# ==================================================================
#          ARQUIVO DE VARIÁVEIS DE CORES E ESTILOS (256 CORES)
# ==================================================================
#
# Este arquivo define variáveis para uso em scripts Bash, facilitando a
# colorização e formatação da saída de texto em terminais que suportam
# 256 cores (8-bit).
#
# COMO USAR:
# 1. Salve este arquivo em seu diretório home (ex: ~/.colors.sh).
# 2. Adicione a linha 'source ~/.colors.sh' ao final do seu ~/.bashrc
#    ou ~/.bash_profile.
# 3. Abra um novo terminal ou execute 'source ~/.bashrc'.
# 4. Use as variáveis em seus scripts. Exemplo:
#    echo -e "${BOLD_GREEN}Operação concluída com sucesso!${RESET}"
#
# NOTA SOBRE O PS1 (PROMPT):
# Para usar estas cores no seu prompt (variável PS1), você precisa
# envolvê-las com '\[...\]' para que o Bash calcule o tamanho da
# linha corretamente. Ex: PS1_GREEN="\[$GREEN\]"
#

# --- CÓDIGO DE RESET ---
# Reseta todas as cores e estilos para o padrão do terminal. Essencial!
RESET='\e[0m'

# --- ESTILOS DE TEXTO ---
BOLD='\e[1m'
DIM='\e[2m'
ITALIC='\e[3m'
UNDERLINE='\e[4m'
BLINK='\e[5m'
INVERT='\e[7m'
HIDDEN='\e[8m'

# --- CORES DE TEXTO (FG) - PALETA BÁSICA (3/4-BIT) ---
BLACK='\e[30m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'

# --- CORES DE TEXTO (FG) - ALTA INTENSIDADE (BRIGHT) ---
BRIGHT_BLACK='\e[90m'
BRIGHT_RED='\e[91m'
BRIGHT_GREEN='\e[92m'
BRIGHT_YELLOW='\e[93m'
BRIGHT_BLUE='\e[94m'
BRIGHT_MAGENTA='\e[95m'
BRIGHT_CYAN='\e[96m'
BRIGHT_WHITE='\e[97m'

# --- CORES DE FUNDO (BG) - PALETA BÁSICA ---
BG_BLACK='\e[40m'
BG_RED='\e[41m'
BG_GREEN='\e[42m'
BG_YELLOW='\e[43m'
BG_BLUE='\e[44m'
BG_MAGENTA='\e[45m'
BG_CYAN='\e[46m'
BG_WHITE='\e[47m'

# --- CORES DE FUNDO (BG) - ALTA INTENSIDADE ---
BG_BRIGHT_BLACK='\e[100m'
BG_BRIGHT_RED='\e[101m'
BG_BRIGHT_GREEN='\e[102m'
BG_BRIGHT_YELLOW='\e[103m'
BG_BRIGHT_BLUE='\e[104m'
BG_BRIGHT_MAGENTA='\e[105m'
BG_BRIGHT_CYAN='\e[106m'
BG_BRIGHT_WHITE='\e[107m'


# ==================================================================
#               PALETA DE 256 CORES (8-BIT)
# Sintaxe: \e[38;5;<code>m (texto) | \e[48;5;<code>m (fundo)
# ==================================================================

# --- CORES DE TEXTO (FG) - SELEÇÃO DA PALETA DE 256 CORES ---
ORANGE='\e[38;5;208m'
LIME_GREEN='\e[38;5;154m'
SKY_BLUE='\e[38;5;39m'
HOT_PINK='\e[38;5;198m'
VIOLET='\e[38;5;99m'
TEAL='\e[38;5;30m'
GOLD='\e[38;5;214m'
CORAL='\e[38;5;203m'

# --- CORES DE FUNDO (BG) - SELEÇÃO DA PALETA DE 256 CORES ---
BG_ORANGE='\e[48;5;208m'
BG_LIME_GREEN='\e[48;5;154m'
BG_SKY_BLUE='\e[48;5;39m'
BG_HOT_PINK='\e[48;5;198m'

# --- ESCALA DE CINZA (PALETA DE 256 CORES) ---
# Texto
GRAY_01='\e[38;5;232m' # O mais escuro
GRAY_02='\e[38;5;233m'
GRAY_03='\e[38;5;234m'
GRAY_04='\e[38;5;235m'
GRAY_05='\e[38;5;236m'
GRAY_06='\e[38;5;237m'
GRAY_07='\e[38;5;238m'
GRAY_08='\e[38;5;239m'
GRAY_09='\e[38;5;240m'
GRAY_10='\e[38;5;241m'
GRAY_11='\e[38;5;242m'
GRAY_12='\e[38;5;243m'
GRAY_13='\e[38;5;244m'
GRAY_14='\e[38;5;245m'
GRAY_15='\e[38;5;246m'
GRAY_16='\e[38;5;247m'
GRAY_17='\e[38;5;248m'
GRAY_18='\e[38;5;249m'
GRAY_19='\e[38;5;250m'
GRAY_20='\e[38;5;251m'
GRAY_21='\e[38;5;252m'
GRAY_22='\e[38;5;253m'
GRAY_23='\e[38;5;254m'
GRAY_24='\e[38;5;255m' # O mais claro

# Fundo
BG_GRAY_01='\e[48;5;232m'
BG_GRAY_05='\e[48;5;236m'
BG_GRAY_10='\e[48;5;241m'
BG_GRAY_15='\e[48;5;246m'
BG_GRAY_20='\e[48;5;251m'


# --- COMBINAÇÕES DE ESTILO E COR (EXEMPLOS) ---
# Útil para criar alertas padronizados
BOLD_RED="${BOLD}${RED}"
BOLD_GREEN="${BOLD}${GREEN}"
BOLD_YELLOW="${BOLD}${YELLOW}"
BOLD_BLUE="${BOLD}${BLUE}"
UNDERLINE_WHITE="${UNDERLINE}${WHITE}"

# --- FUNÇÃO DE TESTE ---
# Execute 'test_colors' no seu terminal para ver uma demonstração das cores.
function test_colors() {
  echo -e "${BOLD}--- DEMONSTRAÇÃO DE CORES E ESTILOS ---${RESET}"
  echo ""
  echo -e "${BOLD}Estilos:${RESET}"
  echo -e "  ${BOLD}Texto em Negrito${RESET}"
  echo -e "  ${ITALIC}Texto em Itálico${RESET}"
  echo -e "  ${UNDERLINE}Texto Sublinhado${RESET}"
  echo ""
  echo -e "${BOLD}Cores Básicas:${RESET}"
  echo -e "  ${RED}Vermelho${RESET} | ${GREEN}Verde${RESET} | ${YELLOW}Amarelo${RESET} | ${BLUE}Azul${RESET}"
  echo ""
  echo -e "${BOLD}Cores de Alta Intensidade:${RESET}"
  echo -e "  ${BRIGHT_RED}Vermelho Brilhante${RESET} | ${BRIGHT_GREEN}Verde Brilhante${RESET} | ${BRIGHT_CYAN}Ciano Brilhante${RESET}"
  echo ""
  echo -e "${BOLD}Cores da Paleta de 256:${RESET}"
  echo -e "  ${ORANGE}Laranja${RESET} | ${LIME_GREEN}Verde Limão${RESET} | ${SKY_BLUE}Azul Céu${RESET} | ${HOT_PINK}Rosa Choque${RESET}"
  echo ""
  echo -e "${BOLD}Fundos Coloridos:${RESET}"
  echo -e "  ${BG_RED}${WHITE} Fundo Vermelho ${RESET} | ${BG_GRAY_05}${BRIGHT_WHITE} Fundo Cinza Escuro ${RESET}"
  echo ""
  echo -e "${BOLD}Combinações:${RESET}"
  echo -e "  ${BOLD_GREEN}SUCESSO:${RESET} A tarefa foi concluída."
  echo -e "  ${BOLD_YELLOW}AVISO:${RESET}   O espaço em disco está baixo."
  echo -e "  ${BOLD_RED}ERRO:${RESET}    Falha ao conectar no servidor."
  echo ""
  echo -e "${BOLD}Escala de Cinza:${RESET}"
  echo -e "  ${GRAY_01}■${GRAY_04}■${GRAY_08}■${GRAY_12}■${GRAY_16}■${GRAY_20}■${GRAY_24}■${RESET}"
  echo -e "${BOLD}--- FIM DA DEMONSTRAÇÃO ---${RESET}"
}