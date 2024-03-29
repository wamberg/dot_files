# Ansible Setup

## Fresh Install

Run the following commands in this order:

1. In `ops/`, run `ansible-galaxy install -r requirements.yml`.

## Development

1. Ensure `molecule` with: `pip install --user molecule[docker]`.
2. In `ops/<role>/`, run `molecule create`.
3. Edit code in `ops/<role/`.
4. In `ops/<role>`, run `molecule converge`.

## Run on Machine

1. `sudo apt install ansible git`
2. Move ssh key to machine
3. As wamberg, in dev/ director `git clone git@github.com:wamberg/dot_files.git`
4. In dot_files/ops, `sudo ansible-galaxy install -r requirements.yml `
5. In dot_files/ops, `sudo ansible-playbook ./playbook.yml`
6. After ansible runs, in /opt/lvim,
   `./utils/installer/install-neovim-from-release; ./utils/installer/install.sh`
7. Install Zoom https://zoom.us/download?os=linux
8. Install Teams
   https://www.microsoft.com/en-us/microsoft-teams/download-app#desktopAppDownloadregion
