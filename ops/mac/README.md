# macOS Infrastructure-as-Code

This setup uses Ansible to manage a macOS machine locally.

## File Structure

- `inventory`: Configures Ansible to run on the local machine.
- `playbook.yml`: Defines the tasks to be performed.
- `requirements.yml`: Lists necessary Ansible collections.

## Bootstrap

On the machine to set up:

1. `xcode-select --install`
2. `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. `brew install git ansible`
4. `mkdir -p ~/dev && git clone https://github.com/wamberg/dot_files.git ~/dev/dot_files && cd ~/dev/dot_files`
5. `ansible-galaxy collection install -r ops/mac/requirements.yml`

## Management with Ansible

**NOTE**: Unlike Arch, no `sudo` is needed -- Homebrew runs as the current user.

Run the playbook to apply the configuration:

`ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml`

### Dry Runs

To see what changes would be made without actually executing them, use the `--check` flag:

`ansible-playbook -i ops/mac/inventory ops/mac/playbook.yml --check`

## Post-Playbook Steps

- Open 1Password and sign in (needed for SSH agent)
- Run `tmux` then `prefix + I` to install tmux plugins
- Restart terminal to pick up zsh config
