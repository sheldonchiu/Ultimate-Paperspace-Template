#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Cloudflare Tunnel ###"
log "Setting up Cloudflare Tunnel"

if ! [[ -e "/tmp/cloudflared.prepared" ]]; then
    
    cd /tmp
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb
    
    touch /tmp/cloudflared.prepared
else
    
    log "Environment already prepared"
    
fi
log "Finished Preparing Environment for Cloudflare Tunnel"



echo "### Starting Cloudflare Tunnel ###"
log "Starting Cloudflare Tunnel"
if [[ $CF_TOKEN == "quick" ]]; then
    # Split EXPOSE_PORTS into an array using ':' as the delimiter
    IFS=':' read -ra names <<< "$PORT_MAPPING"
    IFS=':' read -ra ports <<< "$EXPOSE_PORTS"

    # Loop over the ports array
    paste <(printf '%s\n' "${names[@]}") <(printf '%s\n' "${ports[@]}") | while IFS=$'\t' read -r name port; do
        if [[ $port == "" ]]; then
            continue
        fi
        metrics_port=$((port+1))

        # Generate PID file and log file names using a different delimiter
        pidfile="/tmp/cloudflared_${name}.pid"
        logfile="/tmp/cloudflared_${name}.log"
        hostfile="/tmp/cloudflared_${name}.host"
        
        # Check if tunnel is already running
        if [[ -f $pidfile ]]; then
            if kill -0 "$(cat $pidfile)"; then
                log "Cloudflared tunnel for $name is already running."
                continue
            fi
        fi
        log "Starting cloudflared tunnel for $name"
        # Start cloudflared tunnel in the background
        nohup cloudflared tunnel --url http://localhost:${port} --metrics localhost:${metrics_port} --pidfile "$pidfile" > "$logfile" 2>&1 &

        # Wait for the tunnel to become available
        retries=0
        max_retries=10
        while true; do
            sleep 5
            response=$(curl http://localhost:${metrics_port}/quicktunnel || true)
            if [[ $? -eq 0 ]] && [[ "$(echo "$response" | jq -r '.hostname')" != "" ]]; then
                hostname=$(echo "$response" | jq -r '.hostname')
                echo $hostname > $hostfile
                send_to_discord "Cloudflared: Hostname is $hostname for $name"
                break
            fi
            retries=$((retries+1))
            if [[ $retries -ge $max_retries ]]; then
                log "Error: Failed to get response after $max_retries attempts"
                send_to_discord "Cloudflared: Failed to get response after $max_retries attempts"
                break
            fi
            echo "Failed to get response. Retrying in 5 seconds..."
            sleep 5
        done
    done
else
    cloudflared service install "$CF_TOKEN"
    send_to_discord "Cloudflared: Running as a service"
fi

send_to_discord "Cloudflare Tunnel Started"
echo "### Done ###"