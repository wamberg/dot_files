# NixOS Configuration

This directory contains NixOS system and home-manager configurations using flakes for multiple hosts.

## Status

**Early stage / Learning**: Currently transitioning to NixOS. Starting with desktop and laptop development machines. May expand to servers if things go well.

## User Context

- **User**: wamberg
- **Learning approach**: Start minimal, extract patterns as needed
- **Dotfiles**: Managed with GNU stow in parent directory (permanent hybrid approach)
- **Development setup**: Uses tmux, neovim, zsh
- **Secrets**: Uses 1password CLI (`op`) for development secrets

## Architecture Decisions

### Home-Manager Integration
**Decision**: Use home-manager as a **NixOS module** (integrated into system configuration).
- Single `nixos-rebuild` command updates both system and user config
- User config defined inside NixOS configuration via `home-manager.users.wamberg`
- Simpler workflow for NixOS-only machines

### Dotfiles Strategy
**Decision**: **Permanent hybrid approach** - stow and Nix coexist indefinitely.
- Stow manages all config files (nvim, tmux, zsh, etc.) from parent directory
- Nix installs packages and ensures programs are available
- Migration to Nix-managed configs is **optional** and at user's pace
- When a config benefits from Nix (complex dependencies, templating), migrate just that one

**Why**: This allows gradual learning while keeping existing dotfiles working.

### Secrets Management
**Decision**: **Deferred** until a concrete need arises.
- Development secrets: Continue using `op inject` from `.env.tpl` files
- SSH keys: Managed by 1password SSH agent
- NixOS system secrets: Will add sops-nix or agenix when needed (see Future Enhancements)
- No secrets in Nix configuration files currently

### Flake Structure
**Decision**: Start with simple, explicit flake outputs. Refactor to helper functions when adding second host.
- First host: Write configuration explicitly in flake.nix
- When duplication becomes obvious, extract mkHost helper
- Learn by seeing the patterns before abstracting them

### Module Pattern
**Decision**: Use proper NixOS option definitions with `mkEnableOption`, `mkOption`, and `mkIf`.
- Modules should define options in `options.*` block
- Actual configuration goes in `config` block with conditionals
- Makes modules configurable per-host
- Follows standard NixOS patterns

Example:
```nix
{ config, lib, pkgs, ... }: {
  options.my.desktop = {
    enable = lib.mkEnableOption "desktop environment";
    compositor = lib.mkOption {
      type = lib.types.enum [ "sway" "hyprland" ];
      default = "sway";
    };
  };

  config = lib.mkIf config.my.desktop.enable {
    # Desktop configuration here
  };
}
```

### Testing Strategy
**Decision**: Use `nixos-rebuild test` for most changes, `build-vm` for risky ones.
- `nixos-rebuild test` - Apply config without adding boot entry (safe)
- `nixos-rebuild build-vm` - Test in QEMU VM for major changes
- `nixos-rebuild switch` - Apply and make permanent
- Commands documented organically as learned and used

### Binary Cache and Overlays
**Decision**: **Deferred** until needed.
- Start with default nixpkgs cache
- Add overlay structure when first custom package is needed
- Consider Cachix when rebuild times become painful

### Development Environments
**Decision**: **PENDING** - Need to choose between Docker and Nix-native approaches.

**Context**: Arch setup uses Docker + docker-compose for development dependencies (databases, services, etc.). Need to decide on NixOS approach.

**Options:**

1. **devenv.sh** - Docker Compose replacement for Nix
   - Declarative service configuration (postgres, redis, etc.)
   - Purpose-built for development environments
   - Closest to Docker Compose workflow
   - Example: `services.postgres.enable = true;`

2. **Flake devShells** - Lightweight development shells
   - Define per-project `devShells` in flake.nix
   - Use `shellHook` to start services
   - More manual but flexible
   - Integrates well with direnv

3. **Keep Docker** - Continue using Docker + docker-compose
   - Familiar workflow
   - Production parity if deploying containers
   - More resource overhead on NixOS

**Trade-offs:**
- **Nix-native** (devenv.sh or devShells): Faster, better integration, less resource usage, but learning curve
- **Docker**: Familiar, good isolation, but resource overhead and less Nix integration

**Next steps**: Try Nix-native approach on first real project need. Can always fall back to Docker if needed.

### Hibernation / Swap
**Decision**: Use a **dedicated swap partition** on physical hardware.

- Create a swap partition during NixOS installation (16GB recommended)
- NixOS will automatically configure it in hardware-configuration.nix
- Hibernation will work out of the box without manual offset tracking

**Steps for physical hardware install:**
1. During disk partitioning, create a 16GB swap partition
2. Run `nixos-generate-config` - it will detect and configure swap automatically
3. Verify hibernation works: `systemctl hibernate --dry-run`

**Alternative** (if swap partition not possible):
- Use swapfile approach with manual offset configuration
- Add to configuration.nix after first boot:
  ```nix
  swapDevices = [{ device = "/swapfile"; size = 16 * 1024; }];
  boot.resumeDevice = "/dev/disk/by-uuid/ROOT-UUID";
  boot.kernelParams = [ "resume_offset=OFFSET" ];
  ```
- Get offset with: `filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'`

## Directory Structure

```
ops/nix/
├── flake.nix                      # Main flake defining all hosts and outputs
├── flake.lock                     # Locked dependency versions
├── common/
│   ├── nixos.nix                  # System config shared by ALL hosts
│   └── home.nix                   # Home-manager config shared by ALL hosts
├── hosts/
│   ├── hostname1/
│   │   ├── configuration.nix      # Host-specific system config
│   │   ├── hardware-configuration.nix  # Generated by nixos-generate-config
│   │   └── home.nix               # Host-specific home-manager config
│   └── hostname2/
│       └── ...
├── modules/
│   ├── nixos/
│   │   ├── default.nix            # Imports all available system modules
│   │   ├── desktop.nix            # Desktop environment, GUI apps
│   │   ├── development.nix        # Dev tools, languages, databases
│   │   └── ...
│   └── home/
│       ├── default.nix            # Imports all available home modules
│       ├── gui/
│       │   ├── firefox.nix        # Browser configuration
│       │   └── ...
│       └── cli/
│           ├── nvim.nix           # Neovim configuration
│           └── ...
├── overlays/                      # (Created when first needed)
│   └── ...                        # Custom packages, patches, version overrides
├── lib/                           # (Created when first needed)
│   └── ...                        # Reusable helper functions (mkHost, etc.)
└── README.md                      # This file
```

**Note**: `overlays/` and `lib/` directories don't exist yet. They'll be created when first needed.

## What Goes Where

### common/

Configuration that **every single host** will need:

**nixos.nix** (system-level):
- Nix settings (flakes enabled, nix-command)
- User account definition (wamberg)
- Locale and timezone
- Core system packages (git, vim, curl, stow)
- Basic security settings

**home.nix** (user-level):
- Universal CLI tools (bat, broot, ripgrep, etc)
- Tmux, neovim basic setup (just ensure installed, configs from stow)

### modules/

**Optional** configuration that hosts can selectively import:

**modules/nixos/** (system-level):
- `desktop.nix` - Desktop environment, display manager, GUI system services
- `development.nix` - Dev tools, compilers, databases, Docker
- `laptop.nix` - Battery management, WiFi, power profiles
- `server.nix` - (Future) Server-specific services

**modules/home/** (user-level):
- `gui/` - GUI applications (Firefox, Kitty, etc)
- `cli/` - CLI program configurations
- Organized by category for clarity

**Important**: All modules should use proper option definitions (see Module Pattern above).

### hosts/

**Per-host configuration**:

**configuration.nix**:
- Imports from `common/nixos.nix`
- Imports selected modules from `modules/nixos/`
- Hostname, networking
- Host-specific packages
- Host-specific system settings
- Integrates home-manager as module

**hardware-configuration.nix**:
- Generated by `nixos-generate-config`
- **Never manually edit**
- Hardware-specific settings (filesystems, boot, etc)

**home.nix**:
- Imports from `common/home.nix`
- Imports selected modules from `modules/home/`
- Host-specific home-manager settings

## Design Principles

1. **Start minimal** - Don't create modules until you have config to share between hosts
2. **Extract patterns** - First host can have most config in its configuration.nix, extract common patterns when adding second host
3. **Common is universal** - Only put things in common/ that literally every host will need
4. **Modules are optional** - Modules should be opt-in features that hosts selectively import
5. **Clear separation** - System (nixos) vs user (home) configuration stays separate
6. **Flakes for reproducibility** - Lock dependencies, enable nix-command and flakes features
7. **Learn before abstracting** - See the duplication before creating helpers
8. **Proper module options** - Use mkEnableOption, mkOption, mkIf for configurable modules

## Development Workflow

### Adding First Host

1. Run `nixos-generate-config` on the target machine to get hardware-configuration.nix
2. Create `hosts/hostname/` directory
3. Write configuration.nix that imports common and defines host-specific settings
4. Write home.nix for user-specific settings
5. Define host in flake.nix outputs
6. Build and test

### When Adding Second Host

1. Run `nixos-generate-config` on the new machine
2. Create `hosts/newhost/` directory
3. Copy from first host, modify for new machine
4. **Notice the duplication** - this is your signal to extract patterns
5. Move repeated config to modules/
6. Consider creating helper functions in lib/ if flake.nix gets repetitive
7. Update both hosts to use new modules

### When You See Repeated Config Across Hosts

1. Extract it to a module in `modules/nixos/` or `modules/home/`
2. Use proper option definitions (see Module Pattern)
3. Import that module in relevant hosts
4. Remove the duplicated config from host files

## Integration with Existing Dotfiles

NixOS configuration lives here in ops/nix/. User dotfiles (the parent directory) are still managed with stow. This is a **permanent hybrid approach**:

**Stow manages:**
- All config files in ~/.config/ (nvim, tmux, kitty, etc.)
- Shell configuration files (.zshrc, etc.)
- Application dotfiles

**Nix manages:**
- Package installation
- System services
- System-wide configuration
- (Optional) Any configs you choose to migrate over time

**How they coexist:**
- Nix ensures programs like nvim, tmux, zsh are installed
- Stow symlinks your existing config files
- Both work together - Nix provides programs, stow provides configs
- You can optionally use `home.file` to let Nix manage the symlinking if desired

**Migration is optional:**
If a config benefits from Nix (needs templating, has dependencies, etc.), you can migrate it:
```nix
# In home.nix - have Nix create symlink to stow directory
home.file.".config/nvim".source = ../../../nvim/.config/nvim;
```

## Future Enhancements

These are explicitly deferred until needed:

### nix-darwin for macOS (Priority: Medium)
- User has Apple Silicon MacBook Pro
- Would use nix-darwin + home-manager for full Mac management
- Flake would output both `nixosConfigurations` and `darwinConfigurations`
- Home-manager integrates as module in both NixOS and Darwin
- **Defer until**: NixOS workflow is solid and proven

### Secrets Management (Priority: Low - defer until needed)
Currently using 1password CLI for development secrets. Add NixOS secrets management when you have a concrete use case:

**Candidate solutions:**
- **agenix** - Simpler, uses age/SSH keys, one file per secret
- **sops-nix** - More powerful, YAML/JSON with multiple secrets, supports cloud KMS

**Potential use cases:**
- WiFi passwords (declarative network configuration)
- System service credentials
- SSH host keys (preserve across rebuilds)
- Private repository access tokens
- VPN credentials

**Current workflow remains:**
- Development secrets via `op inject` and .env files
- SSH keys via 1password SSH agent
- Manual configuration for WiFi, etc.

### Binary Cache (Priority: Low)
**When**: Build times become painful with custom packages
**Options**: Cachix (hosted) or self-hosted
**Benefit**: Avoid rebuilding packages on every machine

### Helper Functions and Lib (Priority: Low)
**When**: Adding second host and flake.nix gets repetitive
**Create**: `lib/default.nix` or `lib.nix` with helpers like:
- `mkHost` - Reduce boilerplate in host definitions
- Shared utilities for module configuration
- Custom option types

### Deploy Tooling (Priority: Low)
**When**: Managing multiple machines, especially servers
**Options**: deploy-rs, colmena, NixOps
**Benefit**: Deploy configurations to remote machines

## Common Build Commands

These will be documented as learned and used:

```bash
# Build and activate configuration (makes it default boot entry)
sudo nixos-rebuild switch --flake .#hostname

# Test configuration without making it default (safer)
sudo nixos-rebuild test --flake .#hostname

# Build VM for testing major changes
nixos-rebuild build-vm --flake .#hostname
./result/bin/run-hostname-vm

# Update flake inputs (dependencies)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Garbage collection (free disk space)
sudo nix-collect-garbage -d

# Validate flake
nix flake check
```

## Notes for AI Coding Agent

When proposing changes to this configuration:

**DO:**
- Respect the directory structure above
- Use proper NixOS module patterns with options, config, and conditionals
- Keep common/ minimal and truly universal
- Make modules self-contained and optional
- Consider: "Would every host need this?" when deciding common vs module
- Prefer clear/simple over clever/complex (user is learning)
- Remember dotfiles are managed by stow - Nix should not conflict
- Ask which host(s) need the proposed change

**DON'T:**
- Create modules until they're needed by multiple hosts
- Edit hardware-configuration.nix (it's auto-generated)
- Add overlays/lib directories until there's actual content for them
- Force migration of configs from stow to Nix (it's optional)
- Add secrets management until user has a specific need
- Assume binary cache is available
- Create helper functions before seeing the duplication pattern

**Remember:**
- User is learning Nix - explain what you're doing
- Start with simplest solution that works
- Extract patterns only after seeing duplication
- This is iteration 1 of a learning journey
