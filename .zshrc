# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# PATH & ENVIRONMENT SETUP
# ==============================================================================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Set Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# ==============================================================================
# THEME CONFIGURATION
# ==============================================================================
ZSH_THEME="powerlevel10k/powerlevel10k"
# Uncomment and customize the following to limit theme candidates:
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" "powerlevel10k" )

# ==============================================================================
# ZSH BEHAVIOR SETTINGS
# ==============================================================================
# Case-insensitive and hyphen-insensitive completion
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

# Auto-update Oh My Zsh settings
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# Enable command auto-correction and waiting dots during completion
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="%F{yellow}...%f"

# History settings
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY             # Append new history entries rather than overwriting
setopt SHARE_HISTORY              # Share history across all sessions
setopt HIST_IGNORE_DUPS           # Ignore duplicate commands
setopt HIST_EXPIRE_DUPS_FIRST     # Expire duplicates first when trimming history
setopt HIST_VERIFY                # Show command for verification before execution

# Automatically change to a directory when its name is entered
setopt AUTO_CD

# ==============================================================================
# EDITOR CONFIGURATION
# ==============================================================================
# Use vim on SSH sessions; otherwise, use nvim.
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ==============================================================================
# PLUGINS & ENHANCEMENTS
# ==============================================================================
plugins=(git fzf fzf-tab zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Load fzf key bindings if available
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# Load fzf-tab plugin
source ~/.fzf-tab/fzf-tab.plugin.zsh

# Load command autosuggestions and syntax highlighting
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==============================================================================
# ALIASES & CUSTOM COMMANDS
# ==============================================================================
# Quick access to configuration files
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

# Clear screen and list directory contents
alias cls="clear"
alias ll="ls -lah"

# Colorize grep output and update system
alias grep="grep --color=auto"
alias update="sudo apt update && sudo apt upgrade -y"

# Use nvim for vim commands
alias vim="nvim"

# Git shortcuts
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias gco="git checkout"
alias gl="git log --oneline --graph --decorate"

# Navigation shortcuts
alias ..="cd .."
alias ...="cd ../.."

# Fast directory navigation with zoxide
eval "$(zoxide init zsh)"

# Enable autojump if installed
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh

# Use bat as a drop-in replacement for cat if available
if command -v bat &> /dev/null; then
  alias cat="bat"
fi

# ==============================================================================
# CUSTOM FUNCTIONS
# ==============================================================================
# mkcd: Create a directory and immediately change into it.
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# extract: Extract archives based on file extension.
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.tar.xz)    tar xJf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# fzf-history-widget: Interactively search command history using fzf (bound to Ctrl+R).
fzf-history-widget() {
  local selected_command
  selected_command=$(fc -l 1 | fzf --height 40% --reverse | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')
  LBUFFER="$selected_command"
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# ==============================================================================
# ENVIRONMENT SETUP FOR LANGUAGES
# ==============================================================================
# Setup pyenv for Python version management.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Setup NVM for Node.js version management.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ==============================================================================
# TMUX SESSION MANAGEMENT
# ==============================================================================
alias ta='tmux attach -t'        # Attach to a tmux session
alias tls='tmux list-sessions'     # List available tmux sessions
alias tn='tmux new -s'            # Create a new tmux session
alias tkill='tmux kill-session -t' # Kill a specific tmux session

# ==============================================================================
# QUALITY OF LIFE SETTINGS
# ==============================================================================
# Speed up prompts in large git repos by ignoring untracked files.
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Disable automatic terminal title updates.
DISABLE_AUTO_TITLE="true"
# Disable magic functions to prevent issues with pasted code.
DISABLE_MAGIC_FUNCTIONS="true"

# ==============================================================================
# ADDITIONAL QUALITY OF LIFE ENHANCEMENTS
# ==============================================================================
# Reload the zsh configuration without restarting the terminal.
alias reload="source ~/.zshrc"

# Use 'exa' for modern directory listings if installed.
if command -v exa &>/dev/null; then
  alias ls="exa --color=auto"      # Replace ls with exa for colored output.
  alias ll="exa -lah --icons"      # Detailed listing with icons and human-readable sizes.
fi

# Disk usage summary of the current directory.
alias duh="du -h --max-depth=1 | sort -hr"

# Git enhancements: graphical log overview.
alias gundo="git log --graph --oneline --decorate --all"

# Clean up local git branches that have been merged.
git-clean-branches() {
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
}

# Docker shortcuts for container management.
alias dps="docker ps"            # List running containers.
alias di="docker images"         # List Docker images.
alias drm="docker rm"            # Remove Docker containers.
alias drun="docker run -it --rm" # Run a container interactively and remove it after exit.

# Create and activate a Python virtual environment quickly.
mkvenv() {
  if [ -z "$1" ]; then
    echo "Usage: mkvenv <env_name>"
  else
    python -m venv "$1" && source "$1/bin/activate"
  fi
}

# Fuzzy file finder: search for files and open the selected file in the editor.
ff() {
  local file
  file=$(find . -type f | fzf --height 40% --reverse --preview 'bat --style=numbers --color=always {}')
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi
}

# Use htop for system monitoring if available.
if command -v htop &>/dev/null; then
  alias top="htop"
fi

# Quickly display public IP information.
alias ipinfo="curl ipinfo.io"

# Add Cargo (Rust) binaries to PATH if Cargo is installed.
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Ensure command history is immediately appended and shared across sessions.
setopt inc_append_history
setopt share_history

# Log execution time for commands running longer than 5 seconds.
preexec() {
  timer=$SECONDS
}
precmd() {
  if [ -n "$timer" ]; then
    local elapsed=$(( SECONDS - timer ))
    if (( elapsed > 5 )); then
      echo "Command took $elapsed seconds to execute."
    fi
    unset timer
  fi
}

# ==============================================================================
# ADDITIONAL DEVELOPER UTILITIES
# ==============================================================================
# Enable fast directory navigation with the 'z' tool if installed.
if command -v z &>/dev/null; then
  eval "$(z -i)"
fi

# Interactive Git branch switcher using fzf.
gbf() {
  local branches branch
  branches=$(git branch --all | sed 's/^[* ]*//')
  branch=$(echo "$branches" | fzf --height 40% --reverse)
  if [ -n "$branch" ]; then
    # Remove remote prefix if present before switching.
    git checkout "$(echo "$branch" | sed 's#remotes/[^/]*/##')"
  fi
}

# Quickly SSH to a recent host selected from ~/.ssh/known_hosts.
ssh_recent() {
  awk '{print $1}' ~/.ssh/known_hosts | cut -d, -f1 | sort | uniq | fzf --height 40% --reverse | xargs -r ssh
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
