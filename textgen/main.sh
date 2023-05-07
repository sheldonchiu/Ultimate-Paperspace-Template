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


    touch /tmp/textgen.prepared
else
    
    source /tmp/textgen-env/bin/activate
    
fi
echo "Finished Preparing Environment for Text generation Webui"


echo "### Downloading Model for Text generation Webui ###"

args=""
mkdir -p $REPO_DIR/models
IFS=',' read -ra models <<< "$TEXTGEN_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-7B-1.1" ]]; then
        SYMLINKS="/tmp/vicuna-7B-1.1:$REPO_DIR/models/vicuna-7B-1.1" \
        TARGET_REPO_DIR="/tmp/vicuna-7B-1.1" \
        TARGET_REPO_BRANCH="main" \
        TARGET_REPO_URL="https://huggingface.co/eachadea/vicuna-7b-1.1" \
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-7B-1.1"
    elif [[ "$model" == "vicuna-13B-1.1" ]]; then
        SYMLINKS="/tmp/vicuna-13B-1.1:$REPO_DIR/models/vicuna-13B-1.1" \
        TARGET_REPO_DIR="/tmp/vicuna-13B-1.1" \
        TARGET_REPO_BRANCH="main" \
        TARGET_REPO_URL="https://huggingface.co/eachadea/vicuna-13b-1.1" \
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-13B-1.1"
        args="--load-in-8bit"
    elif [[ "$model" == "vicuna-13B-1.1-GPTQ-4bit-128g" ]]; then
        SYMLINKS="/tmp/vicuna-13B-1.1-GPTQ-4bit-128g:$REPO_DIR/models/vicuna-13B-1.1-GPTQ-4bit-128g" \
        TARGET_REPO_DIR="/tmp/vicuna-13B-1.1-GPTQ-4bit-128g" \
        TARGET_REPO_BRANCH="main" \
        TARGET_REPO_URL="https://huggingface.co/TheBloke/vicuna-13B-1.1-GPTQ-4bit-128g" \
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-13B-1.1-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    elif [[ "$model" == "vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" ]]; then
        SYMLINKS="/tmp/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g:$REPO_DIR/models/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" \
        TARGET_REPO_DIR="/tmp/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" \
        TARGET_REPO_BRANCH="main" \
        TARGET_REPO_URL="https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/" \
        bash $current_dir/../utils/prepare_repo.sh
        model_name="vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    fi
done

echo "Finished Downloading Models for Text generation Webui"


echo "### Starting Text generation Webui ###"

cd $REPO_DIR
nohup python server.py  --listen-port $TEXTGEN_PORT --model $model_name $args > /tmp/textgen.log 2>&1 &
echo $! > /tmp/textgen.pid

echo "Text generation Webui Started"
echo "### Done ###"