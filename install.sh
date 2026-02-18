#!/bin/bash

set -euo pipefail

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

setup_brew() {
  if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 env /bin/bash -c "$(curl -sSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_yay() {
  if ! command -v yay &>/dev/null; then
    run_cmd "Installing yay (AUR helper)" "sudo pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm && cd - && rm -rf /tmp/yay"
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
    log "${CYAN}" "Updating package lists and upgrading existing packages"
    run_cmd "Updating package lists" "sudo DEBIAN_FRONTEND=noninteractive apt-get update"
    run_cmd "Upgrading existing packages" "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
    
    local to_install=()
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
        to_install+=("$pkg")
        log "${INFO}" "Will install: $pkg"
      else
        log "${CHECK}" "$pkg already installed"
      fi
    done <"$pkg_file"
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
      run_cmd "Installing packages: ${to_install[*]}" \
        "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ${to_install[*]} --no-install-recommends"
    fi
    
    # Handle zoxide separately (not in Ubuntu repos)
    if ! command -v zoxide &>/dev/null; then
      run_cmd "Installing zoxide" \
        "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
    fi
    ;;
    
  macos)
    log "${CYAN}" "Updating Homebrew and upgrading packages"
    run_cmd "Updating Homebrew" "brew update"
    run_cmd "Upgrading existing packages" "brew upgrade"
    
    local to_install=()
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      if ! brew list "$pkg" &>/dev/null 2>&1; then
        to_install+=("$pkg")
        log "${INFO}" "Will install: $pkg"
      else
        log "${CHECK}" "$pkg already installed"
      fi
    done <"$pkg_file"
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
      run_cmd "Installing packages: ${to_install[*]}" "brew install ${to_install[*]}"
    fi
    ;;
    
  arch)
    log "${CYAN}" "Updating system packages"
    run_cmd "Updating pacman" "sudo pacman -Syu --noconfirm"
    
    local to_install=()
    local aur_install=()
    
    while IFS= read -r pkg; do
      [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
      
      if [[ "$pkg" == AUR:* ]]; then
        aur_pkg="${pkg#AUR:}"
        if ! pacman -Qi "$aur_pkg" &>/dev/null 2>&1 && ! yay -Qi "$aur_pkg" &>/dev/null 2>&1; then
          aur_install+=("$aur_pkg")
          log "${INFO}" "Will install (AUR): $aur_pkg"
        else
          log "${CHECK}" "$aur_pkg already installed"
        fi
      else
        if ! pacman -Qi "$pkg" &>/dev/null 2>&1; then
          to_install+=("$pkg")
          log "${INFO}" "Will install: $pkg"
        else
          log "${CHECK}" "$pkg already installed"
        fi
      fi
    done <"$pkg_file"
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
      run_cmd "Installing packages" "sudo pacman -S --noconfirm --needed ${to_install[*]}"
    fi
    
    if [[ ${#aur_install[@]} -gt 0 ]]; then
      run_cmd "Installing AUR packages" "yay -S --noconfirm ${aur_install[*]}"
    fi
    ;;
  esac
}

install_font() {
  log "${CYAN}" "Checking JetBrains Mono Nerd Font"
  
  if [[ "$OS" == "macos" ]]; then
    if ls "$HOME/Library/Fonts" 2>/dev/null | grep -qi 'JetBrainsMono'; then
      log "${CHECK}" "JetBrains Mono Nerd Font already installed"
      return
    fi
    
    log "${INFO}" "Downloading JetBrains Mono Nerd Font (~200MB)..."
    if curl -L --progress-bar "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" -o /tmp/JetBrainsMono.zip; then
      log "${INFO}" "Extracting fonts..."
      unzip -q /tmp/JetBrainsMono.zip -d "$HOME/Library/Fonts" && rm /tmp/JetBrainsMono.zip
      log "${CHECK}" "JetBrains Mono Nerd Font installed"
    else
      log "${CROSS}" "Failed to download JetBrains Mono Nerd Font"
      return 1
    fi
  else
    if fc-list 2>/dev/null | grep -qi 'JetBrainsMono'; then
      log "${CHECK}" "JetBrains Mono Nerd Font already installed"
      return
    fi
    
    mkdir -p "$HOME/.local/share/fonts"
    log "${INFO}" "Downloading JetBrains Mono Nerd Font (~200MB)..."
    if wget --progress=bar:force -P "$HOME/.local/share/fonts" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip" 2>&1 | grep -v "^$"; then
      log "${INFO}" "Extracting fonts..."
      unzip -q "$HOME/.local/share/fonts/JetBrainsMono.zip" -d "$HOME/.local/share/fonts"
      log "${INFO}" "Rebuilding font cache..."
      fc-cache -fv &>/dev/null
      rm "$HOME/.local/share/fonts/JetBrainsMono.zip"
      log "${CHECK}" "JetBrains Mono Nerd Font installed"
    else
      log "${CROSS}" "Failed to download JetBrains Mono Nerd Font"
      return 1
    fi
  fi
}

setup_fish_shell() {
  if command -v fish &>/dev/null; then
    local current_shell
    if [[ "$OS" == "macos" ]]; then
      current_shell=$(dscl . -read /Users/$USER UserShell 2>/dev/null | awk '{print $2}' | xargs basename)
    else
      current_shell=$(getent passwd $USER 2>/dev/null | cut -d: -f7 | xargs basename)
    fi
    
    if [[ "$current_shell" != "fish" ]]; then
      log "${INFO}" "Fish is installed but not default (currently: $current_shell)"
      read -p "Set fish as default shell? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        local fish_path=$(command -v fish)
        if chsh -s "$fish_path" 2>/dev/null || sudo chsh -s "$fish_path" "$USER" 2>/dev/null; then
          log "${CHECK}" "Fish set as default shell. Log out and back in to apply."
        else
          log "${CROSS}" "Failed to change shell. Run: chsh -s $(command -v fish)"
        fi
      fi
    else
      log "${CHECK}" "Fish is already default shell"
    fi
  fi
}

stow_dotfiles() {
  log "${CYAN}" "Checking dotfiles installation"
  
  # Check if already stowed by looking for symlink
  if [[ -L "$HOME/.config/fish/config.fish" ]]; then
    log "${CHECK}" "Dotfiles already stowed"
    # Still run stow to catch any new files
    run_cmd "Updating stowed dotfiles" "cd $DOTFILES_DIR && stow -R -v -t ~ -d $DOTFILES_DIR/env ."
  else
    run_cmd "Stowing dotfiles" "cd $DOTFILES_DIR && stow -R -v -t ~ -d $DOTFILES_DIR/env ."
  fi
}

main() {
  detect_os
  log "${CYAN}" "Starting Environment Setup"

  # OS-specific setup
  case "$OS" in
  ubuntu)
    log "${CYAN}" "Updating Ubuntu packages"
    run_cmd "Updating package lists" "sudo DEBIAN_FRONTEND=noninteractive apt-get update -y"
    run_cmd "Installing software-properties-common" "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common --no-install-recommends"
    run_cmd "Adding neovim repository" "sudo DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:neovim-ppa/unstable"
    ;;
  macos)
    log "${CYAN}" "Setting up Homebrew"
    setup_brew
    ;;
  arch)
    log "${CYAN}" "Updating Arch packages"
    setup_yay
    ;;
  esac

  log "${CYAN}" "Installing System Packages"
  install_packages

  setup_fish_shell
  install_font
  stow_dotfiles
  
  log "${GREEN}" "Environment setup completed successfully!"
}

main
