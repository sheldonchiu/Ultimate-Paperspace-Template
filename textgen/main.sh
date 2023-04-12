#!/bin/bash
set -e

create_symlink() {
    local src=$1
    local dest=$2

    mkdir -p $src
    if [[ -L $dest ]] && [[ ! -e $dest ]]; then # -e validates a symlink
        echo "Symlink broken, removing: $dest"
        rm $dest
    fi
    if [[ ! -e $dest ]]; then
        ln -s $src $dest
    fi
}

current_dir=$(dirname "$(realpath "$0")")

echo "Setting up Text generation Webui..."
if ! [[ -e "/tmp/textgen.prepared" ]]; then
    apt-get install -y python3.10 python3.10-dev python3.10-venv
    python3.10 -m venv /tmp/textgen-env
    source /tmp/textgen-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools

    pip3 install torch torchvision torchaudio

    TARGET_REPO_DIR=$REPO_DIR \
    TARGET_REPO_BRANCH="main" \
    TARGET_REPO_URL="https://github.com/oobabooga/text-generation-webui" \
    UPDATE_REPO=$TEXTGEN_UPDATE_REPO \
    UPDATE_REPO_COMMIT=$TEXTGEN_UPDATE_REPO_COMMIT \
    bash $current_dir/../utils/prepare_repo.sh

    cd $REPO_DIR
    pip install -r requirements.txt

    mkdir -p repositories
    cd repositories

    TARGET_REPO_DIR=$REPO_DIR/repositories/GPTQ-for-LLaMa \
    TARGET_REPO_BRANCH="cuda" \
    TARGET_REPO_URL="https://github.com/qwopqwop200/GPTQ-for-LLaMa.git" \
    # UPDATE_REPO=$TEXTGEN_UPDATE_REPO \
    # UPDATE_REPO_COMMIT=$TEXTGEN_UPDATE_REPO_COMMIT \
    bash $current_dir/../utils/prepare_repo.sh

    # git clone https://github.com/qwopqwop200/GPTQ-for-LLaMa.git -b cuda
    cd GPTQ-for-LLaMa
    python setup_cuda.py install

    pip install deepspeed

    touch /tmp/textgen.prepared

else
    source /tmp/textgen-env/bin/activate
fi
echo "Finished setting up Text generation Webui"

args=""
echo "Downloading Models for Text generation Webui..."
mkdir -p $REPO_DIR/models
IFS=',' read -ra models <<< "$FASTCHAT_MODEL"
for model in "${models[@]}"
do
    cd /tmp
    if [[ "$model" == "vicuna-7b" ]]; then
        git clone https://huggingface.co/sheldonxxxx/llama-vicuna-7b
        create_symlink /tmp/llama-vicuna-7b $REPO_DIR/models/llama-vicuna-7b
        model_name="llama-vicuna-7b"
    elif [[ "$model" == "vicuna-13b" ]]; then
        git clone https://huggingface.co/eachadea/vicuna-13b
        create_symlink /tmp/vicuna-13b $REPO_DIR/models/vicuna-13b
        model_name="vicuna-13b"
        args="--load-in-8bit"
    elif [[ "$model" == "vicuna-13b-GPTQ-4bit-128g" ]]; then
        git clone https://huggingface.co/anon8231489123/vicuna-13b-GPTQ-4bit-128g
        create_symlink /tmp/vicuna-13b-GPTQ-4bit-128g $REPO_DIR/models/vicuna-13b-GPTQ-4bit-128g
        model_name="vicuna-13b-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    elif [[ "$model" == "vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g" ]]; then
        GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/
        cd vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g
        wget https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/resolve/main/tokenizer.model
        wget https://huggingface.co/TheBloke/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g/resolve/main/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g.safetensors
        create_symlink /tmp/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g $REPO_DIR/models/vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g
        model_name="vicuna-AlekseyKorshuk-7B-GPTQ-4bit-128g"
        args="--wbits 4 --groupsize 128"
    fi
done
echo "Finished downloading Models for Text generation Webui"

echo "Starting Text generation Webui..."
cd $REPO_DIR
nohup python server.py --model model_name $args > /tmp/textgen.log 2>&1 &
echo $! > /tmp/textgen.pid

echo "Text generation Webui started"