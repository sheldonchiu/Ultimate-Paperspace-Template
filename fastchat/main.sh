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
echo "### Setting up FastChat ###"



if ! [[ -e "/tmp/fastchat.prepared" ]]; then
    
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
echo "Finished Preparing Environment for FastChat"


echo "### Downloading Model for FastChat ###"

args=""
if [[ $FASTCHAT_MODEL == "vicuna-7b" ]]; then
    git clone https://huggingface.co/eachadea/vicuna-7b-1.1 /tmp/vicuna-7b-1.1
    model_path=/tmp/vicuna-7b-1.1
elif [[ $FASTCHAT_MODEL == "vicuna-13b" ]]; then
    git clone https://huggingface.co/eachadea/vicuna-13b-1.1 /tmp/vicuna-13b-1.1
    model_path=/tmp/vicuna-13b-1.1
    args="--load-8bit"
elif [[ $FASTCHAT_MODEL == "chatglm-6b" ]]; then
    git clone https://huggingface.co/THUDM/chatglm-6b /tmp/chatglm-6b
    model_path=/tmp/chatglm-6b
else
    echo "Invalid model name. Please set FASTCHAT_MODEL to vicuna-7b, vicuna-13b or chatglm-6b"
    exit 1
fi

echo "Finished Downloading Models for FastChat"


echo "### Starting FastChat ###"

if [[ -n $1 ]]; then
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
    
fi

echo "FastChat Started"
echo "### Done ###"