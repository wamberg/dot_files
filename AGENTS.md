# Agent Context

Dotfiles repository for Linux/macOS workstations.

## Architecture

**Hybrid approach** - three tools coexist permanently:

| Tool | Purpose | Location |
|------|---------|----------|
| GNU Stow | Symlinks config files to `~/.config/` | Root directories (`nvim/`, `tmux/`, etc.) |
| NixOS/nix-darwin | System packages and services | `ops/nix/` |
| Ansible | Arch Linux machine setup | `ops/arch/` |

Stow manages configs. Nix/Ansible manage packages. This is intentional, not a migration.

## Directory Structure

```
dot_files/
├── nvim/, tmux/, zsh/, ...    # Stow packages (symlinked to ~/.config/)
├── bin/                        # Custom scripts
├── ops/
│   ├── nix/                    # NixOS/Darwin flake (hosts: forge, mac)
│   └── arch/                   # Ansible playbook for Arch
├── flake.nix                   # Dev shell with format/lint commands
└── claude/                     # Claude CLI settings
```

## Hosts

- **forge** - NixOS desktop/server
- **mac** - macOS with nix-darwin

## Common Workflows

**Add a new config (e.g., for tool X):**
```bash
mkdir -p X/.config/X
# Add config files
cd ~/dev/dot_files && stow X
```

**Update NixOS:**
```bash
cd ops/nix
sudo nixos-rebuild switch --flake .#forge
```

**Update flake dependencies:**
```bash
cd ops/nix && nix flake update
```

**Format/lint:**
```bash
nix develop  # enters dev shell
format       # stylua for Lua, yamlfmt for YAML
lint         # shellcheck for shell scripts
```

## Key Files

- `ops/nix/README.md` - Detailed NixOS architecture and decisions
- `ops/nix/flake.nix` - System configurations for all hosts
- `flake.nix` - Development shell (format, lint)

## Conventions

- Configs use Stow's directory structure: `toolname/.config/toolname/`
- NixOS modules use proper option patterns (`mkEnableOption`, `mkIf`)
- Development secrets via 1password CLI (`op inject`)
- User is learning Nix - prefer simple over clever

## NixOS Guidelines

**DO:**
- Respect the directory structure in `ops/nix/`
- Use proper NixOS module patterns with options, config, and conditionals
- Keep `common/` minimal and truly universal
- Make modules self-contained and optional
- Ask which host(s) need the proposed change

**DON'T:**
- Create modules until they're needed by multiple hosts
- Edit `hardware-configuration.nix` (it's auto-generated)
- Add `overlays/` or `lib/` directories until there's actual content
- Force migration of configs from stow to Nix
