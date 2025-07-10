#!/bin/bash

# Git utility functions for enhanced workflow

# Function to open current repository/file in GitHub
open_github() {
    local file="$1"
    local remote="${2:-origin}"
    local line_number="$3"
    
    # Validate we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    # Get git information
    local git_root
    local branch
    local remote_url
    
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    remote_url=$(git config --get "remote.$remote.url" 2>/dev/null)
    
    # Validate required information
    if [[ -z "$git_root" || -z "$branch" || -z "$remote_url" ]]; then
        echo "Error: Could not retrieve git information (root: $git_root, branch: $branch, remote: $remote_url)" >&2
        return 1
    fi
    
    # Construct relative path
    local relative_path="${PWD/#$git_root/}"
    [[ -n "$file" ]] && relative_path="${relative_path}/${file}"
    
    # Parse repository information from URL
    local github_url
    github_url=$(parse_git_url "$remote_url" "$branch" "$relative_path" "$line_number")
    
    if [[ -z "$github_url" ]]; then
        echo "Error: Could not parse GitHub URL from remote: $remote_url" >&2
        return 1
    fi
    
    echo "Opening: $github_url"
    open_url "$github_url"
}

# Function to parse git URL and construct GitHub URL
parse_git_url() {
    local url="$1"
    local branch="$2"
    local path="$3"
    local line_number="$4"
    
    local user repo
    
    # Handle different URL formats
    if [[ "$url" =~ ^git@github\.com:(.+)/(.+)\.git$ ]]; then
        # SSH format: git@github.com:user/repo.git
        user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$url" =~ ^https://github\.com/(.+)/(.+)\.git$ ]]; then
        # HTTPS format: https://github.com/user/repo.git
        user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    elif [[ "$url" =~ ^https://github\.com/(.+)/(.+)$ ]]; then
        # HTTPS format without .git: https://github.com/user/repo
        user="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    else
        return 1
    fi
    
    # Construct GitHub URL
    local github_url="https://github.com/$user/$repo/tree/$branch$path"
    
    # Add line number if specified and it's a file
    if [[ -n "$line_number" && -n "$3" && "$3" != "/" ]]; then
        github_url="${github_url}#L${line_number}"
    fi
    
    echo "$github_url"
}

# Cross-platform URL opener
open_url() {
    local url="$1"
    
    case "$(uname -s)" in
        Darwin)
            open "$url"
            ;;
        Linux)
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$url"
            elif command -v firefox >/dev/null 2>&1; then
                firefox "$url" &
            elif command -v google-chrome >/dev/null 2>&1; then
                google-chrome "$url" &
            else
                echo "Error: No suitable browser opener found" >&2
                echo "URL: $url"
                return 1
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            start "$url"
            ;;
        *)
            echo "Error: Unsupported operating system" >&2
            echo "URL: $url"
            return 1
            ;;
    esac
}

# Function to get current git status with colors
git_status_enhanced() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Not in a git repository"
        return 1
    fi
    
    echo "Repository: $(basename "$(git rev-parse --show-toplevel)")"
    echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "Remote: $(git config --get remote.origin.url)"
    echo ""
    git status --short --branch
}

# Function to create and switch to a new branch
git_new_branch() {
    local branch_name="$1"
    
    if [[ -z "$branch_name" ]]; then
        echo "Usage: git_new_branch <branch-name>" >&2
        return 1
    fi
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    echo "Creating and switching to branch: $branch_name"
    git checkout -b "$branch_name"
}

# Function to safely delete a branch
git_delete_branch() {
    local branch_name="$1"
    local force="${2:-false}"
    
    if [[ -z "$branch_name" ]]; then
        echo "Usage: git_delete_branch <branch-name> [force]" >&2
        return 1
    fi
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    if [[ "$current_branch" == "$branch_name" ]]; then
        echo "Error: Cannot delete current branch. Switch to another branch first." >&2
        return 1
    fi
    
    if [[ "$force" == "true" ]]; then
        git branch -D "$branch_name"
    else
        git branch -d "$branch_name"
    fi
}

# Aliases for convenience
alias gh='open_github'
alias gst='git_status_enhanced'
alias gnb='git_new_branch'
alias gdb='git_delete_branch'