################################################################################
# File Path: ~/.zshrc
# Description: This configuration file for the Z shell (zsh) is used to set up
#              environment variables, load plugins, define aliases and functions,
#              and customize the shell experience. The file has been annotated
#              in detail so that even a junior engineer may understand its purpose.
# Creation Date: 2025-03-31
# Last Modified: 2025-03-31
# Necessary Datafiles and Dependencies:
#   - Oh My Zsh (should be installed at $HOME/.oh-my-zsh)
#   - Powerlevel10k theme (required for the prompt; must be installed)
#   - fzf and fzf-tab (for fuzzy finding functionality)
#   - zsh-autosuggestions and zsh-syntax-highlighting (for enhanced shell features)
#   - Additional tools such as autojump, zoxide, pyenv, NVM, exa, bat, htop, etc.
################################################################################

# ------------------------------------------------------------------------------
# Instant Prompt Initialization for Powerlevel10k
# This section is used to enable the Powerlevel10k instant prompt feature.
# It is placed near the top to allow faster prompt rendering.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# Define Missing ZLE Widgets
# The following commands are used to define missing ZLE widgets which are used
# by zsh-syntax-highlighting. This prevents errors about unhandled widgets.
zle -N insert-unambiguous-or-complete
zle -N menu-search
zle -N recent-paths

# ------------------------------------------------------------------------------
# PATH & ENVIRONMENT SETUP
# The PATH is extended so that custom binaries and local installations can be found.
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Set the path to Oh My Zsh, which is required to load its framework.
export ZSH="$HOME/.oh-my-zsh"

# ------------------------------------------------------------------------------
# THEME CONFIGURATION
# The theme is set to Powerlevel10k for an enhanced prompt experience.
ZSH_THEME="powerlevel10k/powerlevel10k"
# (Optional) A list of theme candidates can be defined here if random selection is desired.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" "powerlevel10k" )

# ------------------------------------------------------------------------------
# ZSH BEHAVIOR SETTINGS
# These settings adjust how the shell handles completion, history, and corrections.
CASE_SENSITIVE="false"                # Case is ignored in completions.
HYPHEN_INSENSITIVE="true"             # Hyphens are treated as equivalent to underscores.
zstyle ':omz:update' mode auto         # Auto-update is enabled.
zstyle ':omz:update' frequency 7       # Auto-update is checked every 7 days.
ENABLE_CORRECTION="true"              # Automatic correction of mistyped commands is enabled.
COMPLETION_WAITING_DOTS="%F{yellow}...%f"  # A waiting indicator is shown during completion.

# History configuration is set to save a larger amount of commands and share them.
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY             # History entries are appended.
setopt SHARE_HISTORY              # History is shared between sessions.
setopt HIST_IGNORE_DUPS           # Duplicate commands are not stored.
setopt HIST_EXPIRE_DUPS_FIRST     # Older duplicates are removed first.
setopt HIST_VERIFY                # Commands are shown for verification before execution.

# AUTO_CD is enabled so that entering a directory name automatically changes to it.
setopt AUTO_CD

# ------------------------------------------------------------------------------
# EDITOR CONFIGURATION
# The default editor is set based on whether the session is remote (SSH) or local.
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ------------------------------------------------------------------------------
# PLUGINS & ENHANCEMENTS
# The following line lists plugins to be loaded by Oh My Zsh. They provide
# additional features like Git integration, fuzzy finding, and command suggestions.
plugins=(git fzf fzf-tab zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# fzf key bindings are loaded if the file is available.
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# A Python alias is created for convenience.
alias py='python3'

# The fzf-tab plugin is sourced to provide enhanced tab completion.
source ~/.fzf-tab/fzf-tab.plugin.zsh

# The zsh-autosuggestions and zsh-syntax-highlighting plugins are already loaded
# by Oh My Zsh, so their explicit sourcing is commented out to avoid duplication.
# source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ------------------------------------------------------------------------------
# ALIASES & CUSTOM COMMANDS
# Shortcuts and custom commands are defined below to speed up common tasks.

# Quick access to configuration files.
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"

# Clear screen and list directory contents.
alias cls="clear"
alias ll="ls -lah"

# Enable colorized grep output and define a system update command.
alias grep="grep --color=auto"
alias update="sudo apt update && sudo apt upgrade -y"

# Use nvim instead of vim.
alias vim="nvim"

# Git shortcuts for frequently used commands.
alias gs="git status"
alias gc="git commit -m"
alias gp="git push"
alias gco="git checkout"
alias gl="git log --oneline --graph --decorate"

# Navigation shortcuts to move up directories.
alias ..="cd .."
alias ...="cd ../.."

# Fast directory navigation is enabled via zoxide.
eval "$(zoxide init zsh)"

# Autojump is loaded if it is installed.
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh

# If available, bat is used as a drop-in replacement for cat.
if command -v bat &> /dev/null; then
  alias cat="bat"
fi

# ------------------------------------------------------------------------------
# CUSTOM FUNCTIONS
# The following functions are defined to provide additional utilities.

# mkcd: Create a directory and change into it immediately.
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# extract: Extract various types of archive files based on their extension.
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

# fzf-history-widget: Interactively search command history using fzf.
fzf-history-widget() {
  local selected_command
  selected_command=$(fc -l 1 | fzf --height 40% --reverse | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')
  LBUFFER="$selected_command"
  zle redisplay
}
# The widget is defined and bound to Ctrl+R.
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# ------------------------------------------------------------------------------
# ENVIRONMENT SETUP FOR LANGUAGES
# The following sections set up environment variables for Python and Node.js.

# pyenv is initialized for managing Python versions.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# NVM is initialized for managing Node.js versions.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# ------------------------------------------------------------------------------
# TMUX SESSION MANAGEMENT
# Aliases are provided to manage tmux sessions easily.
alias ta='tmux attach -t'        # Attach to an existing tmux session.
alias tls='tmux list-sessions'     # List all available tmux sessions.
alias tn='tmux new -s'            # Create a new tmux session.
alias tkill='tmux kill-session -t' # Kill a specified tmux session.

# ------------------------------------------------------------------------------
# QUALITY OF LIFE SETTINGS
# The following settings are used to improve overall shell performance and usability.
DISABLE_UNTRACKED_FILES_DIRTY="true"  # Prompts are sped up in large Git repositories.
DISABLE_AUTO_TITLE="true"             # Automatic terminal title updates are disabled.
DISABLE_MAGIC_FUNCTIONS="true"        # Magic functions are disabled to prevent issues with pasted code.

# ------------------------------------------------------------------------------
# ADDITIONAL QUALITY OF LIFE ENHANCEMENTS
# Additional aliases and functions are defined for convenience.

# Reload the zsh configuration without restarting the terminal.
alias reload="source ~/.zshrc"

# exa is used as a modern replacement for ls if installed.
if command -v exa &>/dev/null; then
  alias ls="exa --color=auto"
  alias ll="exa -lah --icons"
fi

# Disk usage summary is provided for the current directory.
alias duh="du -h --max-depth=1 | sort -hr"

# Graphical Git log overview is enabled.
alias gundo="git log --graph --oneline --decorate --all"

# A function is defined to clean up local Git branches that have been merged.
git-clean-branches() {
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
}

# Docker-related aliases are defined for container management.
alias dps="docker ps"            # List running Docker containers.
alias di="docker images"         # List Docker images.
alias drm="docker rm"            # Remove Docker containers.
alias drun="docker run -it --rm" # Run a Docker container interactively and remove it after exit.

# mkvenv: Create and activate a Python virtual environment quickly.
mkvenv() {
  if [ -z "$1" ]; then
    echo "Usage: mkvenv <env_name>"
  else
    python -m venv "$1" && source "$1/bin/activate"
  fi
}

# ff: Fuzzy file finder that opens a selected file in the editor.
ff() {
  local file
  file=$(find . -type f | fzf --height 40% --reverse --preview 'bat --style=numbers --color=always {}')
  if [ -n "$file" ]; then
    ${EDITOR:-vim} "$file"
  fi
}

# If htop is installed, it is aliased as 'top' for system monitoring.
if command -v htop &>/dev/null; then
  alias top="htop"
fi

# ipinfo alias is set to display public IP information.
alias ipinfo="curl ipinfo.io"

# If Cargo (Rust) is installed, its bin directory is added to the PATH.
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Command history is set to be appended and shared across sessions immediately.
setopt inc_append_history
setopt share_history

# preexec and precmd functions are defined to log execution time for commands that run longer than 5 seconds.
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

# ------------------------------------------------------------------------------
# ADDITIONAL DEVELOPER UTILITIES
# Additional utilities are provided below.

# If the 'z' tool is installed, it is initialized for fast directory navigation.
if command -v z &>/dev/null; then
  eval "$(z -i)"
fi

# gbf: An interactive Git branch switcher using fzf is defined.
gbf() {
  local branches branch
  branches=$(git branch --all | sed 's/^[* ]*//')
  branch=$(echo "$branches" | fzf --height 40% --reverse)
  if [ -n "$branch" ]; then
    git checkout "$(echo "$branch" | sed 's#remotes/[^/]*/##')"
  fi
}

# ssh_recent: Quickly SSH into a recent host from the known_hosts file.
ssh_recent() {
  awk '{print $1}' ~/.ssh/known_hosts | cut -d, -f1 | sort | uniq | fzf --height 40% --reverse | xargs -r ssh
}

# The Powerlevel10k configuration is loaded if the file exists.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The fzf configuration file is checked for and sourced if it exists.
# The following line has been commented out because it was causing the error:
# "unknown option: --zsh". This option may be unsupported by the current fzf version.
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

