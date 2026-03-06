# Update Arch Linux Playbook to Match NixOS Forge

Migrate tools adopted on NixOS back into the Arch Linux Ansible playbook.
Remove abandoned tools. Shift LSPs and formatters to mise.

## Packages to Add

### Pacman (official repos)

| Package | Purpose |
|---------|---------|
| `neovim` | Text editor (not currently explicit in playbook) |
| `tree` | Directory tree viewer |
| `libnotify` | Desktop notifications (`notify-send`) |
| `unrar` | Archive extraction |
| `feh` | Image viewer |
| `zathura` | PDF viewer |
| `zathura-pdf-mupdf` | PDF backend for zathura |
| `aws-cli-v2` | AWS CLI |

### AUR

| Package | Purpose |
|---------|---------|
| `aws-vault` | AWS credential manager |
| `bemoji` | Emoji picker |
| `claude-desktop-bin` | Claude Desktop |
| `jellyfin-media-player` | Jellyfin client |
| `tinty` | Base16/Base24 theme manager |
| `tz` | Timezone viewer |

## Packages to Remove

### Pacman

| Package | Reason |
|---------|--------|
| `obs-studio` | Unused on NixOS |
| `chromium` | Playwright dep (aider removed) |
| `nss` | Playwright dep |
| `atk` | Playwright dep |
| `at-spi2-atk` | Playwright dep |
| `gtk3` | Playwright dep |
| `gdk-pixbuf2` | Playwright dep |
| `xorg-server-xvfb` | Playwright dep |

## Ansible Tasks to Remove

- **Aider pip installation** — aider removed from workflow
- **Playwright chromium installation** — only needed for aider

## Stow List Changes

- **Add:** `btop`, `pi`, `tinty`
- **Remove:** `aider`

## Mise Config Updates

Move LSPs and formatters out of the system playbook and into the mise
global config (`mise/.config/mise/config.toml`). These are developer
tools, not system packages.

| Tool | Mise backend |
|------|-------------|
| `lua-language-server` | aqua |
| `prettier` | npm |
| `stylua` | aqua or cargo |
| `tree-sitter` | aqua |
| `ty` | aqua or github |
| `typescript-language-server` | npm |
| `htmx-lsp` | npm or cargo |

## MIME Type Defaults

Add an Ansible task that writes `~/.config/mimeapps.list`:

| File type | Application |
|-----------|-------------|
| PDF | Zathura |
| Images (JPEG, PNG, GIF) | Feh |
| Video (MP4, MKV) | mpv |
| Audio (MPEG, FLAC) | mpv |

## Unchanged

- **Whisper.cpp** — manual Vulkan build stays (AMD GPU acceleration)
- **Virtualization stack** — qemu, virt-manager, libvirt remain
- **All other existing packages and tasks** — no changes
