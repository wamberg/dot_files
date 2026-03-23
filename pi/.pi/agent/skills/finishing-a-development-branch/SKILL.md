---
name: finishing-a-development-branch
description: Use when implementation is complete and tests pass — guides integration, cleanup, and worktree removal
---

# Finishing a Development Branch

## Overview

Verify tests, present integration options, execute the chosen workflow, and clean up the worktree and branch.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

Run the project's test suite:

```bash
# Auto-detect
npm test || cargo test || pytest || go test ./...
```

**If tests fail:** Stop. Report failures. Do not present options until tests pass.

**If tests pass:** Continue.

### Step 2: Determine Base Branch

```bash
# Detect the base branch
git merge-base --is-ancestor HEAD main 2>/dev/null && BASE=main
git merge-base --is-ancestor HEAD master 2>/dev/null && BASE=master
```

If unclear, ask: "This branch split from main — is that correct?"

### Step 3: Present Options

Present exactly these 4 options:

```
Implementation complete. All tests passing. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work
```

### Step 4: Execute Choice

#### Option 1: Merge Locally

```bash
WORKTREE_PATH=$(pwd)
FEATURE_BRANCH=$(git branch --show-current)

# Move to the main worktree
cd "$(git worktree list --porcelain | head -1 | sed 's/worktree //')"

# Merge
git checkout "$BASE"
git pull
git merge "$FEATURE_BRANCH"

# Verify tests on merged result
<test command>

# Clean up worktree and branch
git worktree remove "$WORKTREE_PATH"
git branch -d "$FEATURE_BRANCH"
```

Report: "Merged `feature/X` into `<base>`. Worktree and branch cleaned up."

#### Option 2: Push and Create PR

```bash
git push -u origin "$(git branch --show-current)"

# Create PR if gh is available
if command -v gh &>/dev/null; then
  gh pr create --title "<title>" --body "<summary>"
fi
```

**Keep the worktree and branch alive** — the user may need them for PR revisions.

Report: "PR created. Worktree kept at `.worktrees/<feature>` for revisions."

#### Option 3: Keep As-Is

Do nothing. Report: "Branch and worktree preserved. You can return to it anytime."

#### Option 4: Discard

**Confirm first:**

```
This will permanently delete:
- Branch: feature/<name>
- All commits on that branch
- Worktree at .worktrees/<name>

Are you sure? (yes/no)
```

**Wait for explicit "yes".** Do not proceed on anything else.

If confirmed:

```bash
WORKTREE_PATH=$(pwd)
FEATURE_BRANCH=$(git branch --show-current)

# Move to the main worktree
cd "$(git worktree list --porcelain | head -1 | sed 's/worktree //')"

git checkout "$BASE"
git worktree remove --force "$WORKTREE_PATH"
git branch -D "$FEATURE_BRANCH"
```

Report: "Work discarded. Worktree and branch removed."

## Quick Reference

| Option           | Merge | Push | Keep Worktree | Clean Up Branch |
| ---------------- | ----- | ---- | ------------- | --------------- |
| 1. Merge locally | ✓     | —    | Remove        | Delete          |
| 2. Create PR     | —     | ✓    | Keep          | Keep            |
| 3. Keep as-is    | —     | —    | Keep          | Keep            |
| 4. Discard       | —     | —    | Remove        | Force delete    |

## Common Mistakes

**Proceeding with failing tests.** Never offer options until tests pass.

**Auto-confirming discard.** Always require explicit "yes" confirmation. Work cannot be recovered.

**Cleaning up worktree for PRs.** The user may need the worktree for revisions after PR feedback. Keep it.

**Forgetting to verify tests after merge.** A clean merge doesn't mean working code. Run the test suite on the merged result.

## Integration

**Called by:**

- **executing-plans** — after all tasks complete and tests pass

**Pairs with:**

- **using-git-worktrees** — cleans up the worktree created by that skill
