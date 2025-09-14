#!/usr/bin/env bash
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
    --exclude .cache \
    --exclude .venv \
    --exclude Downloads \
    --exclude mise \
    --exclude node_modules \
    --exclude snap \
    --exclude "VirtualBox VMs" \
    --exclude Videos \
    --directory="$HOME" \
    . \
    | ssh "$SSH_USERNAME@$SSH_HOST" \
      "cat > ~/backups/freya/freya-backup-$TIMESTAMP.tar.gz" \
    2>&1 | tee "/tmp/freya-backup-log-$TIMESTAMP.txt"
}

arrange "$1" "$2"
act
