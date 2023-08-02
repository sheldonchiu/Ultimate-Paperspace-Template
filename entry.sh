#!/bin/bash
# Don't exit on error

function source_env_file() {
  if [[ -e ".env" ]]; then
    source ".env"
  fi
}

function check_required_env_vars() {
  local required_vars=($(echo "$REQUIRED_ENV" | tr ',' '\n'))
  local missing_vars=()
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      missing_vars+=("$var")
    fi
  done
  if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo "The following required environment variables are missing: ${missing_vars[*]}"
    return 1
  fi
  return 0
}

export SCRIPT_ROOT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
cd $SCRIPT_ROOT_DIR
source_env_file

#nginx
apt-get update -qq
apt-get install -qq -y nginx > /dev/null

mv /notebooks/default /etc/nginx/sites-available/default
/usr/sbin/nginx
echo $! > /tmp/nginx.pid

# Read the RUN_SCRIPT environment variable
run_script="$RUN_SCRIPT"

# Separate the variable by commas
IFS=',' read -ra scripts <<< "$run_script"

echo "Installing common dependencies"
apt-get install -qq curl git-lfs ninja-build aria2 zip python3-venv python3-dev python3.10 python3.10-venv python3.10-dev python3.10-tk -y > /dev/null

# Prepare required path
mkdir -p $IMAGE_OUTPUTS_DIR
if [[ ! -d $WORKING_DIR/image_outputs ]]; then
  ln -s $IMAGE_OUTPUTS_DIR $WORKING_DIR/image_outputs
fi

mkdir $LOG_DIR

# Loop through each script and execute the corresponding case
echo "Starting script(s)"
for script in "${scripts[@]}"
do
  cd $SCRIPT_ROOT_DIR
  if [[ ! -d $script ]]; then
    echo "Script folder $script not found, skipping..."
    continue
  fi
  cd $script
  source_env_file
  if ! check_required_env_vars; then
    echo "One or more required environment variables are missing."
    continue
  fi
  bash main.sh $@
done
