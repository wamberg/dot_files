# claude-switch: Claude Code Profile Switcher

## Problem

`claudectx` copies a profile's `settings.json` wholesale into `~/.claude/settings.json` on every switch. This overwrites runtime state like `enabledPlugins`, forcing manual re-enablement of plugins (e.g., superpowers) after every profile change.

`jean-claude` solves this by symlinking a shared `settings.json` across profiles, but that prevents per-profile settings (model, env vars) which is a hard requirement.

## Solution

A shell script (`,claude-switch.sh`) that writes a profile's `settings.json` to `~/.claude/settings.json`, resolving any 1Password secret references via `op inject`. Each profile's `settings.json` is the source of truth for all settings including `enabledPlugins`, so nothing is lost on switch.

## Script: `bin/.bin/,claude-switch.sh`

### Behavior

1. Read profile directory names from `~/dev/dot_files/claude-code-cli/profiles/`.
2. If a profile name is passed as an argument, use it. Otherwise, present the list via `fzf`.
3. Pipe the selected profile's `settings.json` through `op inject` to resolve any `{{ op://... }}` references.
4. Write the resolved output to `~/.claude/settings.json`.
5. Print which profile was activated.

### Notes

- If a profile has no `op://` references, `op inject` passes it through unchanged.
- The script does not manage MCP servers. Those are handled via `.mcp.json` with env var expansion at the project level.
- Profile switching only takes effect on the next `claude` launch (settings are read at startup, not mid-session).

### Dependencies

- `fzf` (interactive selection)
- `op` (1Password CLI, for secret injection)
- `jq` (not required -- `op inject` handles the templating)

## Directory Restructure

### Before

```
claude/
  .claude/profiles/pbs-api/settings.json
  .claude/profiles/pbs-sub/settings.json
  .config/Claude/claude_desktop_config.json
  .local/share/applications/claude-desktop.desktop
  etc/claude-code/managed-settings.json
```

### After

```
claude-code-cli/
  etc/claude-code/managed-settings.json
  profiles/
    pbs-api/settings.json
    pbs-sub/settings.json

claude-desktop/
  .config/Claude/claude_desktop_config.json
  .local/share/applications/claude-desktop.desktop
```

The `claude/` directory is removed. Its contents split into `claude-code-cli/` (CLI config and profiles) and `claude-desktop/` (Desktop app config).

## Playbook Changes

### Arch (`ops/arch/`)

- `inventory/group_vars/all.yml`: Remove `claudectx-bin` from `aur_cli_packages`.
- `roles/common/tasks/main.yml`:
  - Remove the two existing `claude` stow tasks (home + etc).
  - Add: stow `claude-code-cli` to `/` with `--ignore="profiles"` (deploys `etc/claude-code/managed-settings.json`).
  - Add: stow `claude-desktop` to `$HOME` (deploys `.config/Claude/` and `.local/share/applications/`).
- `inventory/group_vars/all.yml`: Replace `claude` with `claude-desktop` in `stow_packages_common` (stowed to `$HOME` in the common loop). `claude-code-cli` is stowed separately to `/` with the ignore flag.

### Mac (`ops/mac/playbook.yml`)

- Remove the `foxj77/tap` homebrew tap.
- Remove `claudectx` from brew packages.
- Replace `claude` stow tasks with:
  - Stow `claude-desktop` to `$HOME` (replaces the old `claude` stow-to-home task).
  - Update the managed-settings symlink source from `claude/etc/claude-code/managed-settings.json` to `claude-code-cli/etc/claude-code/managed-settings.json`. (Mac uses a direct symlink to `/Library/Application Support/ClaudeCode/`, not stow.)

## Profile settings.json Format

Each profile's `settings.json` is a valid Claude Code settings file with optional `{{ op://... }}` references for secrets. Example:

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

Profiles without secrets need no `op://` references and work as plain JSON.

## Out of Scope

- MCP server management (use `.mcp.json` with `${VAR}` env var expansion at project scope).
- Mid-session profile switching (not possible; settings are read at launch).
- Shared/layered settings merging (managed-settings.json at `/etc/claude-code/` already handles shared base config).
