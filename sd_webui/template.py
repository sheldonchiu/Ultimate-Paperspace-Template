from jinja2 import Template

# Define the variables to be used in the template
title = "Stable Diffusion WebUI"
name = "sd_webui"
use_python = True
prepare_repo ='''
symlinks=(
    "$WEBUI_DIR:/notebooks/stable-diffusion-webui"
    "$WEBUI_DIR/outputs:/notebooks/outputs/stable-diffusion-webui"
    "$WEBUI_DIR/log:$WEBUI_DIR/outputs/log"
    "/storage:/notebooks/storage"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git" \\
TARGET_REPO_DIR=$WEBUI_DIR \\
UPDATE_REPO=$SD_WEBUI_UPDATE_REPO \\
UPDATE_REPO_COMMIT=$SD_WEBUI_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"

# git clone extensions that has their own model folder
if [[ ! -d "${WEBUI_DIR}/extensions/sd-webui-controlnet" ]]; then
    git clone https://github.com/Mikubill/sd-webui-controlnet.git "${WEBUI_DIR}/extensions/sd-webui-controlnet"
fi
if [[ ! -d "${WEBUI_DIR}/extensions/sd-webui-additional-networks" ]]; then
    git clone https://github.com/kohya-ss/sd-webui-additional-networks.git  "${WEBUI_DIR}/extensions/sd-webui-additional-networks"
fi
'''

prepare_env = ''' 
    # fix install issue with pycairo, which is needed by sd-webui-controlnet
    apt-get install -y libcairo2-dev libjpeg-dev libgif-dev
    pip install requests gdown bs4
    pip uninstall -y torch torchvision torchaudio protobuf lxml

    export PYTHONPATH="$PYTHONPATH:$WEBUI_DIR"
    # must run inside webui dir since env['PYTHONPATH'] = os.path.abspath(".") existing in launch.py
    cd $WEBUI_DIR
    python $current_dir/preinstall.py
    cd $current_dir

    if [[ -n "${ACTIVATE_XFORMERS}" ]]; then
        pip install xformers==0.0.19
    fi
'''
    
download_model = '''
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
'''

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
'''

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