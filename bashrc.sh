# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=50000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
#if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#    debian_chroot=$(cat /etc/debian_chroot)
#fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# if [ "$color_prompt" = yes ]; then
    # PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
    # PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir debian
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
#     ;;
# esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# ------------------- aliases --------------------- #
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias reload='source $HOME/.bashrc'
alias ncspot='flatpak run io.github.hrkfdn.ncspot'
alias ollama_stop='systemctl stop ollama'
alias ollama_start='systemctl start ollama'
alias img='chafa'
alias open='xdg-open'

# ============================================================================= #
#                                 FUNCTIONS                                     #
# ============================================================================= #

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# function to find a command like the input
find_command() {
    local cmd="$1"
    if command_exists "$cmd"; then
        echo "Command '$cmd' found in PATH."
    else
        echo "Searching for similar commands..."
        # Use 'compgen' to find similar commands
        compgen -c | grep -i "$cmd" | sort | uniq
    fi
}

# Function to check if a command is installed
is_installed() {
    if command_exists "$1"; then
        echo "$1 is installed."
    elif find_command "$1" | grep -q .; then
        echo "$1 there is no exact match, but similar commands found:"
        find_command "$1"
    else
        echo "$1 is not installed."
    fi
}

# Function to check if a package is installed using dpkg
# is_installed_dpkg() {
#     if dpkg -l | grep -q "^ii  $1 "; then
#         echo "$1 is installed."
#     else
#         echo "$1 is not installed."
#     fi
# }

replace_spaces_with_underscore() {
  local input_string="$*"
  local output_string="${input_string// /_}"
  echo "$output_string"
}

remove_accents() {
  local input_string="$*"
  local output_string=$(echo "$input_string" | iconv -f UTF-8 -t ASCII//TRANSLIT//IGNORE)
  echo "$output_string"
}

to_lowercase() {
  local input_string="$*"
  local output_string="${input_string,,}"
  echo "$output_string"
}


normalize_filenames() {
  local directory="${1:-.}" # Takes the first argument as the directory, or uses the current directory if none is provided
  local log_file="names_log.csv" # Name of the log file

  if [ ! -d "$directory" ]; then
    echo "Error: The directory '$directory' does not exist."
    return 1
  fi

  echo "Normalizing filenames in: $directory"
  echo "Logging changes to: $log_file"

  # Create or truncate the log file and add the header
  echo "Original Name,Normalized Name" > "$log_file"

  # Use 'find' to safely handle filenames with spaces and special characters.
  # -maxdepth 1 ensures only files in the specified directory (not subdirectories) are processed.
  # -print0 for filenames with spaces or special characters.
  find "$directory" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' original_file_path; do
    # Extract the base filename (without the directory path)
    local original_filename=$(basename "$original_file_path")
    local file_directory=$(dirname "$original_file_path")
    local normalized_filename="$original_filename"

    # Apply normalization functions in sequence
    normalized_filename=$(replace_spaces_with_underscore "$normalized_filename")
    normalized_filename=$(remove_accents "$normalized_filename")
    normalized_filename=$(to_lowercase "$normalized_filename")

    # Log to the CSV, escaping commas in names if necessary (for simple CSV)
    # For names with internal commas, ideally you'd use double quotes, but for simplicity, we'll replace with underscores.
    local log_original_name="${original_filename//,/_}"
    local log_normalized_name="${normalized_filename//,/_}"
    echo "$log_original_name,$log_normalized_name" >> "$log_file"

    # Check if the name has changed
    if [ "$original_filename" != "$normalized_filename" ]; then
      local new_file_path="$file_directory/$normalized_filename"

      # Check if the new filename already exists to avoid accidental overwrites
      if [ -e "$new_file_path" ]; then
        echo "Warning: File '$new_file_path' already exists. Skipping rename of '$original_filename'."
      else
        echo "Renaming: '$original_filename' -> '$normalized_filename'"
        mv -v "$original_file_path" "$new_file_path"
      fi
    fi
  done

  echo "Normalization complete."
}

parse_git_branch() {
  # Verifica se o comando git existe antes de tudo
  command -v git >/dev/null 2>&1 || return

  # Se estiver em um repositório git, mostra o branch. Caso contrário, não mostra nada.
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo "git:$(git symbolic-ref --short HEAD)"
}

# Set the prompt to show user, host, current directory, and git branch if available
PS1=" \[\e[38;5;153m\]\u\[\e[m\] at \[\e[38;5;150m\]\h\[\e[m\] in \[\e[38;5;214m\]\w\[\e[m\] \033[0;91m\$(parse_git_branch)\[\e[m\]\n "
