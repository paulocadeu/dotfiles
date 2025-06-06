#!/bin/bash

# ==============================================================================
# SCRIPT DE INSTALAÇÃO DE DOTFILES
#
# Este script cria links simbólicos de todos os arquivos e diretórios
# encontrados em '$HOME/dotfiles' para o diretório '$HOME'.
#
# Lógica de Conflito:
# - Se um arquivo/diretório de destino já existir, ele será renomeado com o
#   sufixo '_old'.
# - Se um link já existir e apontar para o lugar correto, nada será feito.
# ==============================================================================

# Encerra o script imediatamente se um comando falhar.
set -e

# --- VARIÁVEIS DE CONFIGURAÇÃO ---
# Diretório onde seus dotfiles estão armazenados.
DOTFILES_DIR="$HOME/dotfiles"
# Diretório de destino para os links (normalmente a home do usuário).
TARGET_DIR="$HOME"
# Sufixo para os arquivos de backup.
BACKUP_SUFFIX="_old"

# --- INÍCIO DO SCRIPT ---
echo -e "\n\e[1;34m🚀 Iniciando a configuração dos dotfiles...\e[0m"
echo -e "Diretório de origem: \e[33m$DOTFILES_DIR\e[0m"
echo -e "Diretório de destino: \e[33m$TARGET_DIR\e[0m\n"

# Garante que o diretório de dotfiles exista.
if [ ! -d "$DOTFILES_DIR" ]; then
  echo -e "\e[1;31mERRO: O diretório de dotfiles '$DOTFILES_DIR' não foi encontrado.\e[0m"
  exit 1
fi

# Navega para o diretório de dotfiles para facilitar o 'find'.
cd "$DOTFILES_DIR"

# Mapeia todos os arquivos e diretórios (exceto o próprio '.')
# O '-mindepth 1' evita que o 'find' retorne o diretório base '.'.
find . -mindepth 1 | while read -r item; do
  # Remove o './' inicial do caminho do item.
  item_path="${item#./}"

  # Define o caminho completo do arquivo de origem e do link de destino.
  source_file="$DOTFILES_DIR/$item_path"
  target_link="$TARGET_DIR/$item_path"

  echo "----------------------------------------------------"
  echo -e "➡️  Processando: \e[36m$item_path\e[0m"

  # --- LÓGICA DE BACKUP E CRIAÇÃO DE LINK ---

  # Verifica se já existe um arquivo, diretório ou link no destino.
  if [ -e "$target_link" ] || [ -L "$target_link" ]; then
    # Verifica se o que existe já é um link apontando para o lugar certo.
    if [ -L "$target_link" ] && [ "$(readlink "$target_link")" == "$source_file" ]; then
      echo -e "✅  Link já existe e está correto. Nenhuma ação necessária."
    else
      # Se não for um link correto, faz o backup.
      backup_path="${target_link}${BACKUP_SUFFIX}"
      echo -e "⚠️  Conflito: '$target_link' já existe."
      echo -e "    Renomeando para \e[32m'$(basename "$backup_path")'\e[0m"
      # Move o arquivo/diretório existente para o novo nome de backup.
      mv "$target_link" "$backup_path"

      # Agora que o caminho está livre, cria o link.
      echo -e "🔗  Criando novo link: \e[32m$target_link\e[0m -> \e[33m$source_file\e[0m"
      ln -s "$source_file" "$target_link"
    fi
  else
    # Se não houver conflito, apenas cria o link.
    # Garante que o diretório pai do link exista antes de criá-lo.
    mkdir -p "$(dirname "$target_link")"

    echo -e "🔗  Criando link: \e[32m$target_link\e[0m -> \e[33m$source_file\e[0m"
    ln -s "$source_file" "$target_link"
  fi
done

echo "----------------------------------------------------"
echo -e "\n\e[1;34m🎉 Configuração concluída com sucesso!\e[0m\n"