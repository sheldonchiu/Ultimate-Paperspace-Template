#!/bin/bash
set -e

if [ ! -d "$TARGET_REPO_DIR/.git" ]; then
    mkdir -p "$TARGET_REPO_DIR"
    cd "$TARGET_REPO_DIR"
    git init
    git remote add origin $TARGET_REPO_URL
    git fetch
    if [ -n "${TARGET_REPO_BRANCH}" ]; then
        git checkout -t origin/${TARGET_REPO_BRANCH} -f
    else
        git checkout -t origin/master -f
    fi
fi

if [ "${UPDATE_REPO}" = "auto" ]; then
    echo "Updating Repo $TARGET_REPO_DIR ..."
    cd "$TARGET_REPO_DIR"
    git pull
elif [ "${UPDATE_REPO}" = "commit" ]; then
    echo "Updating $TARGET_REPO_DIR to commit ${UPDATE_REPO_COMMIT}..."
    cd "$TARGET_REPO_DIR"
    git fetch
    git checkout "${UPDATE_REPO_COMMIT}"
fi

if [ -n "${SYMLINKS}" ]; then
    echo -e "\nCreating Symlinks..."
    for symlink in "${SYMLINKS[@]}"; do
        src="${symlink%%:*}"
        dest="${symlink#*:}"

        mkdir -p "$src"
        if [ -L "$dest" ] && [ ! -e "$dest" ]; then # -e validates a symlink
            echo "Symlink broken, removing: $dest"
            rm "$dest"
        fi
        if [ ! -e "$dest" ]; then
            ln -s "$src" "$dest"
        fi
        echo "$(realpath "$dest") -> $dest"
    done
fi