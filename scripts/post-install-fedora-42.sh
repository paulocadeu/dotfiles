#!/bin/bash
# Script de pós-instalação do Fedora 42
# Autor: Paulo Cadeu

# RPM installs
sudo dnf update -y


## Visual Studio Code
# https://code.visualstudio.com/docs/setup/linux
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

dnf check-update
sudo dnf install code

# Flatpak installs
# https://flatpak.org/setup/Fedora/
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# flatpak install flathub -y com.mattjakeman.ExtensionManager \
# org.telegram.desktop \
# com.brave.Browser \
# com.visualstudio.code \
# com.discordapp.Discord \
# com.valvesoftware.Steam \
# io.github.hrkfdn.ncspot \
# com.google.Chrome


## RPM fusion https://rpmfusion.org/Configuration
# sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# faz parte do instalador do rmp fusion, verificar o que esse comando faz exatamente.
# sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

curl -o /tmp/Hack.zip -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Hack.zip
unzip /tmp/Hack.zip -d ~/.local/share/fonts/
fc-cache -vf ~/.local/share/fonts/

