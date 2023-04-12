#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")

# apt-get install -qq aria2 -y > /dev/null

# Install Python 3.10
if ! [[ -e "/tmp/sd-comfy.prepared" ]]; then
  apt-get install -y python3.10 python3.10-venv
  python3.10 -m venv /tmp/sd-confy-env
  source /tmp/sd-confy-env/bin/activate

  pip install --upgrade pip
  pip install --upgrade wheel setuptools

  if [[ ! -d "$REPO_DIR/.git" ]]; then
    # It's possible that the stable_diffusion_webui_path already exists but the repo has not been downloaded.
    # We will init the repo manually.
    mkdir -p "$REPO_DIR"
    cd "$REPO_DIR"
    git init
    git remote add origin https://github.com/comfyanonymous/ComfyUI.git
    git fetch
  elif [[ "${UPDATE_REPO}" = "auto" ]]; then
    echo "stable-diffusion-comfy already downloaded, updating..."
    cd "$REPO_DIR"
    git pull
  elif [[ "${UPDATE_REPO}" = "commit" ]]; then
    echo "stable-diffusion-comfy already downloaded, updating to commit ${UPDATE_REPO_COMMIT}..."
    cd "$REPO_DIR"
    git fetch
    git checkout "${UPDATE_REPO_COMMIT}"
  fi
else
  source /tmp/sd-confy-env/bin/activate
fi

bash $DISCORD_PATH "Downloading Models"
bash $current_dir/../utils/model_download/main.sh
bash $DISCORD_PATH "Finished Downloading Models"

python $current_dir/../utils/model_download/link_model.py

cd "$REPO_DIR"
nohup python main.py --dont-print-server > /tmp/sd-comfy.log 2>&1 &
echo $! > /tmp/sd-comfy.pid
bash $DISCORD_PATH "Stable Diffusion ComfyUI Started"

