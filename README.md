# Workstation Configuration

Dotfiles and system configuration for Linux/macOS workstations.

## Setup

**Stow** symlinks config files to `~/.config/`:
```bash
cd ~/dev/dot_files
stow nvim tmux zsh  # etc.
```

**System packages** are managed separately:
- NixOS/nix-darwin: see `ops/nix/README.md`
- Arch Linux: see `ops/arch/README.md`

## Development

```bash
nix develop     # enter dev shell
format          # format Lua and YAML files
lint            # lint shell scripts
```
