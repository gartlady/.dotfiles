#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"
PACKAGES_FILE="$DOTFILES_DIR/packages"

# Color definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Status icons
CHECK="${GREEN}[✓]${RESET}"
CROSS="${RED}[✗]${RESET}"
INFO="${CYAN}[ℹ]${RESET}"

log() { echo -e "${1} ${2}" ${RESET}; }
run_cmd() {
  log "${INFO}" "$1"
  eval "$2" &>/dev/null && log "${CHECK}" "$1 completed" || {
    log "${CROSS}" "$1 failed"
    exit 1
  }
}

install_tool() {
  local name="$1" check_cmd="$2" install_cmd="$3"
  if ! eval "$check_cmd" &>/dev/null; then
    run_cmd "Installing $name" "$install_cmd"
  else
    log "${CHECK}" "$name is already installed"
  fi
}

install_packages() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    log "${CROSS}" "Packages file not found at $PACKAGES_FILE"
    exit 1
  fi

  log "${CYAN}" "Installing System Packages"
  run_cmd "Updating package lists" "sudo apt-get update -y"

  while IFS= read -r pkg; do
    dpkg -s "$pkg" &>/dev/null || run_cmd "Installing $pkg" "sudo apt-get install -y $pkg"
  done <"$PACKAGES_FILE"
}

main() {
  log "${CYAN}" "Starting Environment Setup"

  sudo add-apt-repository ppa:neovim-ppa/unstable
  install_packages
  # install_tool "Neovim" "command -v nvim" \
  #   "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && sudo tar -C /opt -xzf nvim-linux64.tar.gz && rm nvim-linux64.tar.gz"
  install_tool "JetBrains Mono Nerd Font" "fc-list | grep -qi 'JetBrainsMono'" \
    "wget -q -P $HOME/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip && unzip -q $HOME/.local/share/fonts/JetBrainsMono.zip -d $HOME/.local/share/fonts && fc-cache -fv && rm $HOME/.local/share/fonts/JetBrainsMono.zip"
  install_tool "fzf" "command -v fzf" \
    "git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install --all --no-update-rc"
  install_tool "zoxide" "command -v zoxide" \
    "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
  install_tool "nvm" "command -v nvm" \
    "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash"

  run_cmd "Stowing dotfiles" "cd $DOTFILES_DIR && stow -R -v -t ~ -d $DOTFILES_DIR/env ."
  log "${GREEN}" "Environment setup completed successfully!"
}

main
