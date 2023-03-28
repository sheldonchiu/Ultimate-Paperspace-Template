#!/bin/bash

if [ ! -d "$WEBUI_DIR/.git" ]; then
  # It's possible that the stable_diffusion_webui_path already exists but the repo has not been downloaded.
  # We will init the repo manually.
  mkdir -p "$WEBUI_DIR"
  cd "$WEBUI_DIR"
  git init
  git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui
  git fetch
  git checkout -t origin/master -f
else
  echo "stable-diffusion-webui already downloaded, updating..."
  cd "$WEBUI_DIR"
  git pull
fi

mkdir -p "$WEBUI_DIR/outputs"
mkdir -p "$WEBUI_DIR/log"

symlinks=(
  "$WEBUI_DIR:/notebooks/stable-diffusion-webui"
  "$WEBUI_DIR/outputs:/notebooks/outputs"
  "$WEBUI_DIR/log:$WEBUI_DIR/outputs/log"
  "/storage:/notebooks/storage"
  "$MODEL_DIR:/notebooks/models"
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