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
