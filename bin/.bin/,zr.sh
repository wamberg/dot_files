#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
  set -o xtrace
fi

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo "Usage: ./,zr.sh

\"Zettelkasten Random\"

Render a random note with \`glow\`.

"
    exit
fi

main() {
  find ~/dev/garden/ -maxdepth 1 -name "*.md" \
    | shuf -n 1 \
    | xargs glow
}

main "$@"

