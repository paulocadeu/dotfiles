#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# Enhanced configuration for development workflow

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ========================== IMPORT CUSTOM SCRIPTS ======================= #
# Function to safely source files
safe_source() {
    if [ -f "$1" ]; then
        source "$1"
        return 0
    else
        echo "Warning: $1 not found" >&2
        return 1
    fi
}

# Import utility functions (must be first for other scripts to use them)
safe_source "$HOME/dotfiles/scripts/utils.sh"

# Import Git management functions
safe_source "$HOME/dotfiles/scripts/git.sh"

# Import Docker management functions
safe_source "$HOME/dotfiles/scripts/docker.sh"

# Import Prompt customization
safe_source "$HOME/dotfiles/scripts/prompt.sh"



# ========================== HISTORY CONFIGURATION =========================== #
# Enhanced history settings for better command tracking
HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and lines starting with space
HISTSIZE=10000                    # Commands in memory
HISTFILESIZE=50000               # Commands in history file
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "  # Add timestamps to history

# Append to history file, don't overwrite
shopt -s histappend

# Save multi-line commands as single entry
shopt -s cmdhist

# Save history immediately after each command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# ========================== SHELL OPTIONS ================================== #
# Check window size after each command
shopt -s checkwinsize

# Enable extended globbing patterns
shopt -s extglob

# Enable recursive globbing with **
shopt -s globstar

# Correct minor spelling errors in directory names
shopt -s cdspell

# Correct minor spelling errors in arguments to cd
shopt -s dirspell

# Case-insensitive pathname expansion
shopt -s nocaseglob

# ========================== ENVIRONMENT VARIABLES ========================== #
# Default editor
export EDITOR=vim
export VISUAL=vim

# Less configuration for better paging
export LESS='-R -i -M -S -x4'
export LESSHISTFILE=-

# Colored man pages
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# User specific PATH
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Add common development paths if they exist
[[ -d "$HOME/.cargo/bin" ]] && PATH="$HOME/.cargo/bin:$PATH"
[[ -d "$HOME/go/bin" ]] && PATH="$HOME/go/bin:$PATH"
[[ -d "$HOME/.npm-global/bin" ]] && PATH="$HOME/.npm-global/bin:$PATH"

export PATH

# ========================== TERMINAL COLORS ================================= #
# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# ========================== COMPLETION =================================== #
# Enable programmable completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ========================== ALIASES ====================================== #
# Enhanced ls aliases
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lAh --group-directories-first --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lAht'  # Sort by time
alias lz='ls -lAhS'  # Sort by size

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Grep with colors
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System aliases
alias reload='source $HOME/.bashrc && echo "Bashrc reloaded!"'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# File operations
alias open='xdg-open'
alias img='chafa'
alias tree='tree -C'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Network
alias ping='ping -c 5'
alias ports='netstat -tulanp'
alias myip='curl -s ifconfig.me'

# Development aliases
alias py='python3'
alias pip='pip3'
alias serve='python3 -m http.server'
alias json='python3 -m json.tool'

# Application specific
alias ncspot='flatpak run io.github.hrkfdn.ncspot'
alias ollama_stop='systemctl stop ollama'
alias ollama_start='systemctl start ollama'
alias vim='vim'

# ========================== WELCOME MESSAGE ============================= #
# Show system info on login (only for interactive shells)
if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
    echo " Welcome to $(hostname)!"
    echo " $(date '+%A, %d de %B de %Y')"
    echo " $(date '+%H:%M:%S'), Uptime: $(uptime -p)"
    echo ""
fi

# ========================== FINAL SETUP ================================== #
# Set terminal title
case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"; '"$PROMPT_COMMAND"
        ;;
esac

GIT_PROMPT="\033[0;91m\$(parse_git_branch)\[\e[m\]"
PS1="\[\e[38;5;153m\]\u\[\e[m\] at \[\e[38;5;150m\]\h\[\e[m\] in \[\e[38;5;214m\]\w\[\e[m\] $GIT_PROMPT\n\[\e[38;5;39m\]\$ \[\e[m\]"
