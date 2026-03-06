# Arch Linux Playbook Update — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the Arch Linux Ansible playbook to match the tools adopted on NixOS, remove abandoned tools, and shift LSPs/formatters to mise.

**Architecture:** Edit the existing `ops/arch/playbook.yml` Ansible playbook in place. Update the mise global config at `mise/.config/mise/config.toml`. No new files except `mimeapps.list` template. Frequent commits after each logical change.

**Tech Stack:** Ansible (YAML playbook), mise (TOML config), Arch Linux pacman/AUR

**Design doc:** `docs/plans/2026-03-06-arch-linux-update-design.md`

---

### Task 1: Add new pacman packages to CLI task

**Files:**
- Modify: `ops/arch/playbook.yml:4-49` (CLI tools pacman task)

**Step 1: Add packages to the CLI tools list**

Add these packages to the existing `System | Packages | Ensure CLI tools are installed` task, maintaining alphabetical order:

- `aws-cli-v2` (after `bat`)
- `libnotify` (after `less`)
- `neovim` (after `ncdu`)
- `tree` (after `tmux`)
- `unrar` (after `unzip`)

**Step 2: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: `playbook: ops/arch/playbook.yml` (no errors)

**Step 3: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Add neovim, tree, libnotify, unrar, aws-cli-v2 to CLI packages"
```

---

### Task 2: Add new pacman packages to desktop task

**Files:**
- Modify: `ops/arch/playbook.yml` (desktop packages pacman task, around line 546-598)

**Step 1: Add packages to the desktop packages list**

Add to the existing `System | Packages | Install essential desktop packages` task in appropriate sections:

Under `# Applications`:
- `feh` (after `discord`)
- `jellyfin-media-player` (after `kitty`) — wait, check if this is in pacman or AUR. It's AUR. Skip here.
- `zathura` (after `telegram-desktop`)
- `zathura-pdf-mupdf` (after `zathura`)

Remove from `# Applications`:
- `obs-studio`

Under `# Desktop Environment`:
- `bemoji` — check if pacman or AUR first

Under `# System Utilities`:
- No changes needed; `libnotify` goes in CLI task

**Important:** Before adding, verify which packages are in official repos vs AUR:

Run: `pacman -Ss bemoji` — if not found, it's AUR
Run: `pacman -Ss jellyfin-media-player` — if not found, it's AUR
Run: `pacman -Ss tz` — if not found, it's AUR
Run: `pacman -Ss tinty` — if not found, it's AUR

Adjust placement (pacman task vs AUR task) based on results. The design doc assumes these are AUR: `bemoji`, `jellyfin-media-player`, `tinty`, `tz`, `aws-vault`, `claude-desktop-bin`.

**Step 2: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: no errors

**Step 3: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Add feh, zathura to desktop packages, remove obs-studio"
```

---

### Task 3: Add new AUR packages

**Files:**
- Modify: `ops/arch/playbook.yml` (AUR desktop packages task, around line 531-544)

**Step 1: Add AUR packages**

Add to the `System | Packages | Install essential AUR desktop packages` task:
- `aws-vault`
- `bemoji`
- `claude-desktop-bin`
- `jellyfin-media-player`
- `tinty`
- `tz`

Maintain alphabetical order within the list.

**Step 2: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: no errors

**Step 3: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Add aws-vault, bemoji, claude-desktop, jellyfin, tinty, tz to AUR packages"
```

---

### Task 4: Remove playwright and aider tasks

**Files:**
- Modify: `ops/arch/playbook.yml`

**Step 1: Remove the playwright system dependencies task**

Delete the entire task block `System | Packages | Ensure playwright system dependencies` (lines 218-230) which installs: chromium, nss, atk, at-spi2-atk, gtk3, gdk-pixbuf2, xorg-server-xvfb.

**Step 2: Remove aider installation tasks**

Delete these three task blocks:
- `User | wamberg | Check if aider is installed` (lines 231-238)
- `User | wamberg | Install aider-install` (lines 239-246)
- `User | wamberg | Install aider using aider-install` (lines 247-254)

**Step 3: Remove playwright chromium installation tasks**

Delete these two task blocks:
- `User | wamberg | Check if playwright chromium is installed` (lines 255-262)
- `User | wamberg | Install playwright chromium browser` (lines 263-269)

**Step 4: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: no errors

**Step 5: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Remove aider and playwright tasks"
```

---

### Task 5: Update stow list

**Files:**
- Modify: `ops/arch/playbook.yml` (stow task, around lines 97-126)

**Step 1: Update the stow loop list**

Remove from the loop:
- `aider`

Add to the loop (alphabetical order):
- `btop` (after `bin`)
- `iamb` — wait, design says no iamb. Skip.
- `pi` (after `nvim`)
- `tinty` (after `swappy`)

The final stow list should be:
```
- bat
- bin
- btop
- claude
- fuzzel
- git
- kitty
- mako
- mise
- mpv
- niri
- npm
- nvim
- pi
- sql
- starship
- swappy
- tinty
- tmux
- vifm
- waybar
- zsh
```

**Step 2: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: no errors

**Step 3: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Update stow list: add btop, pi, tinty; remove aider"
```

---

### Task 6: Add MIME type defaults task

**Files:**
- Modify: `ops/arch/playbook.yml` (add new task after stow task)

**Step 1: Add mimeapps.list task**

Insert a new Ansible task after the stow task. Use `ansible.builtin.copy` with `content` to write the file directly (no template file needed):

```yaml
    - name: User | wamberg | Set default applications
      become: yes
      become_user: wamberg
      ansible.builtin.copy:
        content: |
          [Default Applications]
          application/pdf=org.pwmt.zathura.desktop
          image/jpeg=feh.desktop
          image/png=feh.desktop
          image/gif=feh.desktop
          video/mp4=mpv.desktop
          video/x-matroska=mpv.desktop
          audio/mpeg=mpv.desktop
          audio/flac=mpv.desktop
        dest: /home/wamberg/.config/mimeapps.list
        owner: wamberg
        group: wamberg
        mode: '0644'
      tags:
        - dev
```

**Step 2: Verify playbook syntax**

Run: `ansible-playbook --syntax-check -i ops/arch/inventory ops/arch/playbook.yml`
Expected: no errors

**Step 3: Commit**

```
git add ops/arch/playbook.yml
git commit -m "arch - Add MIME type defaults for zathura, feh, mpv"
```

---

### Task 7: Update mise config

**Files:**
- Modify: `mise/.config/mise/config.toml`

**Step 1: Remove packages moving to pacman/AUR**

Remove these lines from `[tools]`:
- `awscli = "2.32.13"`
- `aws-vault = "7.2.0"`
- `neovim = "0.11.5"`

**Step 2: Add LSPs and formatters**

Add these to the `[tools]` section:
- `lua-language-server = "latest"`
- `"npm:prettier" = "latest"`
- `stylua = "latest"`
- `tree-sitter = "latest"`
- `ty = "latest"`
- `"npm:typescript-language-server" = "latest"`
- `"npm:htmx-lsp" = "latest"`

The final config should look like:

```toml
[tools]
nodejs = "24.10.0"
python = "3.14.2"
lua-language-server = "latest"
"npm:prettier" = "latest"
"npm:typescript-language-server" = "latest"
"npm:htmx-lsp" = "latest"
stylua = "latest"
tree-sitter = "latest"
ty = "latest"

[settings]
experimental = true
python_compile = true
```

**Step 3: Verify mise config parses**

Run: `mise ls`
Expected: lists all tools without parse errors

**Step 4: Commit**

```
git add mise/.config/mise/config.toml
git commit -m "arch - Move LSPs to mise, move awscli/aws-vault/neovim to pacman"
```

---

### Task 8: Update README

**Files:**
- Modify: `ops/arch/README.md`

**Step 1: Remove aider mention if present**

Check README for any aider references and remove.

**Step 2: Update post-playbook steps**

The whisper.cpp manual install section stays. Verify it's still accurate.

**Step 3: Commit (only if changes were made)**

```
git add ops/arch/README.md
git commit -m "arch - Update README to reflect removed tools"
```
