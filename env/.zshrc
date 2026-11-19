# Zsh configuration

OS_TYPE=$(uname -s)
export OS_TYPE

export EDITOR=nvim
export VISUAL=nvim

# PATH — common
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/Downloads"
export PATH="$PATH:$HOME/.sst/bin"
export PATH="$PATH:$HOME/.opencode/bin"
export PATH="$PATH:$HOME/zig"
export PATH="$PATH:$HOME/usr/local/bin"

# Platform-specific PATH
case "$OS_TYPE" in
  Linux)
    for dir in /opt/nvim-linux-x86_64/bin /usr/local/bin /usr/bin; do
      if [ -x "$dir/nvim" ]; then
        export PATH="$dir:$PATH"
        break
      fi
    done
    if [ -x "$HOME/Downloads/cmake-3.31.0-rc2-linux-x86_64/bin/cmake" ]; then
      export PATH="$HOME/Downloads/cmake-3.31.0-rc2-linux-x86_64/bin:$PATH"
    fi
    ;;
  Darwin)
    export PATH="/usr/local/bin:$PATH"
    if [ -x /opt/homebrew/bin/brew ]; then
      export HOMEBREW_PREFIX=/opt/homebrew
    elif [ -x /usr/local/bin/brew ]; then
      export HOMEBREW_PREFIX=/usr/local
    fi
    if [ -n "$HOMEBREW_PREFIX" ]; then
      export PATH="$HOMEBREW_PREFIX/bin:$PATH"
      export PATH="$HOMEBREW_PREFIX/sbin:$PATH"
    fi
    if [ -x "$HOME/Downloads/cmake-3.31.0-rc2-macos-universal/bin/cmake" ]; then
      export PATH="$HOME/Downloads/cmake-3.31.0-rc2-macos-universal/bin:$PATH"
    fi
    ;;
esac

# Playdate SDK
export PLAYDATE_SDK_PATH="$HOME/projects/playdate/PlaydateSDK"
export PLAYDATE_ARM_GCC="$HOME/projects/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi"
export CMAKE_C_COMPILER="$PLAYDATE_ARM_GCC/bin/arm-none-eabi-gcc"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH="$PATH:$PLAYDATE_SDK_PATH/bin"
export PATH="$PATH:$PLAYDATE_ARM_GCC/bin"
export PATH="$PATH:$GOBIN"

# Homebrew libpq
if [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX/opt/libpq/bin" ]; then
  export PATH="$PATH:$HOMEBREW_PREFIX/opt/libpq/bin"
fi

# NVM
export NVM_DIR="$HOME/.nvm"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# LS_COLORS (GNU ls — Linux)
export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:'

# LSCOLORS (BSD ls — macOS) — blue directories, cyan symlinks, etc.
export LSCOLORS='Exfxcxdxbxegedabagacad'

# Aliases
alias ssh='env TERM=xterm-256color ssh'
alias ls='ls -ltr --color'
alias cd='j'
alias cdi='ji'

ase() {
  if [ -x "$HOME/projects/aseprite/aseprite-release/bin/aseprite" ]; then
    "$HOME/projects/aseprite/aseprite-release/bin/aseprite" "$@"
  elif [ -x /Applications/Aseprite.app/Contents/MacOS/aseprite ]; then
    /Applications/Aseprite.app/Contents/MacOS/aseprite "$@"
  else
    echo "Aseprite not found in standard locations"
  fi
}

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd j)"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  export FZF_DEFAULT_OPTS='--height 40% --layout reverse'
fi

# nvm
if [ -n "$HOMEBREW_PREFIX" ] && [ -f "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  if [ -f "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]; then
    source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  fi
fi
[ -f "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh"

# zsh-autosuggestions
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'
fi

# Custom prompt
PROMPT='%F{14}%~%f %F{10}❯%f '
