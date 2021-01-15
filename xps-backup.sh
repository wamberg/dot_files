#!/bin/env bash
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
  rsync \
    --archive \
    --verbose \
    --human-readable \
    --rsh=ssh \
    --exclude .asdf \
    --exclude .cache \
    --exclude Downloads \
    --exclude node_modules \
    --exclude snap \
    ~/ \
    "$SSH_USERNAME@$SSH_HOST:~/backups/xps/$TIMESTAMP/" \
    | tee "/tmp/log-$TIMESTAMP.txt"
}

arrange "$1" "$2"
act
