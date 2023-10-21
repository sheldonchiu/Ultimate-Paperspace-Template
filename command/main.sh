#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Command Server ###"
log "Setting up Command Server"

if ! [[ -e "/tmp/command.prepared" ]]; then
    
    
    python3 -m venv /tmp/command-env
    
    source $VENV_DIR/command-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    pip install -r requirements.txt
    
    touch /tmp/command.prepared
else
    
    source $VENV_DIR/command-env/bin/activate
    
fi
log "Finished Preparing Environment for Command Server"



echo "### Starting Command Server ###"
log "Starting Command Server"
/usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf restart command
if [[ -n "${DISCORD_BOT}" ]]; then
  /usr/bin/supervisorctl -c $WORKING_DIR/supervisord.conf restart command_process
fi
cd ..

send_to_discord "Command Server Started"

if env | grep -q "PAPERSPACE"; then
  send_to_discord "Link: https://$PAPERSPACE_FQDN/command/"
fi


if [[ -n "${CF_TOKEN}" ]]; then
  if [[ "$RUN_SCRIPT" != *"command"* ]]; then
    export RUN_SCRIPT="$RUN_SCRIPT,command"
  fi
  bash $current_dir/../cloudflare_reload.sh
fi

echo "### Done ###"