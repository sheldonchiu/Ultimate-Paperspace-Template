#!/bin/bash

cd /tmp

curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb

if [ "${CF_TOKEN}" = "quick" ]; then
    local ports=($(echo "$EXPOSE_PORTS" | tr ':' '\n'))
    for var in "${ports[@]}"; do
        local metrics_port=$((var+1))
        nohup cloudflared tunnel --url http://localhost:$var --metrics localhost:$metrics_port --pidfile /tmp/cloudflared_$var.pid > /tmp/cloudflared_$var.log 2>&1 &
        while true; do
            response=$(curl -s http://localhost:$metrics_port/quicktunnel)
            if [ $? -eq 0 ]; then
                hostname=$(echo "$response" | jq -r '.hostname')
                echo "Success! Hostname is $hostname"
                break
            fi
            echo "Failed to get response. Retrying in 5 seconds..."
            sleep 5
        done
        echo $mhostname
    done
else
    cloudflared service install $CF_TOKEN
fi