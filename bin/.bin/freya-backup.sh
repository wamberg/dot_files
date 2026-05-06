#!/usr/bin/env bash
# Backup script for Arch Linux laptop (freya)
#
# Explicitly backs up only essential machine-local state:
# - Claude Code inline plugin data (.claude/plugins/data/)
#
# Everything else (dotfiles, configs, system state) is managed by:
# - Arch + Ansible (declarative system state in dev/dot_files/ops/arch)
# - Stow dotfiles in ~/dev/dot_files
#
# Usage: freya-backup.sh <ssh_username> <ssh_host>

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
    --directory="$HOME" \
    .claude/plugins/data \
    | ssh "$SSH_USERNAME@$SSH_HOST" \
      "cat > ~/backups/freya/freya-backup-${TIMESTAMP}.tar.gz" \
    2>&1 | tee "/tmp/freya-backup-log-$TIMESTAMP.txt"
}

arrange "$1" "$2"
act
