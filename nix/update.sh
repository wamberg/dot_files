#!/bin/sh
pushd ~/dev/dot_files/nix
nix flake update
popd
