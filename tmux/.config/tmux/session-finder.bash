#!/usr/bin/env bash
set -e
cmd=$1
prompt="find/create session> "
tmux='/usr/bin/env tmux'
debug=

if [ "$cmd" = "debug" ]; then
	debug=true
	cmd=$2
fi

session_status() {
	MAX=10
	counter=0
	colors=(yellow red green blue magenta cyan white)
	$tmux ls -F '#{session_attached} #{session_last_attached}#{?session_last_attached,,0} #{session_created} #{session_id} #{session_windows} #{session_name}' \
		| sort -r | cut -d' ' -f6- | head -n $MAX | while read line; do
		local colori=$(expr $counter % ${#colors})
		# TODO consider width of current window
		if [ "$counter" = 0 ]; then
			echo -n "#[bg=${colors[$colori]},fg=default]${line}#[bg=default]"
		else
			# Uncomment this string to show other session names as well
			echo -n "|#[fg=${colors[$colori]}]${line}#[fg=default,bg=default]"
		fi
		local counter=$((counter + 1))
	done
}

session_last() {
	$tmux switch-client -l && {
		sleep 0.1
		$tmux refresh-client -S
	} || true
}

session_most_recent() {
	# Get the most recently used session (excluding current session)
	current_session=$($tmux display-message -p '#S')
	most_recent_session=$($tmux ls -F '#{session_last_attached} #{session_name}' \
		| grep -v " $current_session$" \
		| sort -nr \
		| head -n1 \
		| cut -d' ' -f2)
	
	if [ -n "$most_recent_session" ]; then
		$tmux switch-client -t "$most_recent_session"
		sleep 0.1
		$tmux refresh-client -S
	else
		# Fallback to first session alphabetically if no other sessions
		first_session=$($tmux ls -F '#{session_name}' | grep -v "^$current_session$" | sort | head -n1)
		if [ -n "$first_session" ]; then
			$tmux switch-client -t "$first_session"
			sleep 0.1
			$tmux refresh-client -S
		fi
	fi
}

session_prev() {
	$tmux switch-client -p && {
		sleep 0.1
		$tmux refresh-client -S
	} || true
}

session_next() {
	$tmux switch-client -n && {
		sleep 0.1
		$tmux refresh-client -S
	} || true
}

session_finder() {
	# Get sessions sorted by last attached time, with current session first
	sessions=$($tmux ls -F '#{?session_attached,*,} #{session_name}' | sort -k2)
	
	# Use fzf to select or create a session
	selection=$(echo "$sessions" | fzf --print-query --prompt="$prompt" || true)
	
	# Handle the selection
	if [ -z "$selection" ]; then
		return  # User cancelled
	fi
	
	# Count lines in selection - if 2 lines, user selected existing session
	# If 1 line, user typed something and pressed enter without selecting
	line_count=$(echo "$selection" | wc -l)
	
	if [ "$line_count" -eq 2 ]; then
		# User selected an existing session (second line is the selection)
		selected=$(echo "$selection" | tail -n1)
		# Remove the * prefix if present and any leading/trailing whitespace
		session_name=$(echo "$selected" | sed 's/^\* *//' | sed 's/^ *//' | sed 's/ *$//')
		$tmux switch-client -t "$session_name"
	else
		# User typed a new session name (only query line exists)
		query=$(echo "$selection" | head -n1)
		# Handle special commands
		case "$query" in
			:new\ *)
				session_name=$(echo "$query" | cut -d' ' -f2-)
				$tmux new-session -d -s "$session_name"
				$tmux switch-client -t "$session_name"
				;;
			:rename\ *)
				session_name=$(echo "$query" | cut -d' ' -f2-)
				$tmux rename-session "$session_name"
				;;
			*)
				# Create new session with the query as name
				$tmux new-session -d -s "$query"
				$tmux switch-client -t "$query"
				;;
		esac
	fi
	
	sleep 0.1
	$tmux refresh-client -S
}

case "$cmd" in
	status)
		session_status
		;;
	finder)
		session_finder
		;;
	next)
		session_next
		;;
	prev)
		session_prev
		;;
	last)
		session_last
		;;
	most-recent)
		session_most_recent
		;;
	*)
		exit 1
		;;
esac
