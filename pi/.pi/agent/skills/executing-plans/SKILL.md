---
name: executing-plans
description: Use when you have a written implementation plan to execute — follows the plan step by step, commits at natural boundaries, and notifies on failure
---

# Executing Plans

## Overview

Load a plan, review it critically, then execute it step by step. Commit at natural boundaries. Stop and notify the user on any failure.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan

1. Read the implementation plan file
2. Read the companion `design.md` in the same directory for full context
3. Review critically — identify any questions or concerns
4. If concerns: Raise them and **stop**. Do not guess. Wait for clarification.
5. If no concerns: Proceed to execution

### Step 2: Execute Steps

Follow each step in the plan exactly. Do not skip steps. Do not reorder steps.

**Commit at natural boundaries:** When you have implemented something and its tests pass, commit. A natural boundary is typically:

- A test is written, implementation makes it pass → commit
- A configuration change is made and verified → commit
- A refactor is complete and all existing tests still pass → commit

The plan's explicit "Commit" steps are your guide, but use judgment — if the plan groups work into a commit, follow that grouping.

**Do not stop for manual review between commits.** Execute continuously until the plan is complete or you hit a problem.

### Step 3: Handle Failures

When something goes wrong — tests fail, a command errors, an instruction is unclear, a dependency is missing — **stop immediately**.

Do not retry more than once. Do not attempt workarounds the plan doesn't describe.

**Notify the user:**

```bash
# Terminal bell — tmux will flag the window
printf '\a'

# Desktop notification if available
if command -v notify-send &>/dev/null; then
  notify-send "Pi Agent" "Blocker in $(basename $(pwd)): [brief description]"
fi

# Tmux status message
if [ -n "$TMUX" ]; then
  tmux display-message "Agent blocked in $(tmux display-message -p '#W')"
fi
```

Then report what happened:

```
BLOCKED: [what failed]

What I was doing: [step N of task M]
Error: [the actual error output]
What I tried: [if you retried once, say so]

Waiting for your help.
```

**Wait. Do not continue until the user responds.**

### Step 4: Completion

After all tasks are complete:

1. Run the full test suite one final time
2. If tests pass: invoke **finishing-a-development-branch** skill
3. If tests fail: treat as a failure (Step 3) — notify and wait

## Key Rules

- **Follow the plan exactly.** The plan was written with full context. Trust it.
- **Commit early, commit often.** Every passing test boundary is a checkpoint you can roll back to.
- **Stop on failure, don't guess.** A wrong guess wastes more time than waiting for help.
- **Notify loudly.** The user may be in another tmux window. Use bell, notify-send, and tmux message.

## Integration

**Called by:**
- **dispatch** — launches this skill in a fresh agent session

**Invokes:**
- **finishing-a-development-branch** — after all tasks complete and tests pass
