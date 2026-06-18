#!/usr/bin/env bash
set -euo pipefail

mode="${1:-auto}"        # 'auto' (SessionEnd hook) or 'manual' (slash command)
guidance="${2:-}"        # optional freeform steer, manual mode only

# Per-session opt-out. Also set on the inner `claude -p` below so its own
# SessionEnd hook short-circuits, otherwise async mode lets the recursive
# spawn tree fork-bomb the system.
[ "${GARDEN_LOG_DISABLED:-0}" = "1" ] && exit 0

# Auto mode receives hook JSON on stdin; manual mode has no stdin.
if [ "$mode" = "auto" ]; then
  input=$(cat)
  transcript_path=$(jq -r '.transcript_path // empty' <<<"$input")
  cwd=$(jq -r '.cwd // empty' <<<"$input")
else
  cwd="$PWD"
  # Most recent transcript JSONL for this cwd. CC encodes the cwd by replacing
  # every non-alphanumeric character with '-' under ~/.claude/projects/.
  encoded=$(echo "$cwd" | sed 's|[^a-zA-Z0-9-]|-|g')
  proj_dir="$HOME/.claude/projects/$encoded"
  transcript_path=$(ls -t "$proj_dir"/*.jsonl 2>/dev/null | head -n 1 || true)
fi

[ -n "$transcript_path" ] && [ -f "$transcript_path" ] || exit 0

# Skip if today's diary doesn't exist (it must also contain a `## Log` heading).
diary_dir="${GARDEN_DIARY_DIR:-$HOME/dev/garden/diary}"
diary_file="$diary_dir/$(date +%Y-%m-%d).md"
[ -f "$diary_file" ] || exit 0

project=$(basename "${cwd:-$PWD}")

# Auto path only: skip trivial sessions. Real sessions run 20+ turns; a handful
# of turns means nothing worth logging happened. Manual invocation bypasses this.
if [ "$mode" = "auto" ]; then
  turn_count=$(jq -r 'select(.type == "user" or .type == "assistant") | .type' "$transcript_path" | wc -l)
  (( turn_count < 8 )) && exit 0
fi

# Last ~100 user/assistant turns, flattened to plain text
turns=$(jq -r '
  select(.type == "user" or .type == "assistant")
  | .type + ": " + (
      if (.message.content | type) == "string" then .message.content
      else (.message.content // [] | map(.text // "") | join(" "))
      end
    )' "$transcript_path" | tail -n 100)

[ -n "$turns" ] || exit 0

# Combined prompt: serves next-day handoff and retrospective brag mining at once.
prompt='Summarize this Claude Code session as a first-person work-log entry for my daily diary. Write 2 to 5 sentences of flowing prose. No headings, lists, or bullet points.

Cover, in this order:
1. What I accomplished and why it mattered: concrete changes, features built, problems solved, and their outcome or impact. Not just "worked on X".
2. A lesson or gotcha, only if a genuinely notable one came up. Otherwise omit it.
3. Where I left off and what I plan to do next, only if the work is unfinished.

Write in the first person ("I"), past tense. Omit routine setup, tool chit-chat, and anything you would not mention to a colleague.

Follow these prose rules: active voice; omit needless words; concrete nouns and verbs; straight quotes only, never curly quotes; no dashes for parenthetical asides, use commas or periods instead; start with the substance, no preamble.'

if [ "$mode" = "auto" ]; then
  prompt+='

If nothing substantive happened this session, output exactly SKIP and nothing else.'
fi

if [ -n "$guidance" ]; then
  prompt+='

The user specifically wants this emphasized: '"$guidance"
fi

prompt+='

Output only the summary, no preamble.'

# --tools "" disables all tool execution. The prompt is an arbitrary session
# transcript, so the summarizer must never be able to act on it (e.g. run git).
summary=$(printf '%s\n\n%s' "$prompt" "$turns" | GARDEN_LOG_DISABLED=1 claude -p --model claude-haiku-4-5 --tools "" 2>/dev/null) || exit 0
[ -n "$summary" ] || exit 0

# Auto path may decline a substanceless session.
if [ "$mode" = "auto" ] && [ "$(printf '%s' "$summary" | tr -d '[:space:]')" = "SKIP" ]; then
  exit 0
fi

# Insert into ## Log section, before next ## heading (or at file end)
ts=$(date +%H:%M)
entry=$(printf '\n### %s - _%s_ (claude)\n\n%s\n' "$ts" "$project" "$summary")

tmp=$(mktemp)
awk -v entry="$entry" '
  BEGIN { in_log = 0; printed = 0 }
  /^## Log[[:space:]]*$/ { in_log = 1; print; next }
  in_log && /^## / { print entry; in_log = 0; printed = 1 }
  { print }
  END { if (in_log && !printed) print entry }
' "$diary_file" > "$tmp" && mv "$tmp" "$diary_file"
