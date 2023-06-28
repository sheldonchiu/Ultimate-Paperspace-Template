#!/bin/bash
set -e

current_dir=$(dirname "$(realpath "$0")")
source $current_dir/log.sh

if [[ -n $TARGET_REPO_DIR ]]; then
    if [[ ! -d "$TARGET_REPO_DIR/.git" ]]; then
        mkdir -p "$TARGET_REPO_DIR"
        cd "$TARGET_REPO_DIR"
        git init
        git remote add origin $TARGET_REPO_URL
        git fetch
        if [[ -n $TARGET_REPO_BRANCH ]]; then
            git checkout -t origin/$TARGET_REPO_BRANCH -f
        else
            git checkout -t origin/master -f
        fi
    fi

    if [[ $UPDATE_REPO == "auto" ]]; then
        log "Updating Repo $TARGET_REPO_DIR ..."
        cd $TARGET_REPO_DIR
        git pull
    elif [[ $UPDATE_REPO == "commit" ]]; then
        log "Updating $TARGET_REPO_DIR to commit $UPDATE_REPO_COMMIT..."
        cd $TARGET_REPO_DIR
        git fetch
        git checkout $UPDATE_REPO_COMMIT
    fi
fi
