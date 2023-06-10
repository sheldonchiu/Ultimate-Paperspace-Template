#!/bin/bash

format_log() {
    # Get the current date and time in ISO format
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Get the full file path and line number of the current script
    script_path=$(realpath "${BASH_SOURCE[1]}")

    # Output the log message
    printf "[$timestamp] [$script_path] $1\n"
}

log() {
    echo "$(format_log "$1")"
}

send_to_discord() {
  output=$(format_log "$1")

  printf "$output"
  if [[ -n $DISCORD_WEBHOOK_URL ]]; then
    # Send the message using curl
    curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\":\"$output\"}" \
        "${DISCORD_WEBHOOK_URL}"
  fi
}