# claude-switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `claudectx` with a simple symlink-based profile switcher that preserves `enabledPlugins` across switches.

**Architecture:** Split the current `claude/` stow package into `claude-code-cli/` (CLI managed settings + profiles) and `claude-desktop/` (Desktop app config). A shell script (`,claude-switch.sh`) symlinks `~/.claude/settings.json` to the selected profile's settings file in the dot_files repo. Playbooks updated to remove claudectx and stow the new directories.

**Tech Stack:** Bash, fzf, stow, Ansible

---

### Task 1: Unstow old claude/ package from current machine

**Files:**
- None (runtime state only)

This must happen before removing `claude/` from the repo, since stow needs the package directory to exist for unstow.

- [ ] **Step 1: Unstow claude/ from $HOME and /etc**

```bash
cd ~/dev/dot_files
stow --no-folding --target="$HOME/" --ignore="etc" -D claude 2>/dev/null || true
sudo stow --no-folding --target="/" --ignore=".claude" -D claude 2>/dev/null || true
```

- [ ] **Step 2: Verify symlinks are removed**

```bash
ls -la ~/.claude/profiles/ 2>/dev/null
# Expected: directory should not exist or not be a symlink

ls -la /etc/claude-code/managed-settings.json 2>/dev/null
# Expected: file should not exist or not be a symlink
```

No commit needed -- this is local machine state.

---

### Task 2: Create directory structure and move files

**Files:**
- Create: `claude-code-cli/etc/claude-code/managed-settings.json`
- Create: `claude-code-cli/profiles/pbs-api/settings.json`
- Create: `claude-code-cli/profiles/pbs-sub/settings.json`
- Create: `claude-desktop/.config/Claude/claude_desktop_config.json`
- Create: `claude-desktop/.local/share/applications/claude-desktop.desktop`
- Delete: `claude/` (entire directory after moving contents)

- [ ] **Step 1: Create the new directory structure**

```bash
mkdir -p claude-code-cli/etc/claude-code
mkdir -p claude-code-cli/profiles/pbs-api
mkdir -p claude-code-cli/profiles/pbs-sub
mkdir -p claude-desktop/.config/Claude
mkdir -p claude-desktop/.local/share/applications
```

- [ ] **Step 2: Move managed-settings.json**

```bash
cp claude/etc/claude-code/managed-settings.json claude-code-cli/etc/claude-code/managed-settings.json
```

- [ ] **Step 3: Move profile settings files and add enabledPlugins**

Copy `claude/.claude/profiles/pbs-api/settings.json` to `claude-code-cli/profiles/pbs-api/settings.json` with `enabledPlugins` added:

```json
{
  "env": {
    "ANTHROPIC_SMALL_FAST_MODEL": "us.anthropic.claude-haiku-4-5-20251001-v1:0",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "16384",
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "MAX_THINKING_TOKENS": "10000"
  },
  "model": "us.anthropic.claude-opus-4-6-v1[1m]",
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

Copy `claude/.claude/profiles/pbs-sub/settings.json` to `claude-code-cli/profiles/pbs-sub/settings.json` with `enabledPlugins` added:

```json
{
  "env": {
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "16384",
    "MAX_THINKING_TOKENS": "10000"
  },
  "model": "opus[1m]",
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

- [ ] **Step 4: Move Claude Desktop files**

```bash
cp claude/.config/Claude/claude_desktop_config.json claude-desktop/.config/Claude/claude_desktop_config.json
cp claude/.local/share/applications/claude-desktop.desktop claude-desktop/.local/share/applications/claude-desktop.desktop
```

- [ ] **Step 5: Remove old claude/ directory**

```bash
git rm -r claude/
```

- [ ] **Step 6: Commit**

```bash
git add claude-code-cli/ claude-desktop/
git commit -m "refactor: split claude/ into claude-code-cli/ and claude-desktop/"
```

---

### Task 3: Write the claude-switch script

**Files:**
- Create: `bin/.bin/,claude-switch.sh`

- [ ] **Step 1: Write the script**

Create `bin/.bin/,claude-switch.sh`:

```bash
#!/usr/bin/env bash
set -e

PROFILES_DIR="$HOME/dev/dot_files/claude-code-cli/profiles"
TARGET="$HOME/.claude/settings.json"

# List available profiles
profiles=()
for dir in "$PROFILES_DIR"/*/; do
    [ -f "$dir/settings.json" ] && profiles+=("$(basename "$dir")")
done

if [ ${#profiles[@]} -eq 0 ]; then
    echo "No profiles found in $PROFILES_DIR" >&2
    exit 1
fi

# Select profile: use argument or fzf
if [ -n "$1" ]; then
    profile="$1"
    # Validate the argument is a known profile
    found=false
    for p in "${profiles[@]}"; do
        [ "$p" = "$profile" ] && found=true && break
    done
    if [ "$found" = false ]; then
        echo "Unknown profile: $profile" >&2
        echo "Available: ${profiles[*]}" >&2
        exit 1
    fi
else
    profile=$(printf '%s\n' "${profiles[@]}" | fzf --prompt="Claude profile: ")
    [ -z "$profile" ] && exit 0
fi

source="$PROFILES_DIR/$profile/settings.json"
ln -sf "$source" "$TARGET"
echo "Switched to $profile"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x bin/.bin/,claude-switch.sh
```

- [ ] **Step 3: Test the script manually**

```bash
# List profiles (no fzf, pass argument directly)
bin/.bin/,claude-switch.sh pbs-api

# Verify symlink
ls -la ~/.claude/settings.json
# Expected: ~/.claude/settings.json -> /home/wamberg/dev/dot_files/claude-code-cli/profiles/pbs-api/settings.json

# Verify content
cat ~/.claude/settings.json
# Expected: pbs-api settings with enabledPlugins

# Switch to other profile
bin/.bin/,claude-switch.sh pbs-sub
ls -la ~/.claude/settings.json
# Expected: ~/.claude/settings.json -> /home/wamberg/dev/dot_files/claude-code-cli/profiles/pbs-sub/settings.json

# Test invalid profile
bin/.bin/,claude-switch.sh nonexistent
# Expected: "Unknown profile: nonexistent" and exit 1
```

- [ ] **Step 4: Commit**

```bash
git add bin/.bin/,claude-switch.sh
git commit -m "feat: add claude-switch profile switcher script"
```

---

### Task 4: Update Arch playbook

**Files:**
- Modify: `ops/arch/inventory/group_vars/all.yml`
- Modify: `ops/arch/roles/common/tasks/main.yml`

- [ ] **Step 1: Remove claudectx-bin from AUR packages**

In `ops/arch/inventory/group_vars/all.yml`, remove `claudectx-bin` from `aur_cli_packages`:

```yaml
aur_cli_packages:
  - claude-code
  - whisper.cpp
  - whisper.cpp-model-medium.en
  - whisper.cpp-model-small.en-tdrz
```

- [ ] **Step 2: Replace claude with claude-desktop in stow_packages_common**

In `ops/arch/inventory/group_vars/all.yml`, change `claude` to `claude-desktop` in `stow_packages_common`:

```yaml
stow_packages_common:
  - bat
  - bin
  - btop
  - claude-desktop
  - fuzzel
  - git
  - kitty
  - mise
  - mpv
  - niri
  - npm
  - nvim
  - sql
  - swappy
  - tinty
  - tz
  - tmux
  - vifm
  - waybar
  - zsh
```

- [ ] **Step 3: Update stow tasks in common/tasks/main.yml**

Remove the `difference(['claude'])` filter from the main stow loop (line 142) since `claude` is no longer in the list:

Replace:
```yaml
- name: User | {{ username }} | Stow dot_files
  become: yes
  become_user: "{{ username }}"
  become_flags: "--login"
  ansible.builtin.shell: 'stow --no-folding --dir="${HOME}/dev/dot_files" --target="${HOME}/" -vS {{ item }}'
  loop: "{{ (stow_packages_common + stow_packages_host | default([])) | difference(['claude']) }}"
  register: stow_result
  changed_when: stow_result.stdout != ""
  tags:
    - dev
```

With:
```yaml
- name: User | {{ username }} | Stow dot_files
  become: yes
  become_user: "{{ username }}"
  become_flags: "--login"
  ansible.builtin.shell: 'stow --no-folding --dir="${HOME}/dev/dot_files" --target="${HOME}/" -vS {{ item }}'
  loop: "{{ stow_packages_common + stow_packages_host | default([]) }}"
  register: stow_result
  changed_when: stow_result.stdout != ""
  tags:
    - dev
```

- [ ] **Step 4: Replace the two claude stow tasks with one claude-code-cli task**

Remove these two tasks (lines 148-163):
```yaml
- name: User | {{ username }} | Stow claude to $HOME (skip etc/)
  ...
- name: System | Stow claude managed settings to /etc
  ...
```

Replace with:
```yaml
- name: System | Stow claude-code-cli managed settings to /etc
  ansible.builtin.shell: 'stow --no-folding --dir="/home/{{ username }}/dev/dot_files" --target="/" --ignore="profiles" -vS claude-code-cli'
  register: stow_claude_code_cli
  changed_when: stow_claude_code_cli.stdout != ""
  tags:
    - dev
```

- [ ] **Step 5: Commit**

```bash
git add ops/arch/inventory/group_vars/all.yml ops/arch/roles/common/tasks/main.yml
git commit -m "ops/arch: replace claudectx with claude-switch, split claude stow packages"
```

---

### Task 5: Update Mac playbook

**Files:**
- Modify: `ops/mac/playbook.yml`

- [ ] **Step 1: Remove foxj77 tap**

Delete this task (lines 8-11):
```yaml
    - name: Packages | Tap foxj77 (claudectx)
      community.general.homebrew_tap:
        name: foxj77/tap
        state: present
```

- [ ] **Step 2: Remove claudectx from brew packages**

In the "Install Homebrew formulae" task, remove `claudectx` from the name list.

- [ ] **Step 3: Replace claude stow-to-home task**

Replace the task "Setup | Stow claude to $HOME (skip etc/)" (lines 110-118):

```yaml
    - name: Setup | Stow claude to $HOME (skip etc/)
      ansible.builtin.shell: >
        stow --dir="{{ ansible_facts['env']['HOME'] }}/dev/dot_files"
        --target="{{ ansible_facts['env']['HOME'] }}/"
        --restow --no-folding --verbose=1
        --ignore="etc"
        claude
      register: stow_claude_home
      changed_when: stow_claude_home.stderr != ""
```

With:

```yaml
    - name: Setup | Stow claude-desktop to $HOME
      ansible.builtin.shell: >
        stow --dir="{{ ansible_facts['env']['HOME'] }}/dev/dot_files"
        --target="{{ ansible_facts['env']['HOME'] }}/"
        --restow --no-folding --verbose=1
        claude-desktop
      register: stow_claude_desktop
      changed_when: stow_claude_desktop.stderr != ""
```

- [ ] **Step 4: Update managed-settings symlink source path**

Change the symlink source in "Setup | Symlink Claude Code managed settings" (line 130) from:
```yaml
        src: "{{ ansible_facts['env']['HOME'] }}/dev/dot_files/claude/etc/claude-code/managed-settings.json"
```
To:
```yaml
        src: "{{ ansible_facts['env']['HOME'] }}/dev/dot_files/claude-code-cli/etc/claude-code/managed-settings.json"
```

- [ ] **Step 5: Commit**

```bash
git add ops/mac/playbook.yml
git commit -m "ops/mac: replace claudectx with claude-switch, split claude stow packages"
```

---

### Task 6: Stow new packages and activate profile on current machine

**Files:**
- None (runtime state only)

- [ ] **Step 1: Stow the new packages**

```bash
stow --no-folding --target="$HOME/" -vS claude-desktop
sudo stow --no-folding --target="/" --ignore="profiles" -vS claude-code-cli
```

- [ ] **Step 2: Run claude-switch to set the active profile**

```bash
,claude-switch.sh pbs-api
```

- [ ] **Step 3: Verify**

```bash
# Symlink points to profile
ls -la ~/.claude/settings.json
# Expected: -> /home/wamberg/dev/dot_files/claude-code-cli/profiles/pbs-api/settings.json

# Desktop config still works
ls -la ~/.config/Claude/claude_desktop_config.json
# Expected: -> /home/wamberg/dev/dot_files/claude-desktop/.config/Claude/claude_desktop_config.json

# Managed settings still works
ls -la /etc/claude-code/managed-settings.json
# Expected: -> /home/wamberg/dev/dot_files/claude-code-cli/etc/claude-code/managed-settings.json

# Content is correct
cat ~/.claude/settings.json
# Expected: pbs-api settings with enabledPlugins
```

No commit needed -- this is local machine state.
