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
    echo "Usage: $0 <prompt>"
    echo "  prompt    Text prompt to send to the language model"
    echo ""
    echo "This script runs a prompt through the 'llm' CLI tool with system context."
    exit 1
}

# Check if llm is installed
check_dependencies() {
    if ! command -v llm &> /dev/null; then
        echo "Error: 'llm' command not found. Please install it before running this script."
        echo "Installation instructions: https://llm.datasette.io/en/stable/install.html"
        exit 2
    fi
}

# Main function
main() {
    # Display help if requested
    if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
        usage
    fi

    # Check for mandatory argument
    if [[ $# -lt 1 ]]; then
        echo "Error: Missing prompt argument"
        usage
    fi

    # Check dependencies
    check_dependencies

    # Run the llm command with the specified parameters
    llm -t cli -p user "$(echo $USER)" -p uname "$(uname -a)" "$1"
}

# Execute main with all arguments passed to the script
main "$@"
