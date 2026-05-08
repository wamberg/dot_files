#!/usr/bin/env bash
set -euo pipefail

mode="${1:-auto}"   # 'auto' (hook-driven, throttled) or 'manual' (slash command, no throttle)

# Per-session opt-out
[ "${GARDEN_LOG_DISABLED:-0}" = "1" ] && exit 0

# Hook events pipe JSON on stdin; manual invocation has no stdin.
if [ "$mode" = "auto" ]; then
  input=$(cat)
  transcript_path=$(jq -r '.transcript_path // empty' <<<"$input")
  session_id=$(jq -r '.session_id // empty' <<<"$input")
  cwd=$(jq -r '.cwd // empty' <<<"$input")
else
  cwd="$PWD"
  # Find the most recent transcript JSONL for this cwd. CC encodes the cwd
  # by replacing every non-alphanumeric character with '-' under ~/.claude/projects/.
  encoded=$(echo "$cwd" | sed 's|[^a-zA-Z0-9-]|-|g')
  proj_dir="$HOME/.claude/projects/$encoded"
  transcript_path=$(ls -t "$proj_dir"/*.jsonl 2>/dev/null | head -n 1 || true)
  session_id=""   # unused in manual mode
fi

[ -n "$transcript_path" ] && [ -f "$transcript_path" ] || exit 0

# 30-minute throttle, shared by idle_prompt and SessionEnd. Skipped in manual mode.
if [ "$mode" = "auto" ] && [ -n "$session_id" ]; then
  state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/garden-log"
  mkdir -p "$state_dir"
  state_file="$state_dir/$session_id.last"
  now=$(date +%s)
  if [ -f "$state_file" ]; then
    last=$(cat "$state_file")
    (( now - last < 1800 )) && exit 0
  fi
fi

# Skip if today's diary doesn't exist
diary_dir="${GARDEN_DIARY_DIR:-$HOME/dev/garden/diary}"
diary_file="$diary_dir/$(date +%Y-%m-%d).md"
[ -f "$diary_file" ] || exit 0

project=$(basename "${cwd:-$PWD}")
project_md=${project//_/\\\\_}   # double-escape: bash → awk -v → markdown emits "\_"

# Last ~100 user/assistant turns, flattened to plain text
turns=$(jq -r '
  select(.type == "user" or .type == "assistant")
  | .type + ": " + (
      if (.message.content | type) == "string" then .message.content
      else (.message.content // [] | map(.text // "") | join(" "))
      end
    )' "$transcript_path" | tail -n 100)

[ -n "$turns" ] || exit 0

prompt='Summarize the recent conversation turns in exactly 3 sentences. Focus on (a) the current state of work and (b) what we are trying to accomplish next. Output only the summary, no preamble.'

summary=$(printf '%s\n\n%s' "$prompt" "$turns" | claude -p --model claude-haiku-4-5 2>/dev/null) || exit 0
[ -n "$summary" ] || exit 0

# Insert into ## Log section, before next ## heading (or at file end)
ts=$(date +%H:%M)
entry=$(printf '\n### %s - _%s_ (summary)\n\n%s\n' "$ts" "$project_md" "$summary")

tmp=$(mktemp)
awk -v entry="$entry" '
  BEGIN { in_log = 0; printed = 0 }
  /^## Log[[:space:]]*$/ { in_log = 1; print; next }
  in_log && /^## / { print entry; in_log = 0; printed = 1 }
  { print }
  END { if (in_log && !printed) print entry }
' "$diary_file" > "$tmp" && mv "$tmp" "$diary_file"

# Stamp throttle only after a successful auto-mode write
if [ "$mode" = "auto" ] && [ -n "${session_id:-}" ]; then
  echo "$now" > "$state_file"
fi
