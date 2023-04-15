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

echo "### Setting up Stable Diffusion Comfy ###"
if ! [[ -e "/tmp/sd-comfy.prepared" ]]; then
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

echo "### Downloading Models ###"
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py

cd "$REPO_DIR"
echo "### Starting Stable Diffusion Comfy ###"
nohup python main.py --dont-print-server > /tmp/sd-comfy.log 2>&1 &
echo $! > /tmp/sd-comfy.pid
echo "Stable Diffusion ComfyUI Started"
echo "### Done ###"
