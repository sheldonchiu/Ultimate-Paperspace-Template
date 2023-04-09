#!/bin/bash

current_dir=$(dirname "$(realpath "$0")")

# Install Python 3.10
if ! [ -e "/tmp/fastchat.prepared" ]; then
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/fastchat-env
    source /tmp/fastchat-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    # pip3 install fschat
    cd /tmp
    git clone https://github.com/sheldonchiu/FastChat.git
    cd FastChat
    pip3 install -e .

    pip3 install git+https://github.com/huggingface/transformers

    cd /tmp
    if [[ "$FASTCHAT_MODEL" == "vicuna-7b" ]]; then
        git lfs install
        git clone https://huggingface.co/sheldonxxxx/llama-vicuna-7b
        model_path=/tmp/llama-vicuna-7b
    fi
    touch /tmp/fastchat.prepared
else
    source /tmp/fastchat-env/bin/activate
fi

if [ -n "$1" ]; then
    case $1 in
        "controller")
            nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/fastchat_controller.log 2>&1 &
            echo $! > /tmp/fastchat_controller.pid
            ;;
        "worker")
            nohup python3 -m fastchat.serve.model_worker --model-path $model_path --host 127.0.0.1 > /tmp/fastchat_worker.log 2>&1 &
            echo $! > /tmp/fastchat_worker.pid
            ;;
        "server")
            python3 -m fastchat.serve.gradio_web_server --port $FASTCHAT_PORT --model-list-mode reload > /tmp/fastchat_server.log 2>&1 &
            echo $! > /tmp/fastchat_server.pid
            ;;
        *)
            echo "Invalid argument. Usage: bash main.sh [controller|worker|server]"
            ;;
    esac
else
    nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/fastchat_controller.log 2>&1 &
    echo $! > /tmp/fastchat_controller.pid

    nohup python3 -m fastchat.serve.model_worker --model-path $model_path --host 127.0.0.1 > /tmp/fastchat_worker.log 2>&1 &
    echo $! > /tmp/fastchat_worker.pid

    python3 -m fastchat.serve.gradio_web_server --port $FASTCHAT_PORT --model-list-mode reload > /tmp/fastchat_server.log 2>&1 &
    echo $! > /tmp/fastchat_server.pid
    
    bash $DISCORD_PATH "Fastchat started"
fi