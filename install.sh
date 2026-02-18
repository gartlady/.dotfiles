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
  linux*)
    if [[ -f /etc/arch-release ]]; then
      OS="arch"
    else
      OS="ubuntu"
    fi
    ;;
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
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      dpkg -s "$pkg" &>/dev/null || run_cmd "Installing $pkg" "sudo DEBIAN_FRONTEND=noninteractive apt install -y $pkg --no-install-recommends"
    done <"$pkg_file"
    ;;
  macos)
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      if brew list "$pkg" &>/dev/null; then
        log "${CHECK}" "$pkg is already installed"
      else
        run_cmd "Installing $pkg" "brew install $pkg"
      fi
    done <"$pkg_file"
    ;;
  arch)
    setup_yay
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

      if [[ "$pkg" == AUR:* ]]; then
        aur_pkg="${pkg#AUR:}"
        if ! pacman -Qi "$aur_pkg" &>/dev/null && ! yay -Qi "$aur_pkg" &>/dev/null; then
          run_cmd "Installing $aur_pkg (AUR)" "yay -S --noconfirm $aur_pkg"
        else
          log "${CHECK}" "$aur_pkg is already installed"
        fi
      else
        if ! pacman -Qi "$pkg" &>/dev/null; then
          run_cmd "Installing $pkg" "sudo pacman -S --noconfirm --needed $pkg"
        else
          log "${CHECK}" "$pkg is already installed"
        fi
      fi
    done <"$pkg_file"
    ;;
  esac
}

setup_brew() {
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 env /bin/bash -c "$(sudo curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_yay() {
  if ! command -v yay &>/dev/null; then
    run_cmd "Installing yay (AUR helper)" "sudo pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay"
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
  arch)
    log "${CYAN}" "Updating Arch packages"
    run_cmd "Updating pacman" "sudo pacman -Syu --noconfirm"
    ;;
  esac

  log "${CYAN}" "Installing System Packages"
  install_packages

  # Set fish as default shell (with confirmation)
  if command -v fish &>/dev/null; then
    # Get login shell (cross-platform)
    if [[ "$OS" == "macos" ]]; then
      local login_shell=$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}' | xargs basename)
    else
      local login_shell=$(getent passwd $USER 2>/dev/null | cut -d: -f7 | xargs basename)
    fi
    
    if [[ "$login_shell" != "fish" ]]; then
      log "${INFO}" "Fish is installed but not your default shell (currently: $login_shell)"
      read -p "Would you like to set fish as your default shell? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        local fish_path=$(command -v fish)
        if chsh -s "$fish_path" 2>/dev/null || sudo chsh -s "$fish_path" "$USER" 2>/dev/null; then
          log "${CHECK}" "Fish set as default shell. Please log out and back in for changes to take effect."
        else
          log "${CROSS}" "Failed to set fish as default shell. You can do it manually with: chsh -s $(command -v fish)"
        fi
      else
        log "${INFO}" "Keeping $login_shell as default shell. You can switch to fish anytime by running 'fish'."
      fi
    else
      log "${CHECK}" "Fish is already your default shell"
    fi
  fi

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

  # Stow dotfiles
  run_cmd "Stowing dotfiles" "cd $DOTFILES_DIR && stow -R -v -t ~ -d $DOTFILES_DIR/env ."
  log "${GREEN}" "Environment setup completed successfully!"
}

main

