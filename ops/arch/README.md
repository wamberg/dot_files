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
