#!/bin/bash

current_dir=$(dirname "$(realpath "$0")")

# Install Python 3.10
if ! [ -e "/tmp/textgen.prepared" ]; then
    apt-get install -y python3.10 python3.10-dev python3.10-venv
    python3.10 -m venv /tmp/textgen-env
    source /tmp/textgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    pip3 install torch torchvision torchaudio

    TARGET_REPO_DIR=$REPO_DIR \
    TARGET_REPO_URL="https://github.com/oobabooga/text-generation-webui"
    UPDATE_REPO=$TEXTGEN_UPDATE_REPO \
    UPDATE_REPO_COMMIT=$TEXTGEN_UPDATE_REPO_COMMIT \
    bash $current_dir/../utils/prepare_repo.sh

    cd $REPO_DIR
    pip install -r requirements.txt

    mkdir -p repositories
    cd repositories
    git clone https://github.com/qwopqwop200/GPTQ-for-LLaMa.git -b cuda
    cd GPTQ-for-LLaMa
    python setup_cuda.py install

    touch /tmp/textgen.prepared

else:
    source /tmp/textgen-env/bin/activate
fi

args=""
bash $DISCORD_PATH "Downloading Models for Text generation Webui..."
mkdir =p $REPO_DIR/models
IFS=',' read -ra models <<< "$FASTCHAT_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-7b" ]]; then
        git lfs install
        git clone https://huggingface.co/sheldonxxxx/llama-vicuna-7b
        ln -s /tmp/llama-vicuna-7b $REPO_DIR/models/llama-vicuna-7b
        model_name="llama-vicuna-7b"
    elif [[ "$model" == "vicuna-13b" ]]; then
        git lfs install
        git clone https://huggingface.co/eachadea/vicuna-13b
        ln -s /tmp/vicuna-13b $REPO_DIR/models/vicuna-13b
        model_name="vicuna-13b"
        args="--load-in-8bit"
    elif [[ "$model" == "vicuna-13b-GPTQ-4bit-128g" ]]; then
        git lfs install
        git clone https://huggingface.co/anon8231489123/vicuna-13b-GPTQ-4bit-128g
        ln -s /tmp/vicuna-13b-GPTQ-4bit-128g $REPO_DIR/models/vicuna-13b-GPTQ-4bit-128g
        model_name="vicuna-13b-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    elif [[ "$model" == "vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" ]]; then
        GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/
        cd vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g
        wget https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/resolve/main/tokenizer.model
        wget https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/resolve/main/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g.safetensors
        model_name="vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    fi
done

cd $REPO_DIR
nohup python server.py --model model_name $args > /tmp/textgen.log 2>&1 &
echo $! > /tmp/textgen.pid