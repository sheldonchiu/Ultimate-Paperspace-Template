#!/bin/bash
set -e

if ! [ -e "/tmp/command.prepared" ]; then
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/command-env
    source /tmp/command-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install fastapi uvicorn[standard]
    touch /tmp/command.prepared
else
    source /tmp/command-env/bin/activate
fi

nohup uvicorn main:app --host 0.0.0.0 --port $COMMAND_PORT > /tmp/command.log 2>&1 &
echo $! > /tmp/command.pid

bash $DISCORD_PATH "Command server started"