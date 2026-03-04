# AGENTS.md

This file tracks active friction. Fix items here, then remove them.

## calibre pinned to nixos-stable

calibre is broken on nixos-unstable (qt6 qmake missing during build).
Tracking: https://github.com/NixOS/nixpkgs/issues/493843

Currently installed from `nixpkgs-stable` (nixos-25.05) input in `ops/nix/flake.nix`.
When the upstream issue is resolved:

1. Remove the `nixpkgs-stable` input from `ops/nix/flake.nix`
2. Remove `pkgs-stable` from `flake.nix` outputs, `configuration.nix` args, and `home-manager.extraSpecialArgs`
3. Change `pkgs-stable.calibre` back to `calibre` in `ops/nix/hosts/forge/home.nix`
4. Remove this section