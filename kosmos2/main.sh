#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Kosmos2 ###"
log "Setting up Kosmos2"
TARGET_REPO_DIR=$REPO_DIR \
TARGET_REPO_BRANCH="master" \
TARGET_REPO_URL="https://github.com/microsoft/unilm.git" \
UPDATE_REPO=$KOSMOS2_UPDATE_REPO \
UPDATE_REPO_COMMIT=$KOSMOS2_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh

TARGET_REPO_DIR=/tmp/apex \
TARGET_REPO_BRANCH="master" \
TARGET_REPO_URL="https://github.com/NVIDIA/apex.git" \
UPDATE_REPO=1 \
bash $current_dir/../utils/prepare_repo.sh  
if ! [[ -e "/tmp/kosmos2.prepared" ]]; then
    
    
    python3 -m venv /tmp/kosmos2-env
    
    source /tmp/kosmos2-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR/kosmos-2

    pip install fairseq/
    pip install infinibatch/
    pip install ftfy
    pip install -e torchscale
    pip install -e open_clip
    pip install  git+https://github.com/microsoft/DeepSpeed.git@jeffra/engine-xthru-v2
    pip install tiktoken
    pip install sentencepiece

    pip install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116
    pip install xformers==0.0.16
    pip install gradio numpy==1.22.2 scipy opencv-python protobuf==3.20.1 pytorch-extension

    cd /tmp/apex
    pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
    cd $REPO_DIR
    
    touch /tmp/kosmos2.prepared
else
    
    source /tmp/kosmos2-env/bin/activate
    
fi
log "Finished Preparing Environment for Kosmos2"


echo "### Downloading Model for Kosmos2 ###"
log "Downloading Model for Kosmos2"

# Prepare model dir and link it under the models folder inside the repo
mkdir -p $MODEL_DIR
cd $MODEL_DIR
aria2c --file-allocation=none -c -x 16 -s 16 --summary-interval=0 --console-log-level=warn --continue  --out=kosmos-2.pt "https://huggingface.co/sheldonxxxx/kosmos-2/resolve/main/kosmos-2.pt"
log "Finished Downloading Models for Kosmos2"


echo "### Starting Kosmos2 ###"
log "Starting Kosmos2"

cd $REPO_DIR/kosmos-2
model_path=$MODEL_DIR/kosmos-2.pt

master_port=$((RANDOM%1000+20000))

CUDA_LAUNCH_BLOCKING=1 CUDA_VISIBLE_DEVICES=0 python -m torch.distributed.launch --master_port=$master_port --nproc_per_node=1 demo/gradio_app.py None \
    --task generation_obj \
    --path $model_path \
    --model-overrides "{'visual_pretrained': '',
            'dict_path':'data/dict.txt'}" \
    --dict-path 'data/dict.txt' \
    --required-batch-size-multiple 1 \
    --remove-bpe=sentencepiece \
    --max-len-b 500 \
    --add-bos-token \
    --beam 1 \
    --buffer-size 1 \
    --image-feature-length 64 \
    --locate-special-token 1 \
    --batch-size 1 \
    --nbest 1 \
    --no-repeat-ngram-size 3 \
    --location-bin-size 32 > $LOG_DIR/kosmos2.log 2>&1 &

echo $! > /tmp/kosmos2.pid

send_to_discord "Kosmos2 Started"

bash $current_dir/../cloudflare_reload.sh

echo "### Done ###"