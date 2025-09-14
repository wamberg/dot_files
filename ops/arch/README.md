# Arch Linux Infrastructure-as-Code

## Bootstrap

1. `sudo pacman -S ansible`
2. `ansible-galaxy collection install -r ops/requirements.yml`

## Management with Ansible

1. `ansible-playbook -i ops/inventory ops/playbook.yml`

## Testing

In a virtualbox guest machine:

1. Perform a minimal installation with the `archinstall` script
2. Guest OS: `sudo pacman -S virtualbox-guest-utils linux-headers`
3. Guest OS: `sudo systemctl enable vboxservice.service`
4. Guest OS: `sudo usermod -aG vboxsf $USER`
5. Guest OS: `sudo reboot`

Then I can run the "## Bootstrap" or "## Management with Ansible" commands as needed.
