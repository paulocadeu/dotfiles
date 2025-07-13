#!/usr/bin/env bash
# AppImage Installer Script
# Instala um AppImage extraindo-o para ~/.appImages/nome-app/Nome-versao
# e configura corretamente o arquivo .desktop com o ícone de melhor resolução

set -euo pipefail

# Diretórios principais
APP_BASE_DIR="$HOME/.appImages"
DESKTOP_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons/hicolor"

# Função para exibir mensagem de erro e sair
erro() {
  echo -e "\e[31mERRO:\e[0m $1" >&2
  exit 1
}

# Função para exibir mensagem de uso
mostrar_uso() {
  echo "Uso: $0 caminho/para/arquivo.AppImage"
  echo "Exemplo: $0 ./Aplicativo-1.2.3.AppImage"
  exit 1
}

# Função para exibir mensagem de informação
info() {
  echo -e "\e[94m→\e[0m $1"
}

# Função para exibir sucesso
sucesso() {
  echo -e "\e[32m✓\e[0m $1"
}

# Função para atualizar um campo no arquivo .desktop de forma segura
atualizar_campo_desktop() {
  local arquivo="$1"
  local campo="$2"
  local valor="$3"

  # Escapar caracteres especiais em regex
  local valor_escapado="${valor//\//\\/}"

  # Verificar se o campo existe
  if grep -q "^$campo=" "$arquivo"; then
    # Usar perl em vez de sed para maior compatibilidade
    perl -i -pe "s|^$campo=.*|$campo=$valor_escapado|" "$arquivo"
  else
    # Adicionar campo se não existir
    echo "$campo=$valor" >> "$arquivo"
  fi
}

# Função para extrair nome simplificado do AppImage
extrair_nome_base() {
  local nome="$1"
  # Remove extensão e simplifica o nome (remove versões)
  echo "$nome" | sed -E 's/\.appimage$//i' | sed -E 's/-[0-9]+(\.[0-9]+)*(-arm64|-x86_64|-amd64)?$//i'
}

# Função para solicitar confirmação
confirmar() {
  read -r -p "$1 [s/N] " resposta
  [[ "${resposta,,}" == "s" ]]
}
encontrar_melhor_icone() {
  local dir_base="$1"
  local dpi

  # Tenta obter o DPI atual da tela
  if command -v xdpyinfo >/dev/null 2>&1; then
    dpi=$(xdpyinfo | grep -oP 'resolution:\s+\K\d+' | head -1)
  else
    dpi=96
  fi

  >&2 echo -e "\e[94m→\e[0m DPI detectado: $dpi"

  local resolucoes=(16 22 24 32 48 64 96 128 256 512 1024)

  # 1. Ícones na raiz
  >&2 echo -e "\e[94m→\e[0m Procurando ícones na raiz do diretório..."

  local icone_svg=$(find "$dir_base" -maxdepth 1 -type f -name "*.svg" | head -n1)
  if [[ -n "$icone_svg" ]]; then
    >&2 echo -e "\e[94m→\e[0m Encontrado ícone SVG na raiz: $(basename "$icone_svg")"
    echo "$icone_svg"
    return 0
  fi

  local icone_png=$(find "$dir_base" -maxdepth 1 -type f \( -name "*.png" -o -name "*.ico" \) | head -n1)
  if [[ -n "$icone_png" ]]; then
    >&2 echo -e "\e[94m→\e[0m Encontrado ícone PNG/ICO na raiz: $(basename "$icone_png")"
    echo "$icone_png"
    return 0
  fi

  # 2. Estrutura hicolor
  local hicolor_dir="$dir_base/usr/share/icons/hicolor"
  if [[ -d "$hicolor_dir" ]]; then
    >&2 echo -e "\e[94m→\e[0m Procurando ícones em estrutura hicolor..."

    local icone_svg_hicolor=$(find "$hicolor_dir" -name "*.svg" | head -n1)
    if [[ -n "$icone_svg_hicolor" ]]; then
      >&2 echo -e "\e[94m→\e[0m Encontrado ícone SVG em hicolor: $(basename "$icone_svg_hicolor")"
      echo "$icone_svg_hicolor"
      return 0
    fi

    local melhor_resolucao=0
    local melhor_diferenca=1000000
    local melhor_icone=""

    for res in "${resolucoes[@]}"; do
      local res_dir="${res}x${res}"
      if [[ -d "$hicolor_dir/$res_dir" ]]; then
        local diferenca=$(( res > dpi ? res - dpi : dpi - res ))
        if (( diferenca < melhor_diferenca || (diferenca == melhor_diferenca && res > melhor_resolucao) )); then
          local icones_res=$(find "$hicolor_dir/$res_dir" -type f -name "*.png" | head -n1)
          if [[ -n "$icones_res" ]]; then
            melhor_diferenca=$diferenca
            melhor_resolucao=$res
            melhor_icone="$icones_res"
          fi
        fi
      fi
    done

    if [[ -n "$melhor_icone" ]]; then
      >&2 echo -e "\e[94m→\e[0m Selecionado ícone ${melhor_resolucao}x${melhor_resolucao} (diferença DPI: $melhor_diferenca)"
      echo "$melhor_icone"
      return 0
    fi
  fi

  # 3. Outros diretórios comuns
  local diretorios_comuns=(
    "usr/share/icons"
    "usr/share/pixmaps"
    "usr/share/app/icons"
    "resources/icons"
    "resources/app/resources/icons"
    "resources/app/icons"
  )

  for subdir in "${diretorios_comuns[@]}"; do
    local dir_procura="$dir_base/$subdir"
    if [[ -d "$dir_procura" ]]; then
      local icone_encontrado=$(find "$dir_procura" -type f -name "*.svg" | head -n1)
      if [[ -n "$icone_encontrado" ]]; then
        >&2 echo -e "\e[94m→\e[0m Encontrado ícone SVG em $subdir"
        echo "$icone_encontrado"
        return 0
      fi
      icone_encontrado=$(find "$dir_procura" -type f \( -name "*.png" -o -name "*.ico" \) | head -n1)
      if [[ -n "$icone_encontrado" ]]; then
        >&2 echo -e "\e[94m→\e[0m Encontrado ícone PNG/ICO em $subdir"
        echo "$icone_encontrado"
        return 0
      fi
    fi
  done

  # 4. Busca recursiva
  >&2 echo -e "\e[94m→\e[0m Procurando ícones em qualquer lugar do aplicativo..."

  local icone_qualquer=$(find "$dir_base" -type f -name "*.svg" | grep -v "node_modules" | head -n1)
  if [[ -n "$icone_qualquer" ]]; then
    >&2 echo -e "\e[94m→\e[0m Encontrado ícone SVG: $(basename "$icone_qualquer")"
    echo "$icone_qualquer"
    return 0
  fi

  icone_qualquer=$(find "$dir_base" -type f \( -name "*.png" -o -name "*.ico" \) | grep -v "node_modules" | head -n1)
  if [[ -n "$icone_qualquer" ]]; then
    >&2 echo -e "\e[94m→\e[0m Encontrado ícone PNG/ICO: $(basename "$icone_qualquer")"
    echo "$icone_qualquer"
    return 0
  fi

  # Nenhum ícone encontrado
  return 1
}

# Verificar se é root
[[ "$EUID" -eq 0 ]] && erro "Não execute este script como root ou com sudo."

# Verificar argumento
[[ $# -ne 1 ]] && mostrar_uso

APP_PATH="$1"

# Normalizar o caminho
if [[ "${APP_PATH:0:1}" != "/" && "${APP_PATH:0:2}" != "./" && -f "./$APP_PATH" ]]; then
  APP_PATH="./$APP_PATH"
fi

# Verificar se o arquivo existe
[[ ! -f "$APP_PATH" ]] && erro "Arquivo não encontrado: $APP_PATH"

# Verificar se é um AppImage
[[ ! "${APP_PATH,,}" =~ \.appimage$ ]] && erro "O arquivo não parece ser um AppImage válido"

# Tornar executável
chmod +x "$APP_PATH" || erro "Não foi possível tornar o arquivo executável"

# Extrair nomes e diretórios
APP_FILENAME=$(basename -- "$APP_PATH")
APP_NOME_BASE=$(extrair_nome_base "$APP_FILENAME")
APP_NOME_COMPLETO="${APP_FILENAME%.*}"  # Nome com versão, sem extensão

# Criar estrutura de diretórios
TARGET_DIR="$APP_BASE_DIR/$APP_NOME_BASE/$APP_NOME_COMPLETO"

# Verificar se o diretório já existe
if [[ -d "$TARGET_DIR" ]]; then
  info "O diretório $TARGET_DIR já existe"

  if confirmar "Deseja reinstalar o aplicativo (sobrescrever a instalação existente)?"; then
    # Criar um diretório temporário para extração
    TEMP_DIR=$(mktemp -d)

    # Extrair para o diretório temporário
    info "Extraindo para diretório temporário..."
    if ! "$APP_PATH" --appimage-extract >/dev/null 2>&1; then
      rm -rf "$TEMP_DIR" squashfs-root 2>/dev/null
      erro "Falha ao extrair AppImage. Verifique se libfuse está instalada (libfuse.so.2)"
    fi

    # Remover o diretório existente e criar um novo
    rm -rf "$TARGET_DIR"
    mkdir -p "$TARGET_DIR"

    # Mover conteúdo extraído
    mv squashfs-root/* "$TARGET_DIR/" || erro "Falha ao mover arquivos extraídos"
    rm -rf squashfs-root "$TEMP_DIR" 2>/dev/null
  else
    info "Mantendo instalação existente"

    # Limpar squashfs-root se existir (de uma tentativa anterior)
    rm -rf squashfs-root 2>/dev/null

    # Verificamos se o arquivo .desktop existe para continuar a instalação
    DESKTOP_ARQUIVO=$(find "$TARGET_DIR" -maxdepth 2 -name "*.desktop" | head -n1 || true)
    NOME_DISPLAY="$APP_NOME_BASE"
  fi
else
  # Criar o diretório se não existir
  mkdir -p "$TARGET_DIR" || erro "Não foi possível criar o diretório de destino"

  # Extrair AppImage
  info "Extraindo $APP_FILENAME para $TARGET_DIR..."
  if ! "$APP_PATH" --appimage-extract >/dev/null 2>&1; then
    erro "Falha ao extrair AppImage. Verifique se libfuse está instalada (libfuse.so.2)"
  fi

  # Mover conteúdo extraído
  mv squashfs-root/* "$TARGET_DIR/" || erro "Falha ao mover arquivos extraídos"
  rm -rf squashfs-root
fi

# Procurar arquivo .desktop
if [[ ! -v DESKTOP_ARQUIVO ]]; then  # Só procura se ainda não tiver sido definido
  DESKTOP_ARQUIVO=$(find "$TARGET_DIR" -maxdepth 2 -name "*.desktop" | head -n1 || true)
  NOME_DISPLAY="$APP_NOME_BASE"
fi

if [[ -n "$DESKTOP_ARQUIVO" ]]; then
  info "Arquivo .desktop encontrado: $(basename "$DESKTOP_ARQUIVO")"

  # Obter nome do aplicativo do .desktop, se disponível
  if grep -q "^Name=" "$DESKTOP_ARQUIVO"; then
    NOME_DISPLAY=$(grep "^Name=" "$DESKTOP_ARQUIVO" | head -n1 | cut -d'=' -f2-)
    info "Nome do aplicativo: $NOME_DISPLAY"
  fi

  # Criar nova entrada .desktop
  DESKTOP_TARGET="$DESKTOP_DIR/${APP_NOME_BASE}.desktop"
  mkdir -p "$DESKTOP_DIR"

  # Copiar arquivo original para facilitar modificação
  cp "$DESKTOP_ARQUIVO" "$DESKTOP_TARGET"

  # Ajustar caminho do executável
  EXEC_PATH="$TARGET_DIR/AppRun"
  if [[ ! -f "$EXEC_PATH" ]]; then
    # Buscar executável alternativo se AppRun não existir
    EXEC_PATH=$(find "$TARGET_DIR" -type f -executable -not -path "*/\.*" | head -n1)
  fi

  # Garantir que é executável
  chmod +x "$EXEC_PATH"

  # Buscar melhor ícone
  # Criar um descritor de arquivo temporário para capturar a saída
  exec 3>&1
  ICONE_PATH=$(encontrar_melhor_icone "$TARGET_DIR")

  # Se não encontrou ícone
  if [[ -z "$ICONE_PATH" ]]; then
    info "Aviso: Nenhum ícone adequado encontrado"
  fi

  # Atualizar arquivo .desktop
  atualizar_campo_desktop "$DESKTOP_TARGET" "Exec" "$EXEC_PATH"

  if [[ -n "$ICONE_PATH" ]]; then
    atualizar_campo_desktop "$DESKTOP_TARGET" "Icon" "$ICONE_PATH"
    info "Ícone configurado: $ICONE_PATH"
  else
    info "Aviso: Nenhum ícone encontrado"
  fi

else
  # Nenhum arquivo .desktop encontrado, criar um
  info "Nenhum arquivo .desktop encontrado. Criando um novo..."

  if confirmar "Deseja personalizar o nome do aplicativo?"; then
    read -r -p "Digite o nome para o aplicativo: " NOME_CUSTOM
    [[ -n "$NOME_CUSTOM" ]] && NOME_DISPLAY="$NOME_CUSTOM"
  fi

  # Procurar executável
  EXEC_PATH="$TARGET_DIR/AppRun"
  if [[ ! -f "$EXEC_PATH" ]]; then
    EXEC_PATH=$(find "$TARGET_DIR" -type f -executable -not -path "*/\.*" | head -n1)
  fi

  # Garantir que é executável
  chmod +x "$EXEC_PATH"

  # Buscar melhor ícone
  ICONE_PATH=$(encontrar_melhor_icone "$TARGET_DIR")

  # Criar arquivo .desktop
  DESKTOP_TARGET="$DESKTOP_DIR/${APP_NOME_BASE}.desktop"
  mkdir -p "$DESKTOP_DIR"

  cat > "$DESKTOP_TARGET" << EOF
[Desktop Entry]
Type=Application
Name=$NOME_DISPLAY
Exec=$EXEC_PATH
Terminal=false
Categories=Utility;
EOF

  if [[ -n "$ICONE_PATH" ]]; then
    echo "Icon=$ICONE_PATH" >> "$DESKTOP_TARGET"
    info "Ícone configurado: $ICONE_PATH"
  else
    info "Aviso: Nenhum ícone encontrado"
  fi
fi

# Tornar o arquivo .desktop executável
chmod +x "$DESKTOP_TARGET"

# Atualizar cache de aplicativos
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

echo -e "\e[32m✅ Instalação concluída com sucesso!\e[0m"
echo "Aplicativo: $NOME_DISPLAY"
echo "Instalado em: $TARGET_DIR"
echo "Entrada .desktop: $DESKTOP_TARGET"