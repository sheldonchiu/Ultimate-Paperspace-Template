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
echo "### Setting up Stable Diffusion WebUI ###"


symlinks=(
    "$WEBUI_DIR:/notebooks/stable-diffusion-webui"
    "$WEBUI_DIR/outputs:/notebooks/outputs/stable-diffusion-webui"
    "$WEBUI_DIR/log:$WEBUI_DIR/outputs/log"
    "/storage:/notebooks/storage"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" TARGET_REPO_DIR=$WEBUI_DIR UPDATE_REPO=$SD_WEBUI_UPDATE_REPO UPDATE_REPO_COMMIT=$SD_WEBUI_UPDATE_REPO_COMMIT bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"

# git clone extensions that has their own model folder
if [[ ! -d "${WEBUI_DIR}/extensions/sd-webui-controlnet" ]]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git "${WEBUI_DIR}/extensions/sd-webui-controlnet"
fi
if [[ ! -d "${WEBUI_DIR}/extensions/sd-webui-additional-networks" ]]; then
    git clone https://github.com/kohya-ss/sd-webui-additional-networks.git  "${WEBUI_DIR}/extensions/sd-webui-additional-networks"
fi


if ! [[ -e "/tmp/sd_webui.prepared" ]]; then
    
    python3.10 -m venv /tmp/sd_webui-env
    source /tmp/sd_webui-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
     
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml

    export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $WEBUI_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    if [[ -n "${ACTIVATE_XFORMERS}" ]]; then
        pip install xformers==0.0.19
    fi


    touch /tmp/sd_webui.prepared
else
    
    source /tmp/sd_webui-env/bin/activate
    
fi
echo "Finished Preparing Environment for Stable Diffusion WebUI"


echo "### Downloading Model for Stable Diffusion WebUI ###"

bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py

echo "Finished Downloading Models for Stable Diffusion WebUI"


echo "### Starting Stable Diffusion WebUI ###"
bash start.sh
echo "Stable Diffusion WebUI Started"
echo "### Done ###"