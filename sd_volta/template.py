from jinja2 import Template

# Define the variables to be used in the template
title = "Stable Diffusion Volta" 
name = "sd_volta"
use_python = True

prepare_repo = '''
symlinks=(
    "$REPO_DIR:/notebooks/stable-diffusion-volta"
    "/storage:/notebooks/storage"
    "$REPO_DIR/data/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-volta"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/VoltaML/voltaML-fast-stable-diffusion.git" \\
TARGET_REPO_DIR=$REPO_DIR \\
TARGET_REPO_BRANCH=main \\
UPDATE_REPO=$SD_VOLTA_UPDATE_REPO \\
UPDATE_REPO_COMMIT=$SD_VOLTA_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"
'''.strip()
prepare_env = '''
    cd $REPO_DIR
    python main.py --install-only
    
    pip install xformers==0.0.20
'''.strip()

download_model = '''
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
'''.strip()

action_before_start = ""

start = f'''
cd "$REPO_DIR"
nohup python main.py > /tmp/{name}.log 2>&1 &
echo $! > /tmp/{name}.pid
'''.strip()
# Load the template from a file
with open('../template/main.j2') as f:
    template = Template(f.read())

# Render the template with the variables
result = template.render(
    title=title,
    name=name, 
    use_python=use_python,
    prepare_repo=prepare_repo,
    prepare_env=prepare_env,
    download_model=download_model,
    action_before_start=action_before_start,
    start=start,
)

with open('main.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/control.j2') as f:
    template = Template(f.read())

custom_start = ""
custom_stop = ""
custom_reload = ""

# Render the template with the variables
result = template.render(
    title=title,
    name=name,
    custom_start=custom_start,
    custom_stop=custom_stop,
    custom_reload=custom_reload,
)

with open('control.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = ""
other_commands = '''
export MODEL_DIR=${SD_VOLTA_MODEL_DIR:-"/tmp/stable-diffusion-models"}
export REPO_DIR=${SD_VOLTA_REPO_DIR:-"/storage/stable-diffusion-volta"}

export SD_VOLTA_PORT=${SD_VOLTA_PORT:-"5003"}
export EXPOSE_PORTS="$EXPOSE_PORTS:$SD_VOLTA_PORT"
export PORT_MAPPING="$PORT_MAPPING:sd-volta"
export HUGGINGFACE_TOKEN=$HF_TOKEN

export LINK_MODEL_TO=${SD_VOLTA_LINK_MODEL_TO:-"${REPO_DIR}/data/models/"}
export LINK_LORA_TO=${SD_VOLTA_LINK_LORA_TO:-"${REPO_DIR}/data/lora"}
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)