#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"

# Color definitions
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
MAGENTA="\033[0;35m"
RESET="\033[0m"

# Status icons
CHECK="${GREEN}[✓]${RESET}"
CROSS="${RED}[✗]${RESET}"
INFO="${CYAN}[ℹ]${RESET}"
ARROW="${BLUE}[➜]${RESET}"

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

# Helper functions
print_header() {
  local msg="$1"
  echo -e "\n${BOLD}${CYAN}${msg}${RESET}"
}

print_step() {
  ((CURRENT_STEP++))
  local msg="$1"
  echo -e "${BOLD}${BLUE}[${CURRENT_STEP}/${TOTAL_STEPS}]${RESET} ${YELLOW}${msg}${RESET}"
}

print_success() {
  echo -e "${CHECK} ${GREEN}$1${RESET}"
}

print_error() {
  echo -e "${CROSS} ${RED}$1${RESET}"
}

print_info() {
  echo -e "${INFO} ${CYAN}$1${RESET}"
}

spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  while kill -0 "$pid" 2>/dev/null; do
    for i in $(seq 0 9); do
      printf "  ${spinstr:$i:1} ${YELLOW}Working...${RESET}\r"
      sleep $delay
    done
  done
  printf "            \r"
}

run_step() {
  local msg="$1"
  local cmd="$2"
  local interactive="$3"

  print_info "${ARROW} ${msg}"

  if [ "$interactive" = "true" ]; then
    eval "$cmd"
    return $?
  else
    eval "$cmd" >/dev/null 2>&1 &
    local pid=$!
    spinner $pid
    wait $pid
    return $?
  fi
}

install_dotfiles() {
  print_header "Installing Dotfiles"
  print_step "Stowing configuration"

  if run_step "Running stow" "cd $DOTFILES_DIR && stow ."; then
    print_success "Dotfiles successfully stowed"
  else
    print_error "Failed to stow dotfiles"
    exit 1
  fi

  if ! fc-list | grep -q -i "JetBrainsMono"; then
    run_step "Refreshing font cache" "fc-cache -fv"
    run_step "Cleaning font files" "rm -f $HOME/.local/share/fonts/JetBrainsMono.zip"
  fi

  if ! command -v nvim &>/dev/null; then
    run_step "Cleaning Neovim files" "rm -f nvim-linux64.tar.gz"
  fi
}

install_dependencies() {
  print_header "Installing Dependencies"
  print_step "Updating package lists"

  if run_step "Updating apt" "sudo apt-get update -y" "true"; then
    print_success "Package lists updated"
  else
    print_error "Failed to update package lists"
    exit 1
  fi

  local packages=(stow zsh vim git jq unzip fontconfig wget curl ripgrep)
  print_step "Installing system packages"

  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      if run_step "Installing $pkg" "sudo apt-get install -y $pkg" "true"; then
        print_success "Installed $pkg"
      else
        print_error "Failed to install $pkg"
        exit 1
      fi
    else
      print_info "${CHECK} $pkg is already installed"
    fi
  done

  install_nerd_font
  install_fzf
  install_zoxide
  install_nvm
  check_and_install_neovim
}

check_and_install_neovim() {
  print_step "Checking Neovim installation"

  if command -v nvim &>/dev/null; then
    print_info "${CHECK} Neovim is already installed"
    return
  fi

  print_step "Installing Neovim"

  if run_step "Downloading Neovim" \
    "curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"; then
    print_success "Neovim downloaded"
  else
    print_error "Failed to download Neovim"
    exit 1
  fi

  if run_step "Installing Neovim" \
    "sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux64.tar.gz" "true"; then
    print_success "Neovim installed"
  else
    print_error "Failed to install Neovim"
    exit 1
  fi
}

install_nerd_font() {
  print_step "Checking JetBrains Mono font"

  if fc-list | grep -q -i "JetBrainsMono"; then
    print_info "${CHECK} JetBrains Mono is already installed"
    return
  fi

  print_step "Installing JetBrains Mono"

  if run_step "Downloading font" \
    "wget -q -P $DOTFILES_DIR/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"; then
    print_success "Font downloaded"
  else
    print_error "Failed to download font"
    exit 1
  fi

  if run_step "Unzipping font" \
    "unzip -q $DOTFILES_DIR/.local/share/fonts/JetBrainsMono.zip -d $DOTFILES_DIR/.local/share/fonts"; then
    print_success "Font installed"
  else
    print_error "Failed to install font"
    exit 1
  fi
}

install_fzf() {
  print_step "Checking fzf installation"

  if command -v fzf &>/dev/null; then
    print_info "${CHECK} fzf is already installed"
    return
  fi

  print_step "Installing fzf"

  if run_step "Cloning fzf" \
    "git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf"; then
    print_success "fzf cloned"
  else
    print_error "Failed to clone fzf"
    exit 1
  fi

  if run_step "Installing fzf" \
    "$HOME/.fzf/install --all --no-update-rc"; then
    print_success "fzf installed"
  else
    print_error "Failed to install fzf"
    exit 1
  fi
}

install_zoxide() {
  print_step "Checking zoxide installation"

  if command -v zoxide &>/dev/null; then
    print_info "${CHECK} zoxide is already installed"
    return
  fi

  print_step "Installing zoxide"

  if run_step "Downloading zoxide" \
    "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"; then
    print_success "zoxide installed"
  else
    print_error "Failed to install zoxide"
    exit 1
  fi
}

install_nvm() {
  print_step "Checking nvm installation"

  if command -v nvm --version &>/dev/null; then
    print_info "${CHECK} nvm is already installed"
    return
  fi

  print_step "Installing nvm"

  if run_step "Downloading nvm" \
    "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash"; then
    print_success "nvm installed"
  else
    print_error "Failed to install nvm"
    exit 1
  fi
}

main() {
  print_header "Starting Dotfiles Setup"
  install_dependencies
  install_dotfiles

  echo -e "\n${BOLD}${GREEN}✅ Setup completed successfully!${RESET}"
}

main
