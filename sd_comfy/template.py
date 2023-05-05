from jinja2 import Template

# Define the variables to be used in the template
title = "Stable Diffusion Comfy" 
name = "sd_comfy"
use_python = True

prepare_repo = '''
symlinks=(
    "$WEBUI_DIR:/notebooks/stable-diffusion-comfy"
    "/storage:/notebooks/storage"
    "$MODEL_DIR:/notebooks/models"
)
TARGET_REPO_URL="https://github.com/comfyanonymous/ComfyUI.git" \\
TARGET_REPO_DIR=$WEBUI_DIR \\
UPDATE_REPO=$SD_COMFY_UPDATE_REPO \\ 
UPDATE_REPO_COMMIT=$SD_COMFY_UPDATE_REPO_COMMIT \\
bash $current_dir/../utils/prepare_repo.sh "${symlinks[@]}"
'''
prepare_env = ''''''

download_model = '''
bash $current_dir/../utils/model_download/main.sh
python $current_dir/../utils/model_download/link_model.py
'''

action_before_start = ""

start = f'''
cd "$REPO_DIR"
nohup python main.py --dont-print-server > /tmp/{name}.log 2>&1 &
echo $! > /tmp/{name}.pid
'''
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