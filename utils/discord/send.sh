#!/bin/bash

echo $1
if [[ -n $DISCORD_WEBHOOK_URL ]]; then
  # Send the message using curl
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\":\"$1\"}" \
       "${DISCORD_WEBHOOK_URL}"
fi