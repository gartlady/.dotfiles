#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"

GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
RESET="\033[0m"

check="${GREEN}[✓]${RESET}"
cross="${RED}[✗]${RESET}"
info="${CYAN}[ℹ]${RESET}"
warn="${YELLOW}[!]${RESET}"

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
}

unstow_dotfiles() {
  log "$info" "Unstowing dotfiles..."
  cd "$DOTFILES_DIR"
  stow -D -t ~ -d "$DOTFILES_DIR/env" . 2>/dev/null || true
  log "$check" "Dotfiles unstowed"
}

restore_shell() {
  log "$info" "Restoring shell to bash..."
  local bash_path=$(command -v bash)
  chsh -s "$bash_path" || sudo chsh -s "$bash_path" "$USER"
  log "$check" "Shell restored to bash"
}

remove_packages() {
  local pkg_file="$DOTFILES_DIR/packages.$OS"
  
  log "$info" "Packages that can be removed:"
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    [[ "$pkg" == AUR:* ]] && pkg="${pkg#AUR:}"
    echo "  - $pkg"
  done <"$pkg_file"
  echo ""
  
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    [[ "$pkg" == AUR:* ]] && pkg="${pkg#AUR:}"
    
    read -p "Remove $pkg? (y/n) " -n 1 -r < /dev/tty
    echo >&2
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      case "$OS" in
        ubuntu) sudo apt-get remove -y "$pkg" ;;
        macos) brew uninstall "$pkg" ;;
        arch) sudo pacman -R --noconfirm "$pkg" ;;
      esac
      log "$check" "Removed $pkg"
    else
      log "$info" "Skipped $pkg"
    fi
  done <"$pkg_file"
}

remove_font() {
  read -p "Remove JetBrains Mono font? (y/n) " -n 1 -r < /dev/tty
  echo >&2
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OS" == "macos" ]]; then
      rm -f "$HOME/Library/Fonts"/*JetBrains* 2>/dev/null || true
    else
      rm -f "$HOME/.local/share/fonts"/*JetBrains* 2>/dev/null || true
      fc-cache -fv &>/dev/null || true
    fi
    log "$check" "Font removed"
  else
    log "$info" "Font kept"
  fi
}

main() {
  detect_os
  
  echo ""
  log "$warn" "This will uninstall dotfiles and optionally remove packages"
  read -p "Continue? (y/n) " -n 1 -r < /dev/tty
  echo >&2
  [[ $REPLY =~ ^[Yy]$ ]] || exit 0
  
  unstow_dotfiles
  remove_packages
  remove_font
  restore_shell
  
  echo ""
  log "$check" "Cleanup complete!"
  log "$info" "Log out and back in for shell changes to take effect"
}

main
