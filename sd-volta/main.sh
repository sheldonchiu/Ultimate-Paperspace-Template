#!/bin/bash
REPO_DIR="/storage/stable-diffusion-volta"

# apt-get install -qq aria2 -y > /dev/null

# Install Python 3.10
apt-get install -y python3.10 python3.10-venv
python3.10 -m venv /tmp/sd-volta-env
source /tmp/sd-volta-env/bin/activate

pip install --upgrade pip
pip install --upgrade wheel setuptools

if [ ! -d "$REPO_DIR/.git" ]; then
  # It's possible that the stable_diffusion_webui_path already exists but the repo has not been downloaded.
  # We will init the repo manually.
  mkdir -p "$REPO_DIR"
  cd "$REPO_DIR"
  git init
  git remote add origin https://github.com/VoltaML/voltaML-fast-stable-diffusion.git 
  git fetch
  git checkout experimental
elif [ "${UPDATE_REPO}" = "auto" ]; then
  echo "stable-diffusion-volta already downloaded, updating..."
  cd "$REPO_DIR"
  git pull
elif [ "${UPDATE_REPO}" = "commit" ]; then
  echo "stable-diffusion-volta already downloaded, updating to commit ${UPDATE_REPO_COMMIT}..."
  cd "$REPO_DIR"
  git fetch
  git checkout "${UPDATE_REPO_COMMIT}"
fi

python link_models.py

export HUGGINGFACE_TOKEN=$HF_TOKEN
cd "$REPO_DIR"
nohup python main.py > /tmp/sd-volta.log 2>&1 &
echo $! > /tmp/sd-volta.pid