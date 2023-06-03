#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
cd $current_dir
source .env

# Set up a trap to call the error_exit function on ERR signal
trap 'error_exit "### ERROR ###"' ERR


echo "### Setting up Image Browser ###"
TARGET_REPO_URL="https://github.com/zanllp/sd-webui-infinite-image-browsing.git" \
TARGET_REPO_DIR=$REPO_DIR \
UPDATE_REPO="auto" \
bash $current_dir/../utils/prepare_repo.sh
if ! [[ -e "/tmp/image_browser.prepared" ]]; then
    
    python3.10 -m venv /tmp/image_browser-env
    source /tmp/image_browser-env/bin/activate

    pip install --upgrade pip
    pip install --upgrade wheel setuptools
    
    cd $REPO_DIR
    pip install -r requirements.txt
    
    touch /tmp/image_browser.prepared
else
    
    source /tmp/image_browser-env/bin/activate
    
fi
echo "Finished Preparing Environment for Image Browser"



cat > $REPO_DIR/.env << EOF
IIB_SECRET_KEY=$IMAGE_BROWSER_KEY
# Configuring the server-side language for this extension,
# including the tab title and most of the server-side error messages returned. Options are 'zh', 'en', or 'auto'.
# If you want to configure the language for the front-end pages, please set it on the extension's global settings page.
IIB_SERVER_LANG=auto
EOF

echo "### Starting Image Browser ###"
cd $REPO_DIR
nohup python app.py --port=$IMAGE_BROWSER_PORT > /tmp/image_browser.log 2>&1 &
log "Image Browser Started"
echo "### Done ###"