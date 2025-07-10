# 🏠 Dotfiles

Personal configuration files and utility scripts for enhanced development workflow on Linux systems.

## 📁 Project Structure

```
dotfiles/
├── bashrc.sh                    # Enhanced Bash configuration
├── scripts/
│   ├── git.sh                   # Git utilities and GitHub integration
│   ├── docker.sh                # Docker management functions
│   ├── prompt.sh                # Custom shell prompt documentation
│   ├── utils.sh                 # General utility functions
│   └── colors_terminal/         # Terminal color schemes and utilities
│       ├── extended_colors.sh   # Extended color palette
│       ├── terminal_color_support.sh  # Color support detection
│       └── true_colors.sh       # True color (24-bit) support
├── LICENSE                      # MIT License
└── README.md                    # This file
```

## 🚀 Features Overview

### 🔧 Enhanced Bash Configuration (`bashrc.sh`)
- **Advanced history management** with timestamps and deduplication
- **Comprehensive shell options** for better user experience
- **Smart PATH management** with automatic detection of development tools
- **Extensive alias collection** for productivity
- **Modular script loading** with error handling
- **Cross-platform compatibility** considerations

### 🌿 Git Integration (`scripts/git.sh`)
Advanced Git workflow with GitHub integration:

#### Core Functions
- **`open_github [file] [remote] [line]`** - Open repository/file in browser
  - Cross-platform support (macOS, Linux, Windows)
  - Multiple Git URL formats (SSH/HTTPS)
  - Line number highlighting
  - Smart path resolution

- **`git_status_enhanced`** - Enhanced status with repository info
- **`git_new_branch <name>`** - Create and switch to new branch
- **`git_delete_branch <name> [force]`** - Safe branch deletion

#### Convenient Aliases
- `gh` → `open_github`
- `gst` → `git_status_enhanced`
- `gnb` → `git_new_branch`
- `gdb` → `git_delete_branch`

### 🐳 Docker Management (`scripts/docker.sh`)
Comprehensive Docker workflow automation:

#### Container Management
- **Container lifecycle operations** (start, stop, restart, remove)
- **Bulk operations** with confirmation prompts
- **Container inspection** and logging utilities
- **Health monitoring** and status reporting

#### Image Management
- **Image cleanup** and optimization
- **Registry operations** (push, pull, tag)
- **Build automation** with caching strategies
- **Dangling image removal**

#### System Utilities
- **Docker system cleanup** (prune containers, images, volumes)
- **Resource monitoring** (disk usage, memory consumption)
- **Network management** utilities
- **Volume operations** and backup functions

### 🛠 Utility Functions (`scripts/utils.sh`)
Essential development and system utilities:

#### File Operations
- **`mkcd <dir>`** - Create directory and navigate to it
- **`extract <file>`** - Universal archive extractor (supports 10+ formats)
- **`backup <file>`** - Create timestamped backups
- **`sizeof <path>`** - Show file/directory size

#### Search and Navigation
- **`ff <pattern>`** - Find files by name
- **`fd <pattern>`** - Find directories by name
- **`search <term> [dir]`** - Search content in files (excludes common dirs)

#### System Information
- **`sysinfo`** - Comprehensive system information
- **`netinfo`** - Network configuration and status
- **`usage [dir]`** - Disk usage analysis
- **`psg <process>`** - Process search and monitoring

#### Development Tools
- **`serve [port] [dir]`** - Quick HTTP server
- **`weather [city]`** - Weather information
- **`genpass [length]`** - Secure password generator
- **`note <text>`** / `clearnotes`** - Quick note-taking system

#### Text Processing
- **`normalize_filenames [dir]`** - Normalize filenames (spaces, accents, case)
- **`replace_spaces_with_underscore`** - Text transformation
- **`remove_accents`** - Remove accented characters
- **`to_lowercase`** - Convert to lowercase

### 🎨 Terminal Customization (`scripts/colors_terminal/`)
Advanced terminal appearance and color management:

#### Color Support Detection
- **Terminal capability detection** (8-bit, 256-color, true color)
- **Automatic fallback** for limited terminals
- **Color scheme validation** and testing

#### Color Palettes
- **Extended 256-color palette** with organized categories
- **True color (24-bit) support** with RGB utilities
- **Theme management** and switching capabilities
- **Custom color definitions** for consistent branding

### 📝 Prompt Customization (`scripts/prompt.sh`)
Documentation and examples for custom shell prompts:

- **Git integration** with branch and status information
- **Multi-line layouts** for better readability
- **Color coding** for different prompt elements
- **Performance optimization** for large repositories

## 🔧 Installation

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/paulocadeu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Backup existing bashrc (optional)
cp ~/.bashrc ~/.bashrc.backup

# Link or source the configuration
echo "source ~/dotfiles/bashrc.sh" >> ~/.bashrc

# Reload your shell
source ~/.bashrc
```

### Manual Integration
```bash
# Source individual scripts as needed
source ~/dotfiles/scripts/git.sh
source ~/dotfiles/scripts/docker.sh
source ~/dotfiles/scripts/utils.sh
```

## 📋 Requirements

### Core Requirements
- **Bash 4.0+** (for advanced features)
- **Git** (for Git integration functions)
- **Basic Unix tools** (find, grep, awk, sed)

### Optional Dependencies
- **Docker** (for Docker management functions)
- **curl** (for weather and network functions)
- **Python 3** (for HTTP server functionality)
- **xdg-open/open** (for cross-platform file opening)


## 🎯 Usage Examples

### Git Workflow
```bash
# Open current repository in GitHub
gh

# Open specific file at line 42
gh src/main.js origin 42

# Enhanced git status
gst

# Create feature branch
gnb feature/awesome-feature

# Clean up old branch
gdb feature/old-feature
```

### Docker Operations
```bash
# Container management
docker_start my-container
docker_logs my-container
docker_cleanup

# System maintenance
docker_system_prune
docker_remove_dangling
```

### Utility Functions
```bash
# File operations
mkcd new-project
extract archive.tar.gz
backup important-file.txt

# Search operations
ff "*.js"
search "TODO" src/
psg nginx

# System information
sysinfo
netinfo
weather goiânia
