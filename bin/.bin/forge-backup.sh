#!/usr/bin/env bash
# Backup script for NixOS machine (forge)
#
# Explicitly backs up only essential user data:
# - AWS credentials (.aws/)
# - Development projects (dev/) - keeps .git, excludes build artifacts
# - Documents and calibre library (docs/)
# - Pictures and wallpapers (pics/)
# - Videos (videos/)
#
# Everything else (dotfiles, configs, system state) is managed by:
# - Stow dotfiles in ~/dev/dot_files
#
# Usage: forge-backup.sh <ssh_username> <ssh_host>

set -euxo pipefail
IFS=$'\n\t'

function arrange() {
  : "${1:?"SSH username required"}"
  : "${2:?"SSH host required"}"
  SSH_USERNAME=$1
  SSH_HOST=$2
  TIMESTAMP="$(date +%Y-%m-%dT%H%M%z)"
}

# SC2029: $TIMESTAMP is intentionally expanded client-side
# shellcheck disable=SC2029
function act() {
  tar \
    --create \
    --use-compress-program="pigz -9" \
    --verbose \
    --exclude-caches-all \
    \
    `# Development build artifacts and caches` \
    --exclude "**/node_modules" \
    --exclude "**/.venv" \
    --exclude "**/venv" \
    --exclude "**/__pycache__" \
    --exclude "**/.pytest_cache" \
    --exclude "**/target/debug" \
    --exclude "**/target/release" \
    --exclude "**/.next" \
    --exclude "**/.nuxt" \
    --exclude "**/dist" \
    --exclude "**/build" \
    --exclude "**/.cache" \
    \
    `# Editor and tool temporary files` \
    --exclude "**/*.swp" \
    --exclude "**/*.tmp" \
    --exclude "**/*~" \
    --exclude "**/.DS_Store" \
    \
    --directory="$HOME" \
    .aws \
    dev \
    docs \
    pics \
    videos \
    | ssh "$SSH_USERNAME@$SSH_HOST" \
      "cat > ~/backups/forge/forge-backup-${TIMESTAMP}.tar.gz" \
    2>&1 | tee "/tmp/forge-backup-log-$TIMESTAMP.txt"
}

arrange "$1" "$2"
act
