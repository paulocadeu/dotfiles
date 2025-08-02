/home/paulocadeu/.config/hypr
/home/paulocadeu/.config/kitty
/home/paulocadeu/.config/waybar
rm -rf ${HOME}/.config/hypr && ln -s ${HOME}/dotfiles/config/jakoolit/hypr/ ${HOME}/.config
rm -f ${HOME}/.config/hypr && ln -s ${HOME}/dotfiles/config/jakoolit-fedora-hyprland/hypr ${HOME}/.config
rm -rf ${HOME}/.config/kitty && ln -s ${HOME}/dotfiles/config/jakoolit-fedora-hyprland/kitty ${HOME}/.config
