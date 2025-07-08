# ==================================================================
#        ARQUIVO DE VARIÁVEIS DE CORES E ESTILOS (TRUE COLOR)
# ==================================================================
#
# Este arquivo é para terminais modernos que suportam cores de 24 bits
# (True Color), como Kitty, WezTerm, iTerm2, Windows Terminal, e versões
# recentes do GNOME Terminal, Konsole, etc.
#
# A sintaxe para True Color é:
# - Cor do Texto: \e[38;2;<R>;<G>;<B>m
# - Cor do Fundo: \e[48;2;<R>;<G>;<B>m
# Onde R, G, e B são valores de 0 a 255.
#
# COMO USAR:
# 1. Salve este arquivo (ex: ~/.true_colors.sh).
# 2. Adicione 'source ~/.true_colors.sh' ao seu ~/.bashrc.
# 3. Use as variáveis ou as funções dinâmicas em seus scripts.
#

# --- CÓDIGO DE RESET ---
# Reseta todas as cores e estilos para o padrão do terminal.

RESET='\e[0m'

# --- ESTILOS DE TEXTO (Idênticos ao padrão) ---
BOLD='\e[1m'
DIM='\e[2m'
ITALIC='\e[3m'
UNDERLINE='\e[4m'
BLINK='\e[5m'
INVERT='\e[7m'
HIDDEN='\e[8m'


# ==================================================================
#                  FUNÇÕES DINÂMICAS PARA TRUE COLOR
# ==================================================================
# Estas funções permitem gerar qualquer cor dinamicamente usando valores RGB.

# Define a cor do texto (foreground)
# Uso: $(fg_rgb <r> <g> <b>)
# Ex: echo -e "$(fg_rgb 255 99 71)Texto cor de tomate${RESET}"
fg_rgb() {
    echo -e "\e[38;2;$1;$2;$3m"
}

# Define a cor do fundo (background)
# Uso: $(bg_rgb <r> <g> <b>)
# Ex: echo -e "$(bg_rgb 66 133 244) Fundo azul Google ${RESET}"
bg_rgb() {
    echo -e "\e[48;2;$1;$2;$3m"
}


# ==================================================================
#           PALETA CURADA DE CORES PRÉ-DEFINIDAS (TRUE COLOR)
# ==================================================================
# Uma seleção de cores úteis e agradáveis para uso rápido.

# --- Tons de Vermelho / Rosa ---
TOMATO='\e[38;2;255;99;71m'
FIREBRICK='\e[38;2;178;34;34m'
DEEP_PINK='\e[38;2;255;20;147m'

# --- Tons de Laranja / Amarelo ---
ORANGE_WEB='\e[38;2;255;165;0m'
GOLD='\e[38;2;255;215;0m'
KHAKI='\e[38;2;240;230;140m'

# --- Tons de Verde ---
FOREST_GREEN='\e[38;2;34;139;34m'
SPRING_GREEN='\e[38;2;0;255;127m'
OLIVE='\e[38;2;128;128;0m'

# --- Tons de Azul ---
GOOGLE_BLUE='\e[38;2;66;133;244m'
DEEP_SKY_BLUE='\e[38;2;0;191;255m'
ROYAL_BLUE='\e[38;2;65;105;225m'

# --- Tons de Roxo / Violeta ---
SLATE_BLUE='\e[38;2;106;90;205m'
INDIGO='\e[38;2;75;0;130m'
PURPLE_HEART='\e[38;2;102;51;153m' # Roxo Twitch

# --- Tons de Cinza e Neutros ---
DIM_GRAY='\e[38;2;105;105;105m'
LIGHT_GRAY='\e[38;2;211;211;211m'
WHEAT='\e[38;2;245;222;179m'

# --- Cores de Fundo (BG) correspondentes ---
BG_GOOGLE_BLUE='\e[48;2;66;133;244m'
BG_DIM_GRAY='\e[48;2;105;105;105m'
BG_FIREBRICK='\e[48;2;178;34;34m'


# --- FUNÇÃO DE TESTE ---
# Execute 'test_true_colors' no seu terminal para ver uma demonstração.
function test_true_colors() {
    echo -e "${BOLD}--- DEMONSTRAÇÃO DE TRUE COLOR (24-BIT) ---${RESET}"
    echo ""
    echo -e "${UNDERLINE}Uso de variáveis pré-definidas:${RESET}"
    echo -e "  ${TOMATO}■ Tomato${RESET} | ${GOOGLE_BLUE}■ Google Blue${RESET} | ${SPRING_GREEN}■ Spring Green${RESET} | ${PURPLE_HEART}■ Purple Heart${RESET}"
    echo ""
    echo -e "${UNDERLINE}Uso das funções dinâmicas:${RESET}"
    echo -e "  $(fg_rgb 235 52 140)Cor rosa gerada dinamicamente (RGB 235, 52, 140)${RESET}"
    echo -e "  $(fg_rgb 52 235 229)Cor turquesa gerada dinamicamente (RGB 52, 235, 229)${RESET}"
    echo ""
    echo -e "${UNDERLINE}Combinação de Fundo, Texto e Estilo:${RESET}"
    echo -e "  ${BG_DIM_GRAY}${BOLD}${WHEAT} Texto 'Wheat' em negrito sobre fundo 'Dim Gray' ${RESET}"
    echo -e "  ${BOLD}$(fg_rgb 255 255 255)$(bg_rgb 0 100 0) Texto branco e negrito sobre fundo verde escuro dinâmico ${RESET}"
    echo ""
    echo -e "${UNDERLINE}Exemplo de Gradiente (demonstra o poder do True Color):${RESET}"
    echo -n "  "
    for i in {0..150..4}; do
        # Cria um gradiente de Roxo para Laranja
        echo -n -e "$(bg_rgb $((200-i)) 50 $((100+i))) ${RESET}"
    done
    echo ""
    echo -e "${BOLD}--- FIM DA DEMONSTRAÇÃO ---${RESET}"
}