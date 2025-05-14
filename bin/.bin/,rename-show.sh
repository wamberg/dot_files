#!/usr/bin/env bash

# Set safe options for better script execution
set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

# Function to display help
usage() {
    echo "Usage: $0 <file path> <output directory> [prefix] [suffix]"
    echo "  file path        : Path to the file you wish to rename"
    echo "  output directory : Directory where renamed file should be moved"
    echo "  prefix           : Optional prefix added before the episode identifier"
    echo "  suffix           : Optional suffix added after the episode identifier"
    exit 1
}

# Display help if requested
if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    usage
fi

# Check mandatory arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Assign arguments
file_path="$1"
output_directory="$2"
prefix="${3:-}"
suffix="${4:-}"

# Check if the file exists
if [[ ! -f "$file_path" ]]; then
    echo "Error: File does not exist: $file_path"
    exit 1
fi

# Extract episode identifier with regex - Handle upper and lower case
if [[ "$file_path" =~ ([sS][0-9]{2}[eE][0-9]{2}) ]]; then
    episode_id="${BASH_REMATCH[1]}"
    episode_id=$(echo "$episode_id" | tr '[:upper:]' '[:lower:]') # Normalize to lower case

    new_file_name="${prefix}${episode_id}${suffix}.mkv"
    output_file_path="${output_directory%/}/${new_file_name}" # Ensure no double slash errors

    # Move and rename file
    mv "$file_path" "$output_file_path"
    echo "File moved and renamed to: $output_file_path"
else
    echo "Error: The file name does not contain a standard episode identifier (e.g., S01E01)."
    exit 1
fi
