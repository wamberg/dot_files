#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./,update-ubuntu.sh

Run incantations that update Ubuntu packages

'
    exit
fi

main() {
  # Update apt packages
  sudo apt update
  sudo apt upgrade

  # Update snap packages
  killall snap-store # Avoid "close the app to avoid disruption"
  sudo snap refresh
}

main "$@"


