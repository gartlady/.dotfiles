# Fish shell configuration migrated from zsh
# Generated on: (date)

# Platform detection
set -gx OS_TYPE (uname -s)

# Set nvim as default editor for Alt+E command editing
set -gx EDITOR nvim
set -gx VISUAL nvim

# Path configurations (migrated from .zshrc)
set -gx PATH $PATH $HOME/.local/bin

# Platform-specific paths
if test "$OS_TYPE" = "Linux"
    # Linux-specific paths
    if test -d /opt/nvim-linux-x86_64/bin
        set -gx PATH $PATH /opt/nvim-linux-x86_64/bin
    end
    if test -d $HOME/Downloads/cmake-3.31.0-rc2-linux-x86_64/bin
        set -gx PATH $PATH $HOME/Downloads/cmake-3.31.0-rc2-linux-x86_64/bin
    end
end

# macOS-specific paths
if test "$OS_TYPE" = "Darwin"
    # Intel Mac Homebrew
    if test -x /usr/local/bin/brew
        set -gx HOMEBREW_PREFIX /usr/local
    # Apple Silicon Mac Homebrew
    else if test -x /opt/homebrew/bin/brew
        set -gx HOMEBREW_PREFIX /opt/homebrew
    end
    
    # Add Homebrew to PATH if detected
    if set -q HOMEBREW_PREFIX
        set -gx PATH $PATH $HOMEBREW_PREFIX/bin
        set -gx PATH $PATH $HOMEBREW_PREFIX/sbin
    end
    
    # Check for macOS-specific CMake
    if test -d $HOME/Downloads/cmake-3.31.0-rc2-macos-universal/bin
        set -gx PATH $PATH $HOME/Downloads/cmake-3.31.0-rc2-macos-universal/bin
    end
end

# Common paths (both platforms)
set -gx PATH $PATH /usr/local/go/bin
set -gx PATH $PATH $HOME/Downloads
set -gx PATH $PATH $HOME/.sst/bin
set -gx PATH $PATH $HOME/.opencode/bin
set -gx PATH $PATH $HOME/zig

# Environment variables
set -gx PLAYDATE_SDK_PATH "$HOME/projects/playdate/PlaydateSDK"
set -gx PLAYDATE_ARM_GCC "$HOME/projects/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi"
set -gx CMAKE_C_COMPILER "$HOME/projects/playdate/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gcc"
set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin

# Playdate SDK path
set -gx PATH $PATH $PLAYDATE_SDK_PATH/bin
set -gx PATH $PATH $PLAYDATE_ARM_GCC/bin
set -gx PATH $PATH $GOBIN

# Homebrew-specific paths (check if Homebrew exists)
if set -q HOMEBREW_PREFIX
    if test -d $HOMEBREW_PREFIX/opt/libpq/bin
        set -gx PATH $PATH $HOMEBREW_PREFIX/opt/libpq/bin
    end
end

# NVM
set -gx NVM_DIR "$HOME/.nvm"

# Fish features configuration
# Enable fish shell features
set -g fish_greeting ""  # Disable welcome message

# Disable syntax highlighting (no colors while typing)
set -g fish_color_normal normal
set -g fish_color_command normal
set -g fish_color_param normal
set -g fish_color_redirection normal
set -g fish_color_comment normal
set -g fish_color_error normal
set -g fish_color_escape normal
set -g fish_color_operator normal
set -g fish_color_end normal
set -g fish_color_quote normal
set -g fish_color_autosuggestion brblack --dim
set -g fish_color_valid_path normal
set -g fish_color_cwd normal
set -g fish_color_cwd_root normal
set -g fish_color_match normal
set -g fish_color_selection normal
set -g fish_color_search_match normal
set -g fish_color_history_current normal
set -g fish_color_user normal
set -g fish_color_host normal
set -g fish_color_status normal
set -g fish_color_cancel normal

# LS_COLORS - using system defaults (same as zsh)
set -gx LS_COLORS 'rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:'

# History configuration
set -gx HISTSIZE 10000
set -gx HISTFILE ~/.config/fish/fish_history

# Aliases (converted from zsh)
function ssh --description 'SSH with kitty compatibility'
    env TERM=xterm-256color ssh $argv
end

function ls --description 'List files with color and time order'
    command ls -ltr --color $argv
end

function cd --description 'Use zoxide for directory jumping'
    j $argv
end

function cdi --description 'Use zoxide for interactive directory jumping'
    ji $argv
end

function ase --description 'Launch Aseprite'
    if test -x $HOME/projects/aseprite/aseprite-release/bin/aseprite
        $HOME/projects/aseprite/aseprite-release/bin/aseprite $argv
    else if test -x /Applications/Aseprite.app/Contents/MacOS/aseprite
        /Applications/Aseprite.app/Contents/MacOS/aseprite $argv
    else
        echo "Aseprite not found in standard locations"
    end
end

# Initialize tools
if type -q zoxide
    zoxide init fish --cmd j | source
end

if type -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout reverse'
end

# NVM loading - dynamic Homebrew path detection
if set -q HOMEBREW_PREFIX
    if test -f "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
        bass source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    end
    
    if test -f "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
        bass source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
    end
end

# Custom prompt to match zsh style exactly
function fish_prompt
    set_color brcyan
    echo -n (prompt_pwd --full-length-dirs 3)
    set_color normal
    echo -n " "
    set_color brgreen
    echo -n "❯"
    set_color normal
    echo -n " "
end
