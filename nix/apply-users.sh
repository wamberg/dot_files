#!/bin/sh
pushd ~/dev/dot_files/nix
nix build .#homeManagerConfigurations.wamberg.activationPackage
./result/activate
popd
