#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

install_dotfiles() {
    echo "#####################################"
    echo "# Installing dotfiles using Stow... #"
    echo "#####################################"
    cd "$DOTFILES_DIR"
    stow .

    if ! fc-list | grep -q -i "JetBrainsMono"; then
        # Refresh font cache
        fc-cache -fv
        rm -f ".local/share/fonts/JetBrainsMono.zip"
    fi

    if ! command -v nvim &> /dev/null; then
        rm nvim-linux64.tar.gz
    fi
}

install_dependencies() {
    echo "##############################"
    echo "# Installing dependencies... #"
    echo "##############################"

    sudo apt-get update
    sudo apt-get install -y stow zsh vim git jq unzip fontconfig

    check_and_install_neovim
    install_fzf
    install_nerd_font
    install_zoxide
}

check_and_install_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo "#################################################"
        echo "# Neovim is not installed. Installing Neovim... #"
        echo "#################################################"

        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux64.tar.gz
    else
        echo "###############################"
        echo "# Neovim is already installed #"
        echo "###############################"
    fi
}

install_nerd_font() {
    if fc-list | grep -q -i "JetBrainsMono"; then
        echo "#######################################"
        echo "# JetBrainsMono is already installed. #"
        echo "#######################################"
    else
        echo "#################################"
        echo "# Installing JetBrainsMono font #"
        echo "#################################"
        cd "$DOTFILES_DIR"/.local/share/fonts
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
        unzip JetBrainsMono.zip
    fi
}

install_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo "###########################################"
        echo "# fzf is not installed. Installing fzf... #"
        echo "###########################################"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
	rm ~/.zshrc
    else
        echo "############################"
        echo "# fzf is already installed #"
        echo "############################"
    fi
}

install_zoxide() {
    if ! command -v zoxide &> /dev/null; then
        echo "###########################################"
        echo "# zoxide is not installed. Installing...  #"
        echo "###########################################"

        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    else
        echo "###############################"
        echo "# zoxide is already installed #"
        echo "###############################"
    fi
}

main() {
    install_dependencies
    install_dotfiles

    echo "######################"
    echo "# dotfiles complete! #"
    echo "######################"
}

main
