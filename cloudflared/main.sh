#!/bin/bash

cd /tmp

if ! [ -e "/tmp/cloudflared.prepared" ]; then
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb
    touch /tmp/cloudflared.prepared
fi

if [ "${CF_TOKEN}" = "quick" ]; then
    # Split EXPOSE_PORTS into an array using ':' as the delimiter
    IFS=':' read -ra names <<< "$PORT_MAPPING"
    IFS=':' read -ra ports <<< "$EXPOSE_PORTS"

    # Loop over the ports array
    paste <(printf '%s\n' "${names[@]}") <(printf '%s\n' "${ports[@]}") | while IFS=$'\t' read -r name port; do
    # for var in "${ports[@]}"; do
        if [ "$port" = "" ]; then
            continue
        fi
        metrics_port=$((port+1))

        # Generate PID file and log file names using a different delimiter
        pidfile="/tmp/cloudflared_${name}.pid"
        logfile="/tmp/cloudflared_${name}.log"
        hostfile="/tmp/cloudflared_${name}.host"

        # Start cloudflared tunnel in the background
        nohup cloudflared tunnel --url http://localhost:${port} --metrics localhost:${metrics_port} --pidfile "$pidfile" > "$logfile" 2>&1 &

        # Wait for the tunnel to become available
        retries=0
        max_retries=10
        while true; do
            response=$(curl http://localhost:${metrics_port}/quicktunnel || true)
            if [ $? -eq 0 ] && [ "$(echo "$response" | jq -r '.hostname')" != "" ]; then
                hostname=$(echo "$response" | jq -r '.hostname')
                echo $hostname > $hostfile
                bash $SCRIPT_ROOT_DIR/utils/discord/send.sh "Cloudflared: Hostname is $hostname for $name"
                break
            fi
            retries=$((retries+1))
            if [ $retries -ge $max_retries ]; then
                echo "Error: Failed to get response after $max_retries attempts"
                bash $SCRIPT_ROOT_DIR/utils/discord/send.sh "Cloudflared: Failed to get response after $max_retries attempts"
                break
            fi
            echo "Failed to get response. Retrying in 5 seconds..."
            sleep 5
        done
    done
else
    cloudflared service install "$CF_TOKEN"
    bash $SCRIPT_ROOT_DIR/utils/discord/send.sh "Cloudflared: Running as a service"
fi