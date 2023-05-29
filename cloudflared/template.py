from jinja2 import Template

# Define the variables to be used in the template
title = "Cloudflare Tunnel"
name = "cloudflared"
use_python = False

prepare_repo = ""

prepare_env = ''' 
    cd /tmp
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dpkg -i cloudflared.deb
'''.strip()
download_model = ""

action_before_start = ""

start = '''
if [[ $CF_TOKEN == "quick" ]]; then
    # Split EXPOSE_PORTS into an array using ':' as the delimiter
    IFS=':' read -ra names <<< "$PORT_MAPPING"
    IFS=':' read -ra ports <<< "$EXPOSE_PORTS"

    # Loop over the ports array
    paste <(printf '%s\\n' "${names[@]}") <(printf '%s\\n' "${ports[@]}") | while IFS=$'\\t' read -r name port; do
        if [[ $port == "" ]]; then
            continue
        fi
        metrics_port=$((port+1))

        # Generate PID file and log file names using a different delimiter
        pidfile="/tmp/cloudflared_${name}.pid"
        logfile="/tmp/cloudflared_${name}.log"
        hostfile="/tmp/cloudflared_${name}.host"

        if [[ -f $pidfile ]]; then
            pid=$(cat $pidfile)
            # Only start the tunnel if the process is not running
            if ps -p $pid -o pid,comm | grep -q $pid; then
                echo "Starting cloudflared tunnel for $name"
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
                        bash $DISCORD_PATH "Cloudflared: Hostname is $hostname for $name"
                        break
                    fi
                    retries=$((retries+1))
                    if [[ $retries -ge $max_retries ]]; then
                        echo "Error: Failed to get response after $max_retries attempts"
                        bash $DISCORD_PATH "Cloudflared: Failed to get response after $max_retries attempts"
                        break
                    fi
                    echo "Failed to get response. Retrying in 5 seconds..."
                    sleep 5
                done
            else
                echo "Cloudflared tunnel for $name is already running."
            fi
        fi
    done
else
    cloudflared service install "$CF_TOKEN"
    echo "Cloudflared: Running as a service"
fi
'''.strip()

# Load the template from a file
with open('../template/main.j2') as f:
    template = Template(f.read())

# Render the template with the variables
result = template.render(
    title=title,
    name=name, 
    use_python=use_python,
    prepare_repo=prepare_repo,
    prepare_env=prepare_env,
    download_model=download_model,
    action_before_start=action_before_start,
    start=start,
)

with open('main.sh', 'w') as f:
    f.write(result)
    
######################################################
with open('../template/control.j2') as f:
    template = Template(f.read())
    
custom_reload = '''
    for file in /tmp/cloudflared_*.pid; do
        kill_pid $file
    done
    bash main.sh
'''.strip()
custom_stop = '''
    if [[ -n $2 ]]; then
        echo "Stopping Cloudflare tunnel for $2"
        kill_pid /tmp/cloudflared_{$2}.pid
    else
        for file in /tmp/cloudflared_*.pid; do
            kill_pid $file
        done
    fi
'''.strip()
custom_start = ""

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
    custom_reload=custom_reload,
    custom_stop=custom_stop,
    custom_start=custom_start,
)

with open('control.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = '''
export REQUIRED_ENV="CF_TOKEN"
'''.strip()
other_commands = '''
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)