
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

# ============================================================================= #
#                           ADDITIONAL UTILITY FUNCTIONS                       #
# ============================================================================= #

# Create directory and cd into it
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory_name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive_file>"
        return 1
    fi
    
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.xz)        unxz "$1"        ;;
            *.lzma)      unlzma "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files by name
ff() {
    if [ -z "$1" ]; then
        echo "Usage: ff <filename_pattern>"
        return 1
    fi
    find . -type f -name "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    if [ -z "$1" ]; then
        echo "Usage: fd <directory_pattern>"
        return 1
    fi
    find . -type d -name "*$1*" 2>/dev/null
}

# Quick search in files
search() {
    if [ -z "$1" ]; then
        echo "Usage: search <search_term> [directory]"
        return 1
    fi
    
    local search_dir="${2:-.}"
    grep -r "$1" "$search_dir" --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.vscode --exclude-dir=__pycache__ 2>/dev/null
}

# Show disk usage of current directory
usage() {
    local target_dir="${1:-.}"
    if [ -d "$target_dir" ]; then
        du -sh "$target_dir"/* 2>/dev/null | sort -hr
    else
        echo "Directory '$target_dir' not found"
    fi
}

# Process management - find processes by name
psg() {
    if [ -z "$1" ]; then
        echo "Usage: psg <process_name>"
        return 1
    fi
    ps aux | grep -v grep | grep "$1"
}

# Weather function
weather() {
    local city="${1:-}"
    if command_exists curl; then
        curl -s "wttr.in/${city}?format=3"
    else
        echo "curl is required for weather function"
    fi
}

# Backup function
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file_or_directory>"
        return 1
    fi
    
    if [ -e "$1" ]; then
        local backup_name="$1.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$1" "$backup_name"
        echo "Backup created: $backup_name"
    else
        echo "File or directory not found: $1"
    fi
}

# Show system information
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    
    if command_exists free; then
        echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    fi
    
    if command_exists df; then
        echo "Disk Usage:"
        df -h | grep -E '^/dev/' | awk '{print "  " $1 ": " $3 "/" $2 " (" $5 ")"}'
    fi
}

# Network information
netinfo() {
    echo "=== Network Information ==="
    
    # Public IP
    if command_exists curl; then
        echo "Public IP: $(curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch")"
    fi
    
    # Local IPs
    echo "Local IPs:"
    if command_exists ip; then
        ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print "  " $2}' | cut -d'/' -f1
    elif command_exists ifconfig; then
        ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print "  " $2}'
    fi
    
    # Active connections
    if command_exists netstat; then
        echo "Active connections: $(netstat -an | grep ESTABLISHED | wc -l)"
    fi
}

# Quick file server
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"
    
    if [ ! -d "$directory" ]; then
        echo "Directory '$directory' not found"
        return 1
    fi
    
    echo "Starting HTTP server on port $port in directory: $directory"
    echo "Access at: http://localhost:$port"
    
    if command_exists python3; then
        cd "$directory" && python3 -m http.server "$port"
    elif command_exists python; then
        cd "$directory" && python -m SimpleHTTPServer "$port"
    else
        echo "Python is required for serve function"
    fi
}

# Generate random password
genpass() {
    local length="${1:-16}"
    if command_exists openssl; then
        openssl rand -base64 "$length" | cut -c1-"$length"
    elif [ -f /dev/urandom ]; then
        tr -dc 'A-Za-z0-9!@#$%^&*()_+=' < /dev/urandom | head -c "$length"; echo
    else
        echo "Unable to generate password - openssl or /dev/urandom required"
    fi
}

# Calculate file/directory size
sizeof() {
    if [ -z "$1" ]; then
        echo "Usage: sizeof <file_or_directory>"
        return 1
    fi
    
    if [ -e "$1" ]; then
        du -sh "$1"
    else
        echo "File or directory not found: $1"
    fi
}

# Quick note taking
note() {
    local note_file="$HOME/.notes"
    
    if [ -z "$1" ]; then
        # Show existing notes
        if [ -f "$note_file" ]; then
            echo "=== Your Notes ==="
            cat "$note_file"
        else
            echo "No notes found. Use 'note <text>' to add a note."
        fi
    else
        # Add new note with timestamp
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$note_file"
        echo "Note added!"
    fi
}

# Clear notes
clearnotes() {
    local note_file="$HOME/.notes"
    if [ -f "$note_file" ]; then
        rm "$note_file"
        echo "Notes cleared!"
    else
        echo "No notes to clear."
    fi
}
