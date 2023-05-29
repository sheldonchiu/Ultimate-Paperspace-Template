from jinja2 import Template

# Define the variables to be used in the template
title = "Stable Diffusion Comfy" 
name = "sd_comfy"
use_python = True

prepare_repo = '''
symlinks=(
    "$REPO_DIR:/notebooks/stable-diffusion-comfy"
    "/storage:/notebooks/storage"
    "$REPO_DIR/output:$IMAGE_OUTPUTS_DIR/stable-diffusion-comfy"
    "$MODEL_DIR:/notebooks/models"
)

TARGET_REPO_URL="https://github.com/comfyanonymous/ComfyUI.git" \\
TARGET_REPO_DIR=$REPO_DIR \\
UPDATE_REPO=$SD_COMFY_UPDATE_REPO \\
UPDATE_REPO_COMMIT=$SD_COMFY_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"
'''.strip()
prepare_env = '''
    cd $REPO_DIR
    pip install xformers
    pip install torchvision torchaudio --no-deps
    pip install -r requirements.txt
'''.strip()

download_model = '''
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
'''.strip()

action_before_start = ""

start = f'''
cd "$REPO_DIR"
nohup python main.py --dont-print-server > /tmp/{name}.log 2>&1 &
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
    
export_required_env = '''
'''.strip()
other_commands = '''
export MODEL_DIR=${SD_COMFY_MODEL_DIR:-"/tmp/stable-diffusion-models"}
export REPO_DIR=${SD_COMFY_REPO_DIR:-"/storage/stable-diffusion-comfy"}

export SD_COMFY_PORT=${SD_COMFY_PORT:-"8188"}
export EXPOSE_PORTS="$EXPOSE_PORTS:$SD_COMFY_PORT"
export PORT_MAPPING="$PORT_MAPPING:sd-comfy"
export HUGGINGFACE_TOKEN=$HF_TOKEN

export LINK_MODEL_TO=${SD_COMFY_LINK_MODEL_TO:-"${REPO_DIR}/models/checkpoints"}
export LINK_VAE_TO=${SD_COMFY_LINK_VAE_TO:-"${REPO_DIR}/models/vae"}
export LINK_LORA_TO=${SD_COMFY_LINK_LORA_TO:-"${REPO_DIR}/models/loras"}
export LINK_CONTROLNET_TO=${SD_COMFY_LINK_CONTROLNET_TO:-"${REPO_DIR}/models/controlnet"}
export LINK_EMBEDDING_TO=${SD_COMFY_LINK_EMBEDDING_TO:-"${REPO_DIR}/models/embeddings"}
export LINK_UPSCALER_TO=${SD_COMFY_LINK_EMBEDDING_TO:-"${REPO_DIR}/models/upscale_models"}
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)