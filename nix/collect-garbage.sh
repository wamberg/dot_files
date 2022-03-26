#!/bin/sh
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
sudo nix-collect-garbage -d
