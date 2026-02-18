# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add zsh plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -U compinit && compinit
zinit cdreplay -q

# Load nvim
export PATH=$PATH:/opt/nvim-linux-x86_64/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History config
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:j:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ssh='env TERM=xterm-256color ssh' # allows kitty to work with ssh
alias ls='ls -ltr --color'
alias cd='j'
alias cdi='ji'

# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
export FZF_DEFAULT_OPTS='--height 40% --layout reverse'

# Load zoxide
eval "$(zoxide init zsh --cmd j)"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PLAYDATE_SDK_PATH="$HOME/projects/playdate/PlaydateSDK"
export PLAYDATE_ARM_GCC="$HOME/projects/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi"
export CMAKE_C_COMPILER="$HOME/projects/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc"

export PATH=$PLAYDATE_SDK_PATH/bin:$PATH
export PATH=$PLAYDATE_ARM_GCC/bin:$PATH
export PATH=$HOME/Downloads/cmake-3.31.0-rc2-linux-x86_64/bin:$PATH
export PATH=$HOME/Downloads:$PATH
export PATH=$HOME/.sst/bin:$PATH
export PATH=/opt/homebrew/opt/libpq/bin:$PATH

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/dylan/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

alias ase=/home/dylan/projects/aseprite/aseprite-release/bin/aseprite

# opencode
export PATH=/home/dylan/.opencode/bin:$PATH
export PATH=$PATH:~/zig
export PATH=$PATH:$GOBIN

# bun completions
[ -s "/Users/dylan/.bun/_bun" ] && source "/Users/dylan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
eval "$(mise activate zsh)"
