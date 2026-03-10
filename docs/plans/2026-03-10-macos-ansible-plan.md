# macOS Ansible Migration — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace nix-darwin with an Ansible playbook that manages the MacBook Pro's development environment.

**Architecture:** A flat, single-playbook Ansible setup at `ops/mac/` mirroring the existing `ops/arch/` pattern. Homebrew handles system packages; mise handles runtimes, LSPs, and formatters. Stow manages dotfiles. No shared package lists between platforms.

**Tech Stack:** Ansible, Homebrew (formulae + casks), mise, GNU Stow, tinty, fzf

**Design doc:** `docs/plans/2026-03-10-macos-ansible-design.md`

---

### Task 1: Scaffold ops/mac/ directory

**Files:**
- Create: `ops/mac/inventory`
- Create: `ops/mac/requirements.yml`

**Step 1: Create inventory file**

```
localhost ansible_connection=local
```

Reference: `ops/arch/inventory` uses the same format.

**Step 2: Create requirements.yml**

```yaml
collections:
  - community.general
```

Note: No `kewlfft.aur` — that is Arch-specific.

**Step 3: Commit**

```bash
git add ops/mac/inventory ops/mac/requirements.yml
git commit -m "mac - Scaffold ops/mac/ with inventory and requirements"
```

---

### Task 2: Write the playbook — package installation

**Files:**
- Create: `ops/mac/playbook.yml`

**Step 1: Create playbook with brew formulae and casks**

The playbook runs against localhost without top-level `become: yes`.
Homebrew tasks run as the current user.

```yaml
- hosts: localhost
  tasks:
    - name: Packages | Install Homebrew formulae
      community.general.homebrew:
        name:
          - awscli
          - aws-vault
          - bat
          - curl
          - fd
          - fzf
          - git
          - git-delta
          - gnupg
          - jq
          - less
          - mise
          - ncdu
          - neovim
          - pass
          - pigz
          - ripgrep
          - rsync
          - sqlite
          - stow
          - tmux
          - tree
          - unzip
          - vifm
          - vim
          - wget
          - zsh
        state: present

    - name: Packages | Install Homebrew casks
      community.general.homebrew_cask:
        name:
          - 1password
          - 1password-cli
          - kitty
        state: present
```

Note: `delta` is packaged as `git-delta` in Homebrew. `gnupg` and
`pass` are included to match Arch (used for GPG/pass workflow).

**Step 2: Run playbook to verify packages install**

```bash
ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml
```

Expected: All formulae and casks install (or report "already installed").

**Step 3: Commit**

```bash
git add ops/mac/playbook.yml
git commit -m "mac - Add playbook with brew formulae and casks"
```

---

### Task 3: Add setup tasks to the playbook

**Files:**
- Modify: `ops/mac/playbook.yml`

**Step 1: Add directory creation, oh-my-zsh, stow, tpm, SSH config, and mise tasks**

Append these tasks after the cask installation task in the playbook:

```yaml
    - name: Setup | Create directories
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: directory
        mode: "{{ item.mode | default('0755') }}"
      loop:
        - { path: "{{ ansible_env.HOME }}/.ssh", mode: "0700" }
        - { path: "{{ ansible_env.HOME }}/.tmux/plugins" }
        - { path: "{{ ansible_env.HOME }}/dev" }
        - { path: "{{ ansible_env.HOME }}/docs" }
        - { path: "{{ ansible_env.HOME }}/pics" }
        - { path: "{{ ansible_env.HOME }}/videos" }

    - name: Setup | Check for oh-my-zsh
      ansible.builtin.stat:
        path: "{{ ansible_env.HOME }}/.oh-my-zsh"
      register: omz_stat

    - name: Setup | Install oh-my-zsh
      when: not omz_stat.stat.exists
      ansible.builtin.shell:
        cmd: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        creates: "{{ ansible_env.HOME }}/.oh-my-zsh"

    - name: Setup | Remove oh-my-zsh default .zshrc
      ansible.builtin.file:
        path: "{{ ansible_env.HOME }}/.zshrc"
        state: absent
      when: not omz_stat.stat.exists

    - name: Setup | Stow dotfiles
      ansible.builtin.shell: >
        stow --dir="{{ ansible_env.HOME }}/dev/dot_files"
        --target="{{ ansible_env.HOME }}/"
        --restow --no-folding --verbose=1
        {{ item }}
      loop:
        - bat
        - bin
        - claude
        - git
        - kitty
        - mise
        - npm
        - nvim
        - sql
        - tinty
        - tmux
        - vifm
        - zsh
      register: stow_result
      changed_when: stow_result.stdout != ""

    - name: Setup | Check if tpm is installed
      ansible.builtin.stat:
        path: "{{ ansible_env.HOME }}/.tmux/plugins/tpm/.git"
      register: tpm_stat

    - name: Setup | Clone tmux plugin manager
      ansible.builtin.git:
        repo: "https://github.com/tmux-plugins/tpm"
        dest: "{{ ansible_env.HOME }}/.tmux/plugins/tpm"
        depth: 1
      when: not tpm_stat.stat.exists

    - name: Setup | Configure 1Password SSH agent
      ansible.builtin.blockinfile:
        path: "{{ ansible_env.HOME }}/.ssh/config"
        create: yes
        mode: "0600"
        block: |
          Host *
              IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

    - name: Setup | Create tinty symlink for tinted-theming path
      ansible.builtin.file:
        src: "{{ ansible_env.HOME }}/.config/tinty"
        dest: "{{ ansible_env.HOME }}/.config/tinted-theming/tinty"
        state: link
        force: no
      ignore_errors: yes

    - name: Setup | Check for missing mise tools
      ansible.builtin.shell: "{{ ansible_env.HOME }}/.local/share/mise/bin/mise ls --missing"
      register: mise_missing
      changed_when: false
      environment:
        PATH: "{{ ansible_env.HOME }}/.local/share/mise/bin:{{ ansible_env.HOME }}/.local/share/mise/shims:{{ ansible_env.PATH }}"

    - name: Setup | Install mise tools
      ansible.builtin.shell: "{{ ansible_env.HOME }}/.local/share/mise/bin/mise install"
      when: mise_missing.stdout != ""
      environment:
        PATH: "{{ ansible_env.HOME }}/.local/share/mise/bin:{{ ansible_env.HOME }}/.local/share/mise/shims:{{ ansible_env.PATH }}"
```

Important details:
- No `become: yes` on any task — all run as the current macOS user.
- SSH config uses the macOS 1Password agent socket path
  (`~/Library/Group Containers/...`), which differs from the Arch
  path (`~/.1password/agent.sock`).
- The tinty symlink matches the nix-darwin workaround at
  `ops/nix/hosts/mac/home.nix:114-119`.
- Mise binary path: Homebrew installs mise, which puts its own
  binary at `~/.local/share/mise/bin/mise`. The shell tasks need
  the explicit path because Ansible does not source `.zshrc`.

**Step 2: Run the playbook**

```bash
ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml
```

Expected: Directories created, dotfiles stowed, tpm cloned (or
already present), SSH config written, mise tools installed.

**Step 3: Verify**

```bash
ls -la ~/.ssh/config
ls ~/.tmux/plugins/tpm
mise ls
```

**Step 4: Commit**

```bash
git add ops/mac/playbook.yml
git commit -m "mac - Add setup tasks: dirs, oh-my-zsh, stow, tpm, ssh, mise"
```

---

### Task 4: Add tinty to mise config

**Files:**
- Modify: `mise/.config/mise/config.toml`

Tinty is a Rust binary. Mise can install it via the cargo backend.

**Step 1: Add tinty to mise config**

Add `"cargo:tinty" = "latest"` to the `[tools]` section of
`mise/.config/mise/config.toml`.

**Step 2: Verify tinty installs via mise**

```bash
mise install
tinty --version
```

Expected: tinty binary available in path.

**Step 3: Commit**

```bash
git add mise/.config/mise/config.toml
git commit -m "mise - Add tinty via cargo backend"
```

---

### Task 5: Make set-color-scheme-preference.sh cross-platform

**Files:**
- Modify: `tinty/.config/tinty/hooks/set-color-scheme-preference.sh`

The current script uses `dconf` (Linux/GNOME only). Add macOS
support using `defaults write`.

**Step 1: Update the script to detect the platform**

Replace the `dconf` calls inside the variant conditionals with
platform-aware logic:

```bash
ARTIFACTS_DIR="$HOME/.local/share/tinted-theming/tinty/artifacts"
if [ "$VARIANT" = "dark" ]; then
    if [[ "$OSTYPE" == darwin* ]]; then
        # Set macOS to dark mode
        osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
    else
        dconf write /org/freedesktop/appearance/color-scheme "uint32 1"
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    fi
    echo 'export COLORFGBG="15;0"' > "$ARTIFACTS_DIR/colorfgbg.sh"
elif [ "$VARIANT" = "light" ]; then
    if [[ "$OSTYPE" == darwin* ]]; then
        # Set macOS to light mode
        osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to false'
    else
        dconf write /org/freedesktop/appearance/color-scheme "uint32 2"
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    fi
    echo 'export COLORFGBG="0;15"' > "$ARTIFACTS_DIR/colorfgbg.sh"
fi
```

`osascript` is available on every macOS system. The `$OSTYPE`
variable is set by bash and starts with `darwin` on macOS.

**Step 2: Test on macOS**

```bash
tinty apply base16-dracula    # dark theme
# Verify: macOS should switch to dark mode

tinty apply base16-github     # light theme
# Verify: macOS should switch to light mode
```

**Step 3: Commit**

```bash
git add tinty/.config/tinty/hooks/set-color-scheme-preference.sh
git commit -m "tinty - Make color-scheme-preference hook cross-platform"
```

---

### Task 6: Create fzf-based theme picker for macOS

**Files:**
- Create: `bin/.bin/,mac-theme-menu.sh`

**Step 1: Write the script**

```bash
#!/usr/bin/env bash
# fzf-based theme selector for tinty (macOS)
set -e

TINTY_CONFIG="$HOME/.config/tinty/config.toml"
FAVORITES_FILE="$HOME/.config/tinty/favorites.txt"
CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"

CURRENT=""
if [ -f "$CURRENT_SCHEME_FILE" ]; then
    CURRENT=$(cat "$CURRENT_SCHEME_FILE")
fi

# Show favorites first (starred), then all themes
{
    if [ -f "$FAVORITES_FILE" ] && [ -s "$FAVORITES_FILE" ]; then
        sed 's/^/* /' "$FAVORITES_FILE"
    fi
    tinty -c "$TINTY_CONFIG" list | awk '{print $1}'
} | fzf --prompt="theme ($CURRENT)> " | sed 's/^\* //' | xargs -r tinty -c "$TINTY_CONFIG" apply
```

Note: Uses `*` instead of emoji star for terminal compatibility.

**Step 2: Make it executable**

```bash
chmod +x bin/.bin/,mac-theme-menu.sh
```

**Step 3: Test it**

```bash
~/.bin/,mac-theme-menu.sh
```

Expected: fzf picker opens with favorites at top, selecting a theme
applies it via tinty.

**Step 4: Commit**

```bash
git add bin/.bin/,mac-theme-menu.sh
git commit -m "bin - Add fzf-based theme picker for macOS"
```

---

### Task 7: Write the README

**Files:**
- Create: `ops/mac/README.md`

**Step 1: Write the README**

Model it on `ops/arch/README.md`. Include:
- File structure description (inventory, playbook, requirements)
- Bootstrap steps (xcode-select, homebrew, git, ansible, clone,
  galaxy install)
- Running the playbook command
- Dry run command (`--check`)
- Post-playbook steps (1Password sign-in, tmux plugins, terminal
  restart)

**Step 2: Commit**

```bash
git add ops/mac/README.md
git commit -m "mac - Add README with bootstrap and usage instructions"
```

---

### Task 8: Validate the full playbook on a clean run

**Step 1: Run the full playbook**

```bash
ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml
```

**Step 2: Verify key outcomes**

```bash
# Packages
brew list | grep -E "^(bat|fzf|neovim|tmux|stow|mise)$"
brew list --cask | grep -E "^(1password|kitty)$"

# Stow
ls -la ~/.config/nvim     # Should be symlink to dot_files
ls -la ~/.config/kitty     # Should be symlink to dot_files

# SSH
grep -q "1password" ~/.ssh/config

# Mise
mise ls                    # Should show all tools installed

# Tinty
tinty --version
tinty list | head -3

# Theme picker
~/.bin/,mac-theme-menu.sh
```

**Step 3: Run playbook again to verify idempotency**

```bash
ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml
```

Expected: All tasks report "ok", none report "changed" (except
stow which may always show output).

**Step 4: Commit any fixes**

If validation revealed issues, fix and commit each separately.

---

### Task 9: Remove nix-darwin mac configuration

Only proceed after Task 8 passes. This task removes nix config
files from the repository. Nix itself is uninstalled separately
(manual step, documented below).

**Files:**
- Delete: `ops/nix/hosts/mac/configuration.nix`
- Delete: `ops/nix/hosts/mac/home.nix`
- Delete: `ops/nix/common/darwin.nix`
- Modify: `ops/nix/flake.nix`

**Step 1: Delete mac-specific nix files**

```bash
rm ops/nix/hosts/mac/configuration.nix
rm ops/nix/hosts/mac/home.nix
rmdir ops/nix/hosts/mac
rm ops/nix/common/darwin.nix
```

**Step 2: Remove darwinConfigurations from flake.nix**

Edit `ops/nix/flake.nix` to remove:
- The `darwinConfigurations` block (lines 47-56)
- The `nix-darwin` input (lines 17-20)
- `nix-darwin` from the outputs function arguments (line 25)

Keep the `home-manager` input — forge still uses it via
`home-manager.nixosModules.home-manager`.

The resulting flake should only contain `nixosConfigurations.forge`.

**Step 3: Verify flake still parses for forge**

This must be verified on a machine with nix installed, or by
inspecting the syntax. The flake should still define
`nixosConfigurations.forge` with its existing modules.

**Step 4: Commit**

```bash
git add -u ops/nix/
git commit -m "nix - Remove nix-darwin mac configuration"
```

---

### Task 10: Uninstall nix from the mac (manual)

This task is performed manually, not automated.

**Step 1: Uninstall nix-darwin**

```bash
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
./result/bin/darwin-uninstaller
```

**Step 2: Uninstall nix**

Follow the official uninstall guide:
https://nix.dev/manual/nix/latest/installation/uninstall

On macOS multi-user installs, this involves:
- Stopping and removing the nix-daemon LaunchDaemon
- Removing the `/nix` volume and its fstab entry
- Removing nix build users and group
- Removing `/etc/nix` and `~/.nix-*` files
- Removing nix shell config from `/etc/zshrc` and `/etc/bashrc`

**Step 3: Restart and verify**

```bash
# After restart
which nix        # Should return nothing
ls /nix          # Should not exist
```

**Step 4: Clean up .backup files**

Home-manager created `.backup` files when stow and nix configs
conflicted. Find and remove them:

```bash
find ~ -maxdepth 3 -name "*.backup" -type f 2>/dev/null
```

Review and delete as appropriate.
