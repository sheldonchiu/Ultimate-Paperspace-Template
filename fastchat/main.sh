#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up FastChat ###"
log "Setting up FastChat"

if ! [[ -e "/tmp/fastchat.prepared" ]]; then
    
    python3.10 -m venv /tmp/fastchat-env
    source /tmp/fastchat-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    pip3 install fschat bitsandbytes
    
    touch /tmp/fastchat.prepared
else
    
    source /tmp/fastchat-env/bin/activate
    
fi
log "Finished Preparing Environment for FastChat"


echo "### Downloading Model for FastChat ###"
log "Downloading Model for FastChat"
mkdir -p $MODEL_DIR
model_paths=""
model_args = ()
IFS=',' read -ra models <<< "$FASTCHAT_MODEL"
for model in "${models[@]}"
do
if [[ $model == "vicuna-7b" ]]; then
    if [[ ! -d "/tmp/vicuna-7b-1.1" ]]; then
        git clone https://huggingface.co/eachadea/vicuna-7b-1.1 /tmp/vicuna-7b-1.1
    fi
    model_paths="$model_paths,/tmp/vicuna-7b-1.1"
    model_args += ("--load-8bit")
elif [[ $model == "vicuna-13b" ]]; then
    if [[ ! -d "/tmp/vicuna-13b-1.1" ]]; then
        git clone https://huggingface.co/eachadea/vicuna-13b-1.1 /tmp/vicuna-13b-1.1
    fi
    model_paths="$model_paths,/tmp/vicuna-13b-1.1"
    model_args += ("--load-8bit")
elif [[ $model == "chatglm-6b" ]]; then
    if [[ ! -d "/tmp/chatglm-6b" ]]; then
        git clone https://huggingface.co/THUDM/chatglm-6b /tmp/chatglm-6b
    fi
    model_paths="$model_paths,/tmp/chatglm-6b"
    model_args += ("")
else
    log "Invalid model name. Please set FASTCHAT_MODEL to vicuna-7b, vicuna-13b or chatglm-6b"
    exit 1
fi
done
log "Finished Downloading Models for FastChat"


echo "### Starting FastChat ###"
log "Starting FastChat"
if [[ -n $1 ]]; then
    case $1 in
        "controller")
            nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > $LOG_DIR/fastchat_controller.log 2>&1 &
            echo $! > /tmp/fastchat_controller.pid
            ;;
        "worker")
            port=21001
            model_args_id=0
            IFS=',' read -ra models <<< "$model_paths"
            for model in "${models[@]}"
            do
                if [ -n "$model" ]; then
                    (( port++ ))
                    nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --port $port --model-path $model --load-8bit ${model_args[$model_args_id]} > $LOG_DIR/fastchat_worker_$port.log 2>&1 &
                    echo $! > /tmp/fastchat_worker_$port.pid
                    (( model_args_id++ ))
                fi
            done
            ;;
        "server")
            nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode once --port $FASTCHAT_PORT > $LOG_DIR/fastchat_server.log 2>&1 &
            echo $! > /tmp/fastchat_server.pid
            ;;
        *)
            echo "Invalid argument. Usage: bash main.sh [controller|worker|server]"
            ;;
    esac
else
    nohup python3 -m fastchat.serve.controller --host 127.0.0.1 > $LOG_DIR/fastchat_controller.log 2>&1 &
    echo $! > /tmp/fastchat_controller.pid
    
    port=21001
    model_args_id=0
    IFS=',' read -ra models <<< "$model_paths"
    for model in "${models[@]}"
    do
    if [ -n "$model" ]; then
        (( port++ ))
        nohup python3 -m fastchat.serve.model_worker --host 127.0.0.1 --port $port --model-path $model --load-8bit ${model_args[$model_args_id]} > $LOG_DIR/fastchat_worker_$port.log 2>&1 &
        echo $! > /tmp/fastchat_worker_$port.pid
        (( model_args_id++ ))
    fi
    done
    
    while true; do
        sleep 5
        response=$(curl -X POST http://localhost:21002/worker_get_status || true )
        if [[ $? -eq 0 ]] && [[ "$(echo "$response" | jq -r '.model_names')" != "" ]]; then
            break
        fi
    done

    nohup python3 -m fastchat.serve.gradio_web_server --model-list-mode once --port $FASTCHAT_PORT > $LOG_DIR/fastchat_server.log 2>&1 &
    echo $! > /tmp/fastchat_server.pid
    
fi

send_to_discord "FastChat Started"

bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"