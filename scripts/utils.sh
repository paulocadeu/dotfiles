
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
