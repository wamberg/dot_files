#!/usr/bin/env bash
# Backup script for Arch Linux machine managed by Ansible
#
# Backs up important user data while excluding:
# - System caches and rebuilable content
# - Development tool caches (managed by mise/package managers)
# - Browser temporary data (configs preserved in dotfiles)
# - Virtualization data and container volumes
# - Editor temporary files
#
# Critical data backed up includes:
# - All development projects (dev/)
# - Documents and calibre library (docs/)
# - Pictures and wallpapers (pics/)
# - SSH keys, GPG keys, password store
# - Stowed dotfiles configuration
#
# Usage: forge-backup.sh <ssh_username> <ssh_host>

set -euxo pipefail
IFS=$'\n\t'

function arrange() {
  : "${1:?"SSH username required"}"
  : "${2:?"SSH host required"}"
  SSH_USERNAME=$1
  SSH_HOST=$2
  TIMESTAMP="$(date -Iminutes)"
}

function act() {
  tar \
    --create \
    --use-compress-program="pigz -9" \
    --verbose \
    --exclude-caches-all \
    \
    `# one-off, special excludes` \
    --exclude .oh-my-zsh \
    --exclude Downloads \
    --exclude videos \
    \
    `# System caches and temporary files` \
    --exclude .ansible \
    --exclude .cache \
    --exclude .telegram-unread \
    --exclude .zoom \
    \
    `# Development tool caches (can be rebuilt via mise/package managers)` \
    --exclude .cargo/git \
    --exclude .cargo/registry \
    --exclude .npm \
    --exclude .rustup \
    --exclude .venv \
    --exclude mise \
    --exclude node_modules \
    \
    `# Browser data (except essential configs already in dotfiles)` \
    --exclude .mozilla/firefox/*/OfflineCache \
    --exclude .mozilla/firefox/*/cache2 \
    --exclude .mozilla/firefox/*/storage \
    --exclude .mozilla/firefox/*/thumbnails \
    \
    `# Virtualization and snaps` \
    --exclude "VirtualBox VMs" \
    --exclude .docker/containers \
    --exclude .docker/volumes \
    --exclude snap \
    \
    `# IDE and editor temporary files` \
    --exclude "*.swp" \
    --exclude "*.tmp" \
    --exclude "*~" \
    \
    --directory="$HOME" \
    . \
    | ssh "$SSH_USERNAME@$SSH_HOST" \
      "cat > ~/backups/forge/forge-backup-$TIMESTAMP.tar.gz" \
    2>&1 | tee "/tmp/forge-backup-log-$TIMESTAMP.txt"
}

arrange "$1" "$2"
act
