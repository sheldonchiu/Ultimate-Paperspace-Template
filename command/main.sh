#!/bin/bash
set -e

# Define a function to echo a message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR

current_dir=$(dirname "$(realpath "$0")")
echo "### Setting up Command Server ###"



if ! [[ -e "/tmp/command.prepared" ]]; then
    
    python3.10 -m venv /tmp/command-env
    source /tmp/command-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    pip install fastapi uvicorn[standard]

    touch /tmp/command.prepared
else
    
    source /tmp/command-env/bin/activate
    
fi
echo "Finished Preparing Environment for Command Server"



echo "### Starting Command Server ###"
nohup uvicorn main:app --host 0.0.0.0 --port $COMMAND_PORT > /tmp/command.log 2>&1 &
echo "Command Server Started"
echo "### Done ###"