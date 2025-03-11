# Git Script Keeper

A simple bash utility that automatically commits changes in multiple git repositories.

## Description

Git Script Keeper is a bash script that helps you manage multiple git repositories by automatically detecting changes and committing them. It reads a list of repository paths from a file and processes each repository, committing any changes with an auto-generated commit message.

## Features

- Automatically detects changes in multiple git repositories
- Skips repositories with no changes
- Generates commit messages that include the list of modified files
- Handles errors gracefully (non-existent directories, non-git repositories)
- Supports comments and empty lines in the repository list file

## Usage

```bash
./git_script_keeper.sh <path_to_repo_list_file>
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

1. Download the script:
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/git-script-keeper/main/git_script_keeper.sh
   ```

2. Make it executable:
   ```bash
   chmod +x git_script_keeper.sh
   ```

3. Create a repository list file with one repository path per line.

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
