# Arch Linux Infrastructure-as-Code

This setup uses Ansible to manage an Arch Linux machine locally.

## File Structure

- `inventory`: Configures Ansible to run on the local machine.
- `playbook`: Defines the tasks to be performed.
- `requirements.yml`: Lists necessary Ansible collections, such as `community.general` for the `pacman` module and `kewlfft.aur` for AUR support.

## Bootstrap

1. `sudo pacman -S ansible`
2. `sudo ansible-galaxy collection install -r ops/arch/requirements.yml`

## Management with Ansible

**NOTE**: The `ansible-playbook` command must be run with root privileges to manage system packages and configuration. For this reason, all `ansible-playbook` and `ansible-galaxy` commands in this guide use `sudo`. This ensures that Ansible collections are available to the root user executing the playbook.

Run the playbook to apply the configuration:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook`

### Dry Runs

To see what changes would be made without actually executing them, use the `--check` flag:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook --check`

### Using Tags

The playbook uses tags to allow running specific parts of the configuration.

For example, to only run tasks tagged with `packages`:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook --tags packages`

## Managing AUR Packages

This setup uses the `kewlfft.aur` collection to manage packages from the Arch User Repository (AUR).

**NOTE**: This requires a non-root user (e.g., `aur_builder`) that can build AUR packages. This user must be configured with passwordless `sudo` privileges.

To run only the AUR-related tasks:

`sudo ansible-playbook -i ops/arch/inventory ops/arch/playbook --tags aur`

## Testing

In a virtualbox guest machine:

1. Perform a minimal installation with the `archinstall` script
2. Guest OS: `sudo pacman -S virtualbox-guest-utils linux-headers`
3. Guest OS: `sudo systemctl enable vboxservice.service`
4. Guest OS: `sudo usermod -aG vboxsf $USER`
5. Guest OS: `sudo reboot`

Then I can run the "## Bootstrap" or "## Management with Ansible" commands as needed.
