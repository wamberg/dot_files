# Arch Linux Infrastructure-as-Code

This setup uses Ansible to manage an Arch Linux machine locally.

## File Structure

- `inventory`: Configures Ansible to run on the local machine.
- `playbook.yml`: Defines the tasks to be performed.
- `requirements.yml`: Lists necessary Ansible collections, such as `community.general` for the `pacman` module and `kewlfft.aur` for AUR support.

## Bootstrap

On the machine to Arch-ify:

1. `sudo pacman -S git ansible`
2. `mkdir -p /home/wamberg/dev && git clone https://github.com/wamberg/dot_files.git /home/wamberg/dev/dot_files && cd /home/wamberg/dev/dot_files`
3. `sudo ansible-galaxy collection install -r ops/arch/requirements.yml`

## Management with Ansible

**NOTE**: The `ansible-playbook` command must be run with root privileges to manage system packages and configuration. For this reason, all `ansible-playbook` and `ansible-galaxy` commands in this guide use `sudo`. This ensures that Ansible collections are available to the root user executing the playbook.

Run the playbook to apply the configuration:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml`

### Dry Runs

To see what changes would be made without actually executing them, use the `--check` flag:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --check`

### Using Tags

The playbook uses tags to allow running specific parts of the configuration.

For example, to only run tasks tagged with `packages`:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --tags packages`

## Managing AUR Packages

This setup uses the `kewlfft.aur` collection to manage packages from the Arch User Repository (AUR).

**NOTE**: This requires a non-root user (e.g., `aur_builder`) that can build AUR packages. This user must be configured with passwordless `sudo` privileges.

To run only the AUR-related tasks:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook.yml --tags aur`

## Post-Playbook Steps

### AWS Config

- Restore ~/.aws/config
- `av add <profile>` for each AWS profile I want to access

### Wallpaper

Place wallpaper images in ~/pics/wallpaper

## Testing

In a virtualbox guest machine:

1. Start a new machine with the arch linux iso mounted
2. Perform a minimal installation, on the guest OS run:
  1. `pacman -Sy`
  2. `pacman -S archlinux-keyring`
  3. `pacman -S archinstall`
  3. `archinstall`, make sure to create the user, "wamberg"
3. Enable directory sharing, on the guest OS run:
  1. `sudo pacman -S virtualbox-guest-utils linux-headers`
  2. `sudo systemctl enable vboxservice.service`
  3. `sudo usermod -aG vboxsf $USER`
  4. `sudo reboot`

Then I can run commands in the the **Bootstrap** or **Management with Ansible** commands as needed.
