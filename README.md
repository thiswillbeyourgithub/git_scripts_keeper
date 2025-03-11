# Git Scripts Keeper

A simple bash utility that automatically commits changes in multiple git repositories.

## Description

Git Script Keeper is a bash script that helps you manage multiple git repositories by automatically detecting changes and committing them. It reads a list of repository paths from a file and processes each repository, committing any changes with an auto-generated commit message.

Inspired by etckeeper, Git Script Keeper was created to track changes in scripts and configuration folders that aren't covered by system configuration management tools.

## Features

- Automatically detects changes in multiple git repositories
- Skips repositories with no changes
- Generates commit messages that include the list of modified files
- Handles errors gracefully (non-existent directories, non-git repositories)
- Supports comments and empty lines in the repository list file

## Usage

```bash
./git_scripts_keeper.sh <path_to_repo_list_file>
```

### Example repository list file (repos.txt):
```
# My repositories
/home/user/projects/project1
/home/user/projects/project2
# This one is commented out
# /home/user/projects/inactive-project
/home/user/projects/project3
```

### Options

- `-h, --help`: Display help message and exit

## Requirements

- Bash shell
- Git

## Installation

1. Download this script via `git clone`
2. Make it executable: `chmod +x git_scripts_keeper.sh`
3. Create a repository list file with one repository path per line into `repos.txt`.
4. Launch via `./git_scripts_keeper.sh repos.txt`
5. Optional: make it periodic via the systemd unit.
