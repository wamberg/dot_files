---
name: using-git-worktrees
description: Create isolated git worktrees for feature work with project setup and test verification
---

# Using Git Worktrees

## Overview

Create an isolated workspace using git worktrees. The worktree shares the same repository but has its own checked-out files on a separate branch.

**Worktree location:** `.worktrees/` inside the project root (gitignored).

## Steps

### 1. Verify `.worktrees/` Is Gitignored

```bash
git check-ignore -q .worktrees 2>/dev/null
```

**If NOT ignored:**

1. Add `.worktrees/` to `.gitignore`
2. Commit the change: `git commit -m "chore: gitignore .worktrees/"`
3. Proceed

### 2. Create the Worktree

```bash
mkdir -p .worktrees
git worktree add ".worktrees/$FEATURE_NAME" -b "feature/$FEATURE_NAME"
```

### 3. Run Project Setup

Auto-detect and run the appropriate setup:

```bash
cd ".worktrees/$FEATURE_NAME"

# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then pip install -e . || poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi

# Nix — skip setup, the devshell handles dependencies.
# The dispatch skill launches pi inside `nix develop` when a flake is detected.
if [ -f flake.nix ]; then echo "Nix flake detected — skipping setup (devshell handles dependencies)"; fi
```

**If setup fails or no setup is detected:**

```
Setup issue: [describe what happened]

Fix the setup in .worktrees/$FEATURE_NAME and tell me to continue.
I'll re-run the tests to verify before proceeding.
```

**Wait for the user.** Do not proceed until they confirm.

### 4. Run Baseline Tests

```bash
# Auto-detect test command
if [ -f package.json ]; then npm test; fi
if [ -f Cargo.toml ]; then cargo test; fi
if [ -f pytest.ini ] || [ -f pyproject.toml ]; then pytest; fi
if [ -f go.mod ]; then go test ./...; fi
```

**If tests pass:** Report the count and proceed.

**If tests fail:**

```
Baseline tests failing ([N] failures):

[Show failures]

Fix the issues in .worktrees/$FEATURE_NAME and tell me to continue.
I'll re-run the tests to verify.
```

**Wait for the user.** Do not proceed until tests pass or the user explicitly says to skip.

### 5. Report Ready

```
Worktree ready at .worktrees/$FEATURE_NAME (branch: feature/$FEATURE_NAME)
Tests passing ([N] tests, 0 failures)
```

## Common Mistakes

**Skipping ignore verification.** Worktree contents get tracked, pollute git status. Always verify with `git check-ignore`.

**Proceeding with failing tests.** You can't distinguish new bugs from pre-existing issues. Stop, let the user fix it, verify again.

**Assuming setup commands.** Projects vary. Auto-detect from project files. When detection fails, ask.

## Integration

**Called by:**

- **dispatch** — to create isolated workspace before launching agent

**Pairs with:**

- **finishing-a-development-branch** — cleans up worktree after work is complete
