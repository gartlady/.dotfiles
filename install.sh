#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"

GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

check="${GREEN}[✓]${RESET}"
cross="${RED}[✗]${RESET}"
info="${CYAN}[ℹ]${RESET}"

log() { echo -e "$1 $2"; }

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
      log "$cross" "Unsupported OS"
      exit 1
      ;;
  esac
  log "$check" "OS detected: $OS"
}

update_system() {
  log "$info" "Updating system packages..."
  case "$OS" in
    ubuntu) sudo apt-get update -y ;;
    macos) brew update ;;
    arch) sudo pacman -Syu --noconfirm ;;
  esac
  log "$check" "System updated"
}

install_packages() {
  log "$info" "Installing packages..."
  local pkg_file="$DOTFILES_DIR/packages.$OS"
  
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    
    case "$OS" in
      ubuntu)
        if ! dpkg -s "$pkg" &>/dev/null; then
          log "$info" "Installing: $pkg"
          sudo apt-get install -y "$pkg" --no-install-recommends
        fi
        ;;
      macos)
        if ! brew list "$pkg" &>/dev/null; then
          log "$info" "Installing: $pkg"
          brew install "$pkg"
        fi
        ;;
      arch)
        if [[ "$pkg" == AUR:* ]]; then
          local aur_pkg="${pkg#AUR:}"
          if ! pacman -Qi "$aur_pkg" &>/dev/null && ! yay -Qi "$aur_pkg" &>/dev/null; then
            log "$info" "Installing (AUR): $aur_pkg"
            yay -S --noconfirm "$aur_pkg"
          fi
        elif ! pacman -Qi "$pkg" &>/dev/null; then
          log "$info" "Installing: $pkg"
          sudo pacman -S --noconfirm --needed "$pkg"
        fi
        ;;
    esac
    log "$check" "$pkg installed"
  done <"$pkg_file"
}

install_zoxide() {
  if [[ "$OS" == "ubuntu" ]] && ! command -v zoxide &>/dev/null; then
    log "$info" "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    log "$check" "zoxide installed"
  fi
}

install_font() {
  log "$info" "Installing JetBrains Mono Nerd Font..."
  
  if [[ "$OS" == "macos" ]]; then
    if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi 'JetBrainsMono'; then
      log "$check" "Font already installed"
      return
    fi
    curl -L --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -o /tmp/JetBrainsMono.zip
    unzip -o -q /tmp/JetBrainsMono.zip -d "$HOME/Library/Fonts"
    rm /tmp/JetBrainsMono.zip
  else
    if fc-list 2>/dev/null | grep -qi 'JetBrainsMono'; then
      log "$check" "Font already installed"
      return
    fi
    mkdir -p "$HOME/.local/share/fonts"
    wget --progress=bar:force -P "$HOME/.local/share/fonts" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    unzip -o -q "$HOME/.local/share/fonts/JetBrainsMono.zip" -d "$HOME/.local/share/fonts"
    fc-cache -fv &>/dev/null
    rm "$HOME/.local/share/fonts/JetBrainsMono.zip"
  fi
  log "$check" "Font installed"
}

setup_fish() {
  local current_shell
  if [[ "$OS" == "macos" ]]; then
    current_shell=$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}' | xargs basename)
  else
    current_shell=$(getent passwd $USER 2>/dev/null | cut -d: -f7 | xargs basename)
  fi
  
  [[ "$current_shell" == "fish" ]] && return
  
  log "$info" "Current shell: $current_shell"
  read -p "Set fish as default shell? (y/n) " -n 1 -r
  echo
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    local fish_path=$(command -v fish)
    chsh -s "$fish_path" || sudo chsh -s "$fish_path" "$USER"
    log "$check" "Fish set as default shell"
  fi
}

stow_dotfiles() {
  log "$info" "Stowing dotfiles..."
  cd "$DOTFILES_DIR"
  stow -R -t ~ -d "$DOTFILES_DIR/env" .
  log "$check" "Dotfiles stowed"
}

main() {
  detect_os
  update_system
  install_packages
  install_zoxide
  install_font
  setup_fish
  stow_dotfiles
  echo ""
  log "$check" "Installation complete!"
}

main
