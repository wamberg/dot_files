# Personal Config

## Installation Guide

1. Install NixOS, following the UEFI instructions,
   [here](https://nixos.org/manual/nixos/stable/index.html#ch-installation)
2. Reboot and copy this repo onto the fresh installation
3. [Enable nix flakes](https://nixos.wiki/wiki/Flakes#System-wide_installation)
4. Install `stow`
5. Use `stow` to install all the configurations that you want to use:
   `stow --dir="${HOME}/dev/dot_files" --target="${HOME}/" --verbose=2 -RS <package>`
6. Update the system with ./nix/apply-system.sh
7. Update the user configuration with ./nix/apply-system.sh

### mkcert

`mkcert install` does not go smoothly on NixOS. The command displays an error
along the lines of "not supported on your system." After running
`mkcert -install`, I need to manually import the Certificate Authority into
Chrome. Under Chrome settings, go to Privacy and security -> Manage Certificates
-> Authorites tab. Click the "Import" button and import
~/.local/share/mkcert/rootCA.pem.
