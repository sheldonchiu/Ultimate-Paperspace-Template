#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Text generation Webui ###"
TARGET_REPO_DIR=$REPO_DIR \
TARGET_REPO_BRANCH="main" \
TARGET_REPO_URL="https://github.com/oobabooga/text-generation-webui" \
UPDATE_REPO=$TEXTGEN_UPDATE_REPO \
UPDATE_REPO_COMMIT=$TEXTGEN_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh
if ! [[ -e "/tmp/textgen.prepared" ]]; then
    
    python3.10 -m venv /tmp/textgen-env
    source /tmp/textgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install torch torchvision torchaudio
    pip install -r requirements.txt

    mkdir -p repositories
    cd repositories
    TARGET_REPO_DIR=$REPO_DIR/repositories/GPTQ-for-LLaMa \
    TARGET_REPO_BRANCH="cuda" \
    TARGET_REPO_URL="https://github.com/qwopqwop200/GPTQ-for-LLaMa.git" \
    bash $current_dir/../utils/prepare_repo.sh

    cd GPTQ-for-LLaMa
    python setup_cuda.py install

    pip install deepspeed

    # Temp fix for graio 3.25.0 cannot restart on GUI
    pip install gradio>=3.28.0
    
    touch /tmp/textgen.prepared
else
    
    source /tmp/textgen-env/bin/activate
    
fi
echo "Finished Preparing Environment for Text generation Webui"


log "### Downloading Model for Text generation Webui ###"
# Prepare model dir and link it under the models folder inside the repo
mkdir -p $MODEL_DIR
rm -rf $LINK_MODEL_TO
ln -s $MODEL_DIR $LINK_MODEL_TO
if [[ ! -f $model_dir/config.yaml ]]; then  
    wget -q https://raw.githubusercontent.com/oobabooga/text-generation-webui/main/models/config.yaml -P $model_dir
fi

args=""
IFS=',' read -ra models <<< "$TEXTGEN_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-13B-1.1" ]]; then
        model_name="vicuna-13B-1.1-GPTQ-4bit-128g"
        download_from_hf  "TheBloke" "$model_name" "main"
        args="--wbits 4 --groupsize 128 --model_type Llama"
    elif [[ "$model" == "stable-vicuna-13B" ]]; then
        model_name="stable-vicuna-13B-GPTQ"
        download_from_hf  "TheBloke" "$model_name" "latest"
        args="--wbits 4 --groupsize 128 --model_type Llama"
    fi
done
log "Finished Downloading Models for Text generation Webui"


echo "### Starting Text generation Webui ###"
cd $REPO_DIR
nohup python server.py  --listen-port $TEXTGEN_PORT --model $model_name $args --xformers > /tmp/textgen.log 2>&1 &
echo $! > /tmp/textgen.pid
log "Text generation Webui Started"
echo "### Done ###"