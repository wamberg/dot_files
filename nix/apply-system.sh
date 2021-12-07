#!/bin/sh
pushd ~/dev/dot_files/nix
sudo nixos-rebuild switch --flake .#
popd
