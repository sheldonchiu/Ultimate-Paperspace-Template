from jinja2 import Template

# Define the variables to be used in the template
title = "Stable Diffusion WebUI"
name = "sd_webui"
use_python = True
prepare_repo ='''
symlinks=(
    "$REPO_DIR/outputs:$IMAGE_OUTPUTS_DIR/stable-diffusion-webui"
    "$REPO_DIR/log:$REPO_DIR/outputs/log"
    "/storage:/notebooks/storage"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" \\
TARGET_REPO_DIR=$REPO_DIR \\
UPDATE_REPO=$SD_WEBUI_UPDATE_REPO \\
UPDATE_REPO_COMMIT=$SD_WEBUI_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"

# git clone extensions that has their own model folder
if [[ ! -d "${REPO_DIR}/extensions/sd-webui-controlnet" ]]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git "${REPO_DIR}/extensions/sd-webui-controlnet"
fi
if [[ ! -d "${REPO_DIR}/extensions/sd-webui-additional-networks" ]]; then
    git clone https://github.com/kohya-ss/sd-webui-additional-networks.git  "${REPO_DIR}/extensions/sd-webui-additional-networks"
fi
'''.strip()

prepare_env = ''' 
    # fix install issue with pycairo, which is needed by sd-webui-controlnet
    apt-get install -y libcairo2-dev libjpeg-dev libgif-dev
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml

    export PYTHONPATH="$PYTHONPATH:$REPO_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $REPO_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    pip install xformers==0.0.20
'''.strip()
    
download_model = '''
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
'''.strip()

start = "bash start.sh"

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
    start=start,
)

with open('main.sh', 'w') as f:
    f.write(result)
    
    # Load the template from a file
with open('../template/control.j2') as f:
    template = Template(f.read())
    
custom_start = ""
custom_stop = ""
custom_reload = ""

additional_condition = '''
elif [[ $1 == "download_model" ]]; then
    echo "### Downloading Models ###"
    bash $current_dir/../utils/model_download/main.sh
    python $current_dir/../utils/model_download/link_model.py
    echo "Finished Downloading Models for Stable Diffusion WebUI"
'''.strip()

# Render the template with the variables
result = template.render(
    title=title,
    name=name, 
    custom_start=custom_start,
    custom_stop=custom_stop,
    custom_reload=custom_reload,
    additional_condition=additional_condition
)

with open('control.sh', 'w') as f:
    f.write(result)
    
##############################################

with open('../template/env.j2') as f:
    template = Template(f.read())
    
export_required_env = ""
other_commands = '''
export MODEL_DIR=${SD_WEBUI_MODEL_DIR:-"/tmp/stable-diffusion-models"}
export REPO_DIR=${SD_WEBUI_REPO_DIR:-"/storage/stable-diffusion-webui"}

export SD_WEBUI_PORT=${SD_WEBUI_PORT:-"7860"}
export EXPOSE_PORTS="$EXPOSE_PORTS:$SD_WEBUI_PORT"
export PORT_MAPPING="$PORT_MAPPING:sd-webui"

export LINK_MODEL_TO=${SD_WEBUI_LINK_MODEL_TO:-"${REPO_DIR}/models/Stable-diffusion"}
export LINK_VAE_TO=${SD_WEBUI_LINK_VAE_TO:-"${REPO_DIR}/models/VAE"}
export LINK_HYPERNETWORK_TO=${SD_WEBUI_LINK_HYPERNETWORK_TO:-"${REPO_DIR}/models/hypernetworks"}
export LINK_LORA_TO=${SD_WEBUI_LINK_LORA_TO:-"${REPO_DIR}/extensions/sd-webui-additional-networks/models/lora,${REPO_DIR}/models/Lora"}
export LINK_CONTROLNET_TO=${SD_WEBUI_LINK_CONTROLNET_TO:-"${REPO_DIR}/extensions/sd-webui-controlnet/models"}
export LINK_EMBEDDING_TO=${SD_WEBUI_LINK_EMBEDDING_TO:-"${REPO_DIR}/embeddings"}
'''.strip()
result = template.render(
    export_required_env=export_required_env,
    other_commands=other_commands,
)

with open('.env', 'w') as f:
    f.write(result)