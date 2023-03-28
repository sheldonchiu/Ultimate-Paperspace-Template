#!/bin/bash

repo_storage_dir="/storage/stable-diffusion"
model_storage_dir="/tmp/stable-diffusion-models"
stable_diffusion_webui_path="$repo_storage_dir/stable-diffusion-webui"

if [ ! -d "$stable_diffusion_webui_path/.git" ]; then
  # It's possible that the stable_diffusion_webui_path already exists but the repo has not been downloaded.
  # We will init the repo manually.
  mkdir -p "$stable_diffusion_webui_path"
  cd "$stable_diffusion_webui_path"
  git init
  git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui
  git fetch
  git checkout -t origin/master -f
else
  echo "stable-diffusion-webui already downloaded, updating..."
  cd "$stable_diffusion_webui_path"
  git pull
fi

mkdir -p "$stable_diffusion_webui_path/outputs"
mkdir -p "$stable_diffusion_webui_path/log"

symlinks=(
  "$stable_diffusion_webui_path:/notebooks/stable-diffusion-webui"
  "$stable_diffusion_webui_path/outputs:/notebooks/outputs"
  "$stable_diffusion_webui_path/log:$stable_diffusion_webui_path/outputs/log"
  "/storage:/notebooks/storage"
  "$model_storage_dir:/notebooks/models"
)

echo -e "\nCreating Symlinks..."
for symlink in "${symlinks[@]}"; do
    src="${symlink%%:*}"
    dest="${symlink#*:}"
    # If `/notebooks/stable-diffusion-webui` is a broken symlink then remove it.
    # The WebUI might have previously been installed in a non-persistent directory.
    if [ -L "$dest" ] && [ ! -e "$dest" ]; then # -e validates a symlink
        echo "Symlink broken, removing: $dest"
        rm "$dest"
    fi
    if [ ! -e "$dest" ]; then
        ln -s "$src" "$dest"
    fi
    echo "$(realpath "$dest") -> $dest"
done