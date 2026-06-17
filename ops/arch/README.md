# Arch Linux Infrastructure-as-Code

This setup uses Ansible to manage two Arch Linux machines locally:

- **forge** (desktop): AMD CPU/GPU, Windows dual-boot, gaming
- **freya** (laptop): Intel CPU/GPU, lid-close keeps running

## File Structure

- `inventory/` — Ansible inventory with per-host variables
  - `hosts` — Defines forge and freya
  - `group_vars/all.yml` — Shared variables (packages, directories)
  - `host_vars/forge.yml` — Desktop-specific config (AMD, gaming, swapfile hibernate)
  - `host_vars/freya.yml` — Laptop-specific config (Intel, partition hibernate)
- `playbook.yml` — Orchestrator that assigns roles to hosts
- `requirements.yml` — Ansible collection dependencies
- `roles/` — Task groups
  - `common/` — CLI tools, user setup, stow, GPG/pass, SSH, mise, tmux, docker, NTP
  - `aur/` — AUR builder user, yay, AUR packages
  - `workstation/` — Desktop apps, DE (niri/sddm/waybar), PipeWire, Bluetooth
  - `gaming/` — Multilib, 32-bit libs, v4l2loopback (forge only)
  - `laptop/` — Lid-close config (freya only)
  - `hibernation/` — Swapfile or partition hibernate, GRUB resume config

## Bootstrap

On the machine to Arch-ify:

1. `sudo pacman -S git ansible`
2. `mkdir -p /home/wamberg/dev && git clone https://github.com/wamberg/dot_files.git /home/wamberg/dev/dot_files && cd /home/wamberg/dev/dot_files`
3. `sudo ansible-galaxy collection install -r ops/arch/requirements.yml`
4. Set the machine's hostname to match the inventory name:
   - `sudo hostnamectl set-hostname forge` (desktop)
   - `sudo hostnamectl set-hostname freya` (laptop)

## Management with Ansible

**NOTE**: The `ansible-playbook` command must be run with root privileges to manage system packages and configuration. For this reason, all `ansible-playbook` and `ansible-galaxy` commands in this guide use `sudo`. This ensures that Ansible collections are available to the root user executing the playbook.

Run the playbook for a specific machine:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge`

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit freya`

### Dry Runs

To see what changes would be made without actually executing them, use the `--check` flag:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge --check`

### Using Tags

The playbook uses tags to allow running specific parts of the configuration.

For example, to only run tasks tagged with `cli`:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge --tags cli`

Or to run desktop environment setup:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge --tags desktop`

To run system upgrades (excluded by default):

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge --tags upgrade`

### List Tasks

To see what tasks would run for a machine:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit freya --list-tasks`

## Managing AUR Packages

This setup uses the `kewlfft.aur` collection to manage packages from the Arch User Repository (AUR).

To run only the AUR-related tasks:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --limit forge --tags aur_setup`

## Obsidian Sync Bootstrap (one-time per machine, after playbook run)

The `obsidian-sync` role installs `ob` (under a mise-managed Node 24, since the
system Node lacks `better-sqlite3` prebuilts) and deploys the unit files, but does
**not** enable the service — it would crash-loop until the vault is linked. `ob`
must always be invoked via `mise exec node@24 --`; an `ob` alias makes this less
tedious. Complete these steps manually on each machine after the first playbook run:

```bash
alias ob='mise exec node@24 -- ob'                    # optional, for this shell
ob login                                              # interactive: email/password + MFA
ob sync-list-remote                                   # confirm the vault (name: garden)
ob sync-setup --vault garden --path ~/dev/garden
ob sync                                               # initial reconcile (one-shot)
systemctl --user enable --now obsidian-sync.service   # start continuous daemon
```

After this, the service auto-resumes on reboot (linger + `WantedBy=default.target`).
The waybar dot turns green within ~10 s; click it to restart the service if it stops.

### Diary auto-generation

The role also enables `obsidian-diary.timer`, which runs at boot and just after
midnight to ensure a diary entry exists for **today and tomorrow** (`~/dev/garden/diary/`).
Because Templater (the GUI plugin) can't run headlessly, `bin/.bin/obsidian-diary-ensure.js`
reproduces the daily-note render generically: it reads the vault's own
`.obsidian/daily-notes.json` + template at runtime and fills in `{{date:…}}` and the
`<%* … %>` weekday logic. The template (with its private content) stays in the vault;
this script holds none of it. Run it by hand any time with
`mise exec node@24 -- ~/.bin/obsidian-diary-ensure.js` (add `--dry-run` to preview).
If you change the template's weekday-task logic in Obsidian, the renderer follows it
automatically — only genuinely new Templater APIs would need a shim addition.

## Post-Playbook Steps

### AWS Config

- Restore ~/.aws/config
- `av add <profile>` for each AWS profile I want to access

### Wallpaper

Place wallpaper images in ~/pics/wallpaper

## Using the Arch Installation

### Installing Additional AUR Packages

The playbook creates an `aur_builder` user specifically for building and installing AUR packages. To manually install additional AUR packages:

```
sudo -u aur-builder yay -S <package>
```
