#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")

# Install Python 3.10
if ! [ -e "/tmp/fastchat.prepared" ]; then
    bash $DISCORD_PATH "Preparing Environment for FastChat"
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/fastchat-env
    source /tmp/fastchat-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    pip3 install fschat
    pip3 install git+https://github.com/huggingface/transformers

    touch /tmp/fastchat.prepared
else
    source /tmp/fastchat-env/bin/activate
fi

args=""

bash $DISCORD_PATH "Downloading Models for FastChat"
cd /tmp
if [[ "$FASTCHAT_MODEL" == "vicuna-7b" ]]; then
    git lfs install
    git clone https://huggingface.co/sheldonxxxx/llama-vicuna-7b
    model_path=/tmp/llama-vicuna-7b
elif [[ "$FASTCHAT_MODEL" == "vicuna-13b" ]]; then
    git lfs install
    git clone https://huggingface.co/eachadea/vicuna-13b
    model_path=/tmp/vicuna-13b
    args="--load-8bit"
elif [[ "$FASTCHAT_MODEL" == "chatglm-6b" ]]; then
    git lfs install
    git clone https://huggingface.co/THUDM/chatglm-6b
    model_path=/tmp/chatglm-6b
fi

bash $DISCORD_PATH "FastChat is starting"

if [ -n "$1" ]; then
    case $1 in
        "controller")
            nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/fastchat_controller.log 2>&1 &
            echo $! > /tmp/fastchat_controller.pid
            ;;
        "worker")
            nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --model-path $model_path $args > /tmp/fastchat_worker.log 2>&1 &
            echo $! > /tmp/fastchat_worker.pid
            ;;
        "server")
            nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode reload --port $FASTCHAT_PORT > /tmp/fastchat_server.log 2>&1 &
            echo $! > /tmp/fastchat_server.pid
            ;;
        *)
            echo "Invalid argument. Usage: bash main.sh [controller|worker|server]"
            ;;
    esac
else
    nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > /tmp/fastchat_controller.log 2>&1 &
    echo $! > /tmp/fastchat_controller.pid

   nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --model-path $model_path $args > /tmp/fastchat_worker.log 2>&1 &
    echo $! > /tmp/fastchat_worker.pid

    nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode reload --port $FASTCHAT_PORT > /tmp/fastchat_server.log 2>&1 &
    echo $! > /tmp/fastchat_server.pid
    
    bash $DISCORD_PATH "Fastchat started"
fi