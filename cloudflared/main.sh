#!/bin/bash

cd /tmp

if ! [ -e "/tmp/cloudflared.prepared" ]; then
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb
    touch /tmp/cloudflared.prepared
fi

function send_discord_message() {
  # Your Discord webhook URL
  local webhook_url="$DISCORD_WEBHOOK_URL"

  # Message to send
  local message="$2"

  # Send the message using curl
  curl -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\":\"${message}\"}" \
       "${webhook_url}"
}

if [ "${CF_TOKEN}" = "quick" ]; then
    # Split EXPOSE_PORTS into an array using ':' as the delimiter
    IFS=':' read -ra ports <<< "$EXPOSE_PORTS"

    # Loop over the ports array
    for var in "${ports[@]}"; do
        if [ "$var" = "" ]; then
            continue
        fi
        metrics_port=$((var+1))

        # Generate PID file and log file names using a different delimiter
        pidfile="/tmp/cloudflared_${var}.pid"
        logfile="/tmp/cloudflared_${var}.log"
        hostfile="/tmp/cloudflared_${var}.host"

        # Start cloudflared tunnel in the background
        nohup cloudflared tunnel --url http://localhost:${var} --metrics localhost:${metrics_port} --pidfile "$pidfile" > "$logfile" 2>&1 &

        # Wait for the tunnel to become available
        retries=0
        max_retries=10
        while true; do
            response=$(curl http://localhost:${metrics_port}/quicktunnel || true)
            if [ $? -eq 0 ] && [ "$(echo "$response" | jq -r '.hostname')" != "" ]; then
                hostname=$(echo "$response" | jq -r '.hostname')
                echo "Success! Hostname is $hostname"
                echo $hostname > $hostfile
                if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
                    send_discord_message "Cloudflared: Hostname is $hostname"
                fi
                break
            fi
            retries=$((retries+1))
            if [ $retries -ge $max_retries ]; then
                echo "Error: Failed to get response after $max_retries attempts"
                if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
                    send_discord_message "Cloudflared: Failed to get response after $max_retries attempts"
                fi
                exit 1
            fi
            echo "Failed to get response. Retrying in 5 seconds..."
            sleep 5
        done
    done
else
    cloudflared service install "$CF_TOKEN"
fi