#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
if ! [ -e "/tmp/sd-webui.prepared" ]; then
    bash $DISCORD_PATH "Preparing Environment for Stable Diffusion WebUI"
    # Install Python 3.10
    apt-get install -y python3.10 python3.10-venv
    python3.10 -m venv /tmp/sd-webui-env
    source /tmp/sd-webui-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml
    
    symlinks=(
        "$WEBUI_DIR:/notebooks/stable-diffusion-webui"
        "$WEBUI_DIR/outputs:/notebooks/outputs"
        "$WEBUI_DIR/log:$WEBUI_DIR/outputs/log"
        "/storage:/notebooks/storage"
        "$MODEL_DIR:/notebooks/models"
    )
    SYMLINKS=$symlinks \
    TARGET_REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" \
    TARGET_REPO_DIR=$WEBUI_DIR \
    UPDATE_REPO=$SD_WEBUI_UPDATE_REPO \
    UPDATE_REPO_COMMIT=$SD_WEBUI_UPDATE_REPO_COMMIT \
    bash $current_dir/../utils/prepare_repo.sh

    export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $WEBUI_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    if [ -n "${ACTIVATE_XFORMERS}" ]; then
        pip install xformers==0.0.16
    fi

    touch /tmp/sd-webui.prepared
else
    source /tmp/sd-webui-env/bin/activate
fi

bash $DISCORD_PATH "Downloading Models"
bash $current_dir/../utils/model_download/main.sh
bash $DISCORD_PATH "Finished Downloading Models"

python $current_dir/../utils/model_download/link_model.py

bash start.sh
bash $DISCORD_PATH "Stable Diffusion WebUI Started"