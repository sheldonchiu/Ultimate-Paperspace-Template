#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Text generation Webui ###"
log "Setting up Text generation Webui"
# Remove stale symlink to avoid pull conflicts
rm -rf $LINK_MODEL_TO

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

    pip uninstall -y llama-cpp-python
    CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir

    pip install deepspeed

    pip install xformers
    
    touch /tmp/textgen.prepared
else
    
    source /tmp/textgen-env/bin/activate
    
fi
log "Finished Preparing Environment for Text generation Webui"


echo "### Downloading Model for Text generation Webui ###"
log "Downloading Model for Text generation Webui"
# Prepare model dir and link it under the models folder inside the repo
mkdir -p $MODEL_DIR
rm -rf $LINK_MODEL_TO
ln -s $MODEL_DIR $LINK_MODEL_TO
if [[ ! -f $MODEL_DIR/config.yaml ]]; then 
    current_dir_save=$(pwd) 
    cd $REPO_DIR
    commit=$(git rev-parse HEAD)
    wget -q https://raw.githubusercontent.com/oobabooga/text-generation-webui/$commit/models/config.yaml -P $MODEL_DIR
    cd $current_dir_save
fi


bash $current_dir/../utils/llm_model_download.sh
log "Finished Downloading Models for Text generation Webui"


echo "### Starting Text generation Webui ###"
log "Starting Text generation Webui"
cd $REPO_DIR
share_args="--chat --listen-port $TEXTGEN_PORT --xformers ${EXTRA_TEXTGEN_ARGS}"
if [ -v TEXTGEN_ENABLE_OPENAI_API ] && [ ! -z "$TEXTGEN_ENABLE_OPENAI_API" ];then
  loader_arg=""
  if echo "$TEXTGEN_OPENAI_MODEL" | grep -q "GPTQ"; then
    loader_arg="--loader exllama"
  fi
  if echo "$TEXTGEN_OPENAI_MODEL" | grep -q "LongChat"; then
    loader_arg+=" --max_seq_len 8192 --compress_pos_emb 4"
  fi
  PYTHONUNBUFFERED=1 OPENEDAI_PORT=7013 nohup python server.py --model $TEXTGEN_OPENAI_MODEL $loader_arg --extensions openai $share_args > $LOG_DIR/textgen.log 2>&1 &
else
  PYTHONUNBUFFERED=1 nohup python server.py  $share_args > $LOG_DIR/textgen.log 2>&1 &
fi
echo $! > /tmp/textgen.pid

send_to_discord "Text generation Webui Started"
echo "### Done ###"