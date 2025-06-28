#!/bin/bash

# Function to display help message
show_help() {
  echo "Usage: $0 [--create-repos] <path_to_repo_list_file>"
  echo
  echo "Automatically commits changes in git repositories listed in the specified file."
  echo
  echo "Options:"
  echo "  -h, --help       Display this help message and exit"
  echo "  --create-repos   Initialize git repositories if .git directory is missing"
  echo
  echo "The repo list file should contain one repository path per line."
  echo "Empty lines and lines starting with # are ignored."
  exit 0
}

# Initialize variables
CREATE_REPOS=false
REPO_LIST_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    --create-repos)
      CREATE_REPOS=true
      shift
      ;;
    *)
      if [ -z "$REPO_LIST_FILE" ]; then
        REPO_LIST_FILE="$1"
        shift
      else
        echo "Error: Too many arguments"
        echo "Use '$0 --help' for more information."
        exit 1
      fi
      ;;
  esac
done

# Check if a file path is provided
if [ -z "$REPO_LIST_FILE" ]; then
  echo "Usage: $0 [--create-repos] <path_to_repo_list_file>"
  echo "Use '$0 --help' for more information."
  exit 1
fi

# Check if the file exists
if [ ! -f "$REPO_LIST_FILE" ]; then
  echo "Error: File $REPO_LIST_FILE does not exist"
  exit 1
fi

# Read repositories from the file
while IFS= read -r REPO_PATH || [ -n "$REPO_PATH" ]; do
  # Skip empty lines and comments
  [[ -z "$REPO_PATH" || "$REPO_PATH" =~ ^[[:space:]]*# ]] && continue
  
  echo "Processing repository: $REPO_PATH"
  
  # Check if directory exists
  if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Directory $REPO_PATH does not exist"
    exit 1
  fi
  
  # Change to repository directory
  cd "$REPO_PATH" || continue
  
  # Check if it's a git repository, initialize if --create-repos flag is set
  if [ ! -d ".git" ]; then
    if [ "$CREATE_REPOS" = true ]; then
      echo "Initializing git repository in $REPO_PATH"
      git init
    else
      echo "Error: $REPO_PATH is not a git repository. Use --create-repos to initialize it."
      exit 1
    fi
  fi
  
  # Check if there are changes
  if [ -z "$(git status --porcelain --ignore-submodules)" ]; then
    echo "No changes to commit in $REPO_PATH"
    continue
  fi
  
  # Add all changes
  git add .
  
  # Get list of modified files
  MODIFIED_FILES=$(git diff --cached --name-only | tr '\n' ' ')
  
  # Commit with modified files as message
  git commit -m "Auto-commit: $MODIFIED_FILES"
  
  echo "Changes committed in $REPO_PATH"
done < "$REPO_LIST_FILE"
