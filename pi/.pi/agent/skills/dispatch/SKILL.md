---
name: dispatch
description: Dispatch an implementation plan to a fresh agent in an isolated git worktree via tmux
---

# Dispatch

## Overview

Create an isolated worktree, open a new tmux window, and launch a fresh Pi agent with a directive to execute an implementation plan.

**Announce at start:** "I'm using the dispatch skill to set up an isolated agent."

## Prerequisites

- You are inside a tmux session
- The plan is committed to git (both `design.md` and `implementation.md` in `docs/plans/YYYY-MM-DD-<feature-name>/`)
- The current branch is clean (no uncommitted plan files)

## Steps

### 1. Verify Tmux

```bash
if [ -z "$TMUX" ]; then
  echo "Not inside a tmux session. Start tmux first."
  exit 1
fi
```

If not in tmux, tell the user and stop.

### 2. Commit Uncommitted Plan Files

Check for uncommitted plan docs:

```bash
git status --porcelain docs/plans/
```

If there are uncommitted changes in the plan directory, commit them:

```bash
git add "docs/plans/$PLAN_DIR/"
git commit -m "docs: add plan for $FEATURE_NAME"
```

### 3. Create Worktree

Invoke the **using-git-worktrees** skill with the feature name. Wait for it to complete — this includes setup and baseline test verification.

### 4. Launch Agent in New Tmux Window

```bash
WORKTREE_PATH=".worktrees/$FEATURE_NAME"
PLAN_PATH="docs/plans/$PLAN_DIR/implementation.md"

# Create a new tmux window named after the feature, starting in the worktree
tmux new-window -n "$FEATURE_NAME" -c "$WORKTREE_PATH"

# Launch pi — inside nix devshell if the project uses a flake
if [ -f "$WORKTREE_PATH/flake.nix" ]; then
  tmux send-keys -t "$FEATURE_NAME" "nix develop -c pi \"Implement the plan in $PLAN_PATH using the executing-plans skill\"" Enter
else
  tmux send-keys -t "$FEATURE_NAME" "pi \"Implement the plan in $PLAN_PATH using the executing-plans skill\"" Enter
fi
```

### 5. Report to User

```
Agent dispatched in tmux window "$FEATURE_NAME"

To monitor:
  Ctrl+b, then select window "$FEATURE_NAME"

The agent will notify you if it hits a blocker.
You can continue working in this session.
```

### 6. Return Control

The dispatch is complete. Return control to the user in the current session. Do not wait for the dispatched agent to finish.

## Common Mistakes

**Forgetting to commit the plan.** The worktree branches from the current commit. If the plan isn't committed, the executing agent can't find it.

**Creating the worktree before verifying setup.** The using-git-worktrees skill handles setup and test verification. Don't skip it.

**Blocking on the dispatched agent.** Your job is to dispatch and return. The user decides what to do next.

## Integration

**Called by:**
- **writing-plans** — after plan is saved and user confirms dispatch

**Invokes:**
- **using-git-worktrees** — to create the isolated workspace
