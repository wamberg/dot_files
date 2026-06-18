# dot_files

## Gotchas

### Obsidian Sync runs on Node 24, not the system Node

The headless Obsidian Sync client (`obsidian-headless`, binary `ob`) is installed
under a **mise-managed Node 24**, even though the system default is a newer Node.
This is deliberate: `obsidian-headless` bundles `better-sqlite3`, whose current
release has **no prebuilt binary for Node 26** and **fails to compile from source**
against Node 26's V8 API. Node 24 (LTS) has prebuilt binaries, so it just works.

Implications:
- `ob` must always be invoked as `mise exec node@24 -- ob ...` (the
  `obsidian-sync.service` ExecStart and the README bootstrap both do this).
- The Node 24 pin lives in `ops/arch/roles/obsidian-sync/`. Do **not** bump it past
  whatever `better-sqlite3` supports prebuilts for.
- Once `better-sqlite3` ships Node 26 prebuilts, this pin can be dropped and `ob`
  can run on the system Node again.

See `ops/arch/roles/obsidian-sync/` and `obsidian-sync/.config/systemd/user/`.

### `systemctl disable`/`reenable` deletes stow symlinks for user units

The systemd user units in this repo (e.g. `systemd/.config/systemd/user/`) are
linked into `~/.config/systemd/user/` by **GNU stow**, so the live unit file is a
symlink pointing back at the repo. systemd's `disable` logic removes *any*
symlink-to-unit it finds in the search dir, treating it as an enablement alias —
so **`systemctl --user disable` (and `reenable`, which disables first) will nuke
the stow symlink**, not just the `*.wants/` entry.

Implications:
- To re-link after this happens:
  `stow --no-folding --dir="$HOME/dev/dot_files" --target="$HOME/" -vS systemd`.
- To enable/change a unit's `[Install]` target, prefer creating the `*.wants/`
  symlink by hand, or use `systemctl --user enable` (which only *adds* symlinks).
  Avoid `disable`/`reenable` on stow-linked units.
- Ansible is safe here: the role uses the `systemd` module with `enabled: yes`
  (an `enable`, never a `disable`), so playbook re-runs won't trigger this.

### Wayland-dependent tmux sessions must start after `graphical-session.target`

`freya-sessions.service` creates the bazaar/garden tmux sessions. tmux freezes the
environment at *server* start and hands that frozen copy to every pane forever, so
the server must be created **after** `WAYLAND_DISPLAY` exists or `wl-copy`/`wl-paste`
break in every pane (falling back to a non-existent `wayland-0`). `niri --session`
imports `WAYLAND_DISPLAY` into the systemd user environment and only then reaches
`graphical-session.target` — so the service is bound to `graphical-session.target`
(not `default.target`, which is reached at login *before* the compositor). The
script also imports `WAYLAND_DISPLAY` from `systemctl --user show-environment` as
defense-in-depth. See `systemd/.config/systemd/user/freya-sessions.service` and
`bin/.bin/,freya-sessions.sh`.
