#!/usr/bin/env bash

# Check if at least one argument (the endpoint URL) was provided
if [ -z "$1" ]; then
  echo "Usage: $0 ENDPOINT_URL [BASIC_AUTH_CREDENTIALS]"
  echo "Example: $0 http://example.com/your-endpoint username:password"
  exit 1
fi

# Endpoint is the first argument
ENDPOINT="$1"

# Basic auth credentials (username:password) are the second argument, if provided
BASIC_AUTH_CREDENTIALS="${2:-}"

# Function to retrieve the response
fetch_response() {
  local url="$1"
  local credentials="$2"
  if [ -n "$credentials" ]; then
    # With basic auth
    curl -s -u "$credentials" "$url"
  else
    # Without basic auth
    curl -s "$url"
  fi
}

# Initialize the variable to store the last response
LAST_RESPONSE=$(fetch_response "${ENDPOINT}" "${BASIC_AUTH_CREDENTIALS}")

echo "Monitoring the endpoint: ${ENDPOINT}"

# Loop indefinitely
while true; do
  # Fetch the current response from the endpoint
  CURRENT_RESPONSE=$(fetch_response "${ENDPOINT}" "${BASIC_AUTH_CREDENTIALS}")

  # Check if the response is different from the last response
  if [ "${CURRENT_RESPONSE}" != "${LAST_RESPONSE}" ]; then
    # Notify about the change
    notify-send --icon=dialog-information "curl-diff.sh" "The response from the endpoint has changed."

    # Update the last response to the current one
    LAST_RESPONSE="${CURRENT_RESPONSE}"
  fi

  # Wait for 2 seconds before the next request
  sleep 2
done
