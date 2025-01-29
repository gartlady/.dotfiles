#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

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

# OS detection
detect_os() {
  case "$OSTYPE" in
  darwin*) OS="macos" ;;
  linux*) OS="ubuntu" ;;
  *)
    log "${CROSS}" "Unsupported OS"
    exit 1
    ;;
  esac
}

log() { echo -e "${1} ${2}" ${RESET}; }
run_cmd() {
  log "${INFO}" "$1"
  eval "$2" &>/dev/null || {
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
  local pkg_file="$DOTFILES_DIR/packages.$OS"
  if [[ ! -f "$pkg_file" ]]; then
    log "${CROSS}" "Packages file for $OS not found at $pkg_file"
    exit 1
  fi

  case "$OS" in
  ubuntu)
    while IFS= read -r pkg; do
      dpkg -s "$pkg" &>/dev/null || run_cmd "Installing $pkg" "sudo DEBIAN_FRONTEND=noninteractive apt install -y $pkg --no-install-recommends"
    done <"$pkg_file"
    ;;
  macos)
    while IFS= read -r pkg; do
      if brew info "$pkg" &>/dev/null; then
        log "${CHECK}" "$pkg is already installed"
      else
        run_cmd "Installing $pkg" "brew install $pkg"
      fi
    done <"$pkg_file"
    ;;
  esac
}

setup_brew() {
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 env /bin/bash -c "$(sudo curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

main() {
  detect_os
  log "${CYAN}" "Starting Environment Setup"

  # OS-specific setup
  case "$OS" in
  ubuntu)
    log "${CYAN}" "Updating Ubuntu packages"
    run_cmd "Updating package lists" "sudo DEBIAN_FRONTEND=noninteractive apt update -y --no-install-recommends"
    run_cmd "Installing software-properties-common" "sudo DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common --no-install-recommends"
    run_cmd "Adding neovim repository" "sudo DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:neovim-ppa/unstable"
    ;;
  macos)
    log "${CYAN}" "Setting up Homebrew"
    setup_brew
    run_cmd "Updating Homebrew" "brew update"
    ;;
  esac

  log "${CYAN}" "Installing System Packages"
  install_packages

  # Font installation
  log "${CYAN}" "Installing JetBrains Mono Nerd Font"
  if [[ "$OS" == "macos" ]]; then
    font_check="ls $HOME/Library/Fonts | grep -qi 'JetBrainsMono'"
    font_install="curl -sSL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip -o /tmp/JetBrainsMono.zip && unzip -q /tmp/JetBrainsMono.zip -d $HOME/Library/Fonts && rm /tmp/JetBrainsMono.zip"
  else
    font_check="fc-list | grep -qi 'JetBrainsMono'"
    font_install="wget -q -P $HOME/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip && unzip -q $HOME/.local/share/fonts/JetBrainsMono.zip -d $HOME/.local/share/fonts && fc-cache -fv && rm $HOME/.local/share/fonts/JetBrainsMono.zip"
  fi
  install_tool "JetBrains Mono Nerd Font" "$font_check" "$font_install"

  # Tool installations
  log "${CYAN}" "Installing Development Tools"
  case "$OS" in
  ubuntu)
    install_tool "fzf" "command -v fzf" "git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf && $HOME/.fzf/install --all --no-update-rc"
    install_tool "zoxide" "command -v zoxide" "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
    install_tool "nvm" "command -v nvm" "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash"
    ;;
  esac

  # Stow dotfiles
  run_cmd "Stowing dotfiles" "cd $DOTFILES_DIR && stow -R -v -t ~ -d $DOTFILES_DIR/env ."
  log "${GREEN}" "Environment setup completed successfully!"
}

main
