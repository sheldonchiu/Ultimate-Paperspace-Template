#!/bin/bash

format_log() {
    # Get the current date and time in ISO format
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Output the log message
    printf "[$timestamp] $1\n"
}

log() {
    echo "$(format_log "$1")"
}

send_to_discord() {
  output=$(format_log "$1")

  echo "$output"
  if [[ -n $DISCORD_WEBHOOK_URL ]]; then
    # Send the message using curl
    curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\":\"$output\"}" \
        "${DISCORD_WEBHOOK_URL}" 2>&1 > /dev/null
  fi
}