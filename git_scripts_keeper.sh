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

# Repos where a git step failed. We keep going so one broken repo (e.g. a stale
# index.lock) does not block the others, but exit non-zero at the end so systemd
# marks the unit as failed instead of silently pretending everything was committed.
FAILED_REPOS=()
fail() {
  echo "Error: $1 in $REPO_PATH" >&2
  FAILED_REPOS+=("$REPO_PATH")
}

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
  cd "$REPO_PATH" || { fail "cd failed"; continue; }
  
  # Check if it's a git repository, initialize if --create-repos flag is set
  if [ ! -d ".git" ] && [ ! -f ".git" ]; then
    if [ "$CREATE_REPOS" = true ]; then
      # Check if .gitignore already exists (unexpected in non-git directory)
      if [ -f ".gitignore" ]; then
        echo "Error: Found .gitignore file in $REPO_PATH but no .git directory. This is unexpected."
        exit 1
      fi
      
      # Create .gitignore file with standard patterns
      echo "Creating .gitignore file in $REPO_PATH"
      cat > .gitignore << EOF
*.lock
*.log
EOF
      
      echo "Initializing git repository in $REPO_PATH"
      git init
    else
      echo "Error: $REPO_PATH is not a git repository. Use --create-repos to initialize it."
      exit 1
    fi
  fi
  
  # Check if there are changes
  # Capture separately: an erroring git status prints nothing, which would
  # otherwise be mistaken for "no changes".
  if ! STATUS=$(git status --porcelain --ignore-submodules); then
    fail "git status failed"
    continue
  fi
  if [ -z "$STATUS" ]; then
    echo "No changes to commit in $REPO_PATH"
    continue
  fi
  
  # Add all changes
  if ! git add .; then
    fail "git add failed"
    continue
  fi
  
  # Get list of modified files
  FILE_COUNT=$(git diff --cached --name-only | wc -l)
  MODIFIED_FILES=$(git diff --cached --name-only | head -20 | tr '\n' ' ')
  if [ "$FILE_COUNT" -gt 20 ]; then
    COMMIT_MSG="Auto-commit: $MODIFIED_FILES... ($FILE_COUNT files total)"
  else
    COMMIT_MSG="Auto-commit: $MODIFIED_FILES"
  fi

  # Commit with modified files as message
  if ! git commit -m "$COMMIT_MSG"; then
    fail "git commit failed"
    continue
  fi

  echo "Changes committed in $REPO_PATH"
done < "$REPO_LIST_FILE"

if [ ${#FAILED_REPOS[@]} -gt 0 ]; then
  echo "Error: ${#FAILED_REPOS[@]} repo(s) failed:" >&2
  printf '  %s\n' "${FAILED_REPOS[@]}" >&2
  exit 1
fi
