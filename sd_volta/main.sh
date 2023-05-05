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
echo "### Setting up Stable Diffusion Volta ###"


symlinks=(
    "$WEBUI_DIR:/notebooks/stable-diffusion-volta"
    "/storage:/notebooks/storage"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/VoltaML/voltaML-fast-stable-diffusion.git" \
TARGET_REPO_DIR=$WEBUI_DIR \
UPDATE_REPO=$SD_VOLTA_UPDATE_REPO \
UPDATE_REPO_COMMIT=$SD_VOLTA_UPDATE_REPO_COMMIT \
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"


if ! [[ -e "/tmp/sd_volta.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_volta-env
    source /tmp/sd_volta-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    

    touch /tmp/sd_volta.prepared
else
    
    source /tmp/sd_volta-env/bin/activate
    
fi
echo "Finished Preparing Environment for Stable Diffusion Volta"


echo "### Downloading Model for Stable Diffusion Volta ###"

bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py

echo "Finished Downloading Models for Stable Diffusion Volta"


echo "### Starting Stable Diffusion Volta ###"

cd "$REPO_DIR"
nohup python main.py > /tmp/sd_volta.log 2>&1 &
echo $! > /tmp/sd_volta.pid

echo "Stable Diffusion Volta Started"
echo "### Done ###"