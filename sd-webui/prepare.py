# You'll see this little code block at the beginning of every cell.
# It makes sure you have ran the first block that defines your settings.
try:
    %store -r symlink_to_notebooks model_storage_dir repo_storage_dir
    test = [symlink_to_notebooks, model_storage_dir, repo_storage_dir]
except NameError as e:
    print("There is an issue with your variables.")
    print("Please go back to the first block and make sure your settings are correct, then run the cell.")
    print('Error:', e)
    import sys
    sys.exit(1)
    
import os
from pathlib import Path

repo_storage_dir = Path(repo_storage_dir)
stable_diffusion_webui_path = repo_storage_dir / 'stable-diffusion-webui'

if not (stable_diffusion_webui_path / '.git').exists():    
    # It's possible that the stable_diffusion_webui_path already exists but the repo has not been downloaded.
    # We will init the repo manually.
    !mkdir -p "{stable_diffusion_webui_path}"
    %cd "{stable_diffusion_webui_path}"
    !git init
    !git remote add origin https://github.com/AUTOMATIC1111/stable-diffusion-webui
    !git fetch
    !git checkout -t origin/master -f
    # !git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui "{stable_diffusion_webui_path}"
else:
    print('stable-diffusion-webui already downloaded, updating...')
    !cd "{stable_diffusion_webui_path}" && git pull # no % so we don't interfere with the main process

!mkdir -p "{repo_storage_dir / 'stable-diffusion-webui' / 'outputs'}"
!mkdir -p "{repo_storage_dir / 'stable-diffusion-webui' / 'log'}"

symlinks = [
    (repo_storage_dir / 'stable-diffusion-webui', Path('/notebooks/stable-diffusion-webui')),
    (repo_storage_dir / 'stable-diffusion-webui' / 'outputs', Path('/notebooks/outputs')),
    (repo_storage_dir / 'stable-diffusion-webui' / 'log', repo_storage_dir / 'stable-diffusion-webui' / 'outputs' / 'log'),
    (Path('/storage'), Path('/notebooks/storage')),
    (Path(model_storage_dir), Path('/notebooks/models')),
           ]

if symlink_to_notebooks and repo_storage_dir != '/notebooks':
    print('\nCreating Symlinks...')
    for src, dest in symlinks:
        # If `/notebooks/stable-diffusion-webui` is a broken symlink then remove it.
        # The WebUI might have previously been installed in a non-persistent directory.
        if dest.is_symlink() and not dest.exists(): # .exists() validates a symlink
            print('Symlink broken, removing:', dest)
            dest.unlink()
        if not dest.exists():
            os.symlink(src, dest)
        print(os.path.realpath(dest), '->', dest)
        
try:
    %store -r symlink_to_notebooks model_storage_dir repo_storage_dir activate_xformers activate_deepdanbooru pip_cache_dir
    test = [symlink_to_notebooks, model_storage_dir, repo_storage_dir, activate_xformers, activate_deepdanbooru, pip_cache_dir]
except NameError as e:
    print("There is an issue with your variables.")
    print("Please go back to the first block and make sure your settings are correct, then run the cell.")
    print('Error:', e)
    import sys
    sys.exit(1)

from pathlib import Path
import os

%cd "{Path(repo_storage_dir, 'stable-diffusion-webui')}"

!pip install --upgrade pip
!pip install --upgrade wheel setuptools

if pip_cache_dir:
    !pip install git+https://github.com/pixelb/crudini.git
    !mkdir -p "{pip_cache_dir}"
    !python3 -m crudini --set /etc/pip.conf global cache-dir "{pip_cache_dir}"
    !echo "Set pip cache directory: $(pip cache dir)"

# Uninstall PyTorch and some other libraries so the WebUI can install the versions it needs
!pip uninstall -y torch torchvision torchaudio protobuf lxml

# Import launch.py which will automatically run the install script but not launch the WebUI.
import launch
launch.prepare_environment()

# Install things for this notebook
!pip install requests gdown bs4 markdownify

# The installer isn't installing deepdanbooru right now so we'll do it manually.
if activate_deepdanbooru:
    # https://github.com/KichangKim/DeepDanbooru/releases
    !pip install "git+https://github.com/KichangKim/DeepDanbooru.git@v3-20211112-sgd-e28#egg=deepdanbooru[tensorflow]" # $(curl --silent "https://api.github.com/KichangKim/DeepDanbooru/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')#egg=deepdanbooru[tensorflow]" # tensorflow==2.10.0 tensorflow-io==0.27.0 flatbuffers==1.12

# We need to install xformers first so that the WebUI installer can install the correct version of PyTorch afterwards
if activate_xformers:
    print('Installing xformers...')
    !pip install xformers==0.0.17.dev466 triton==2.0.0

# Make sure important directories exists
!mkdir -p "{model_storage_dir}/hypernetworks"
!mkdir -p "{model_storage_dir}/vae"
!mkdir -p "{model_storage_dir}/lora"
!mkdir -p "{repo_storage_dir}/stable-diffusion-webui/models/hypernetworks"
!mkdir -p "{repo_storage_dir}/stable-diffusion-webui/models/VAE"
!mkdir -p "{repo_storage_dir}/stable-diffusion-webui/log/images"

!echo -e "\n===================================\nDone! If you're seeing this the process has exited successfully.\n"


try:
    %store -r model_storage_dir repo_storage_dir link_novelai_anime_vae search_paperspace_datasets
    test = [model_storage_dir, repo_storage_dir, link_novelai_anime_vae, search_paperspace_datasets]
except NameError as e:
    print("There is an issue with your variables.")
    print("Please go back to the first block and make sure your settings are correct, then run the cell.")
    print('Error:', e)
    import sys
    sys.exit(1)

import os
from glob import glob
from pathlib import Path
import sys

model_storage_dir = Path(model_storage_dir)

if not model_storage_dir.exists():
    print('Your model storage directory does not exist:', model_storage_dir)
    sys.exit(1)

webui_root_model_path = Path(repo_storage_dir, 'stable-diffusion-webui/models')
webui_sd_model_path = Path(webui_root_model_path, 'Stable-diffusion')
webui_hypernetwork_path = Path(webui_root_model_path, 'hypernetworks')
webui_vae_path = Path(webui_root_model_path, 'VAE')
webui_lora_path =Path(repo_storage_dir, 'stable-diffusion-webui/extensions/sd-webui-additional-networks/models/lora')
webui_controlnet_path = Path(repo_storage_dir, 'stable-diffusion-webui/extensions/sd-webui-controlnet/models')

def delete_broken_symlinks(dir):
    deleted = False
    dir = Path(dir)
    for file in dir.iterdir():
        if file.is_symlink() and not file.exists():
            print('Symlink broken, removing:', file)
            file.unlink()
            deleted = True
    if deleted:
        print('')

def create_symlink(source, dest):
    if os.path.isdir(dest):
        dest = Path(dest, os.path.basename(source))
    if not dest.exists():
        os.symlink(source, dest)
    print(source, '->', Path(dest).absolute())

# Check for broken symlinks and remove them
print('Removing broken symlinks...')
delete_broken_symlinks(webui_sd_model_path)
delete_broken_symlinks(webui_hypernetwork_path)
delete_broken_symlinks(webui_vae_path)

def link_ckpts(source_path):
    # Link .ckpt and .safetensor/.st files (recursive)
    print('\nLinking .ckpt and .safetensor/.safetensors/.st files in', source_path)
    source_path = Path(source_path)
    for file in [p for p in source_path.rglob('*') if p.suffix in ['.ckpt', '.safetensor', '.safetensors', '.st']]:
        if Path(file).parent.parts[-1] not in ['hypernetworks', 'vae', 'lora', 'cn'] :
            if not (webui_sd_model_path / file.name):
                print('New model:', file.name)
            create_symlink(file, webui_sd_model_path)
    # Link config yaml files
    print('\nLinking config .yaml files in', source_path)
    for file in model_storage_dir.glob('*.yaml'):
        create_symlink(file, webui_sd_model_path)


link_ckpts(model_storage_dir)

# Link hypernetworks
print('\nLinking hypernetworks...')
hypernetwork_source_path = Path(model_storage_dir, 'hypernetworks')
if hypernetwork_source_path.is_dir():
    for file in hypernetwork_source_path.iterdir():
        create_symlink(hypernetwork_source_path / file, webui_hypernetwork_path)
else:
    print('Hypernetwork storage directory not found:', hypernetwork_source_path)

# Link VAEs
print('\nLinking VAEs...')
vae_source_path = Path(model_storage_dir, 'vae')
if vae_source_path.is_dir():
    for file in vae_source_path.iterdir():
        create_symlink(vae_source_path / file, webui_vae_path)
else:
    print('VAE storage directory not found:', vae_source_path)
    
# Link Loras
print('\nLinking Loras...')
lora_source_path = Path(model_storage_dir, 'lora')
if lora_source_path.is_dir():
    for file in lora_source_path.iterdir():
        create_symlink(lora_source_path / file, webui_lora_path
                      )
else:
    print('VAE storage directory not found:', lora_source_path)

# Link control net
print('\nLinking control net...')
cn_source_path = Path(model_storage_dir, 'cn')
if cn_source_path.is_dir():
    for file in cn_source_path.iterdir():
        create_symlink(cn_source_path / file, webui_controlnet_path
                      )
else:
    print('VAE storage directory not found:', lora_source_path)

# Link the NovelAI files for each of the NovelAI models
print('\nLinking NovelAI files for each of the NovelAI models...')
for model in model_storage_dir.glob('novelai-*.ckpt'):
    yaml = model.stem + '.yaml'
    if os.path.exists(yaml):
        print('New NovelAI model config:', yaml)
        create_symlink(yaml, webui_sd_model_path)

if link_novelai_anime_vae:
    print('\nLinking NovelAI anime VAE...')
    for model in model_storage_dir.glob('novelai-*.ckpt'):
        if (model_storage_dir / 'hypernetworks' / 'animevae.pt').is_file():
            vae = model.stem + '.vae.pt'
            if not os.path.exists(webui_vae_path):
                print(f'Linking NovelAI {vae} and {model}')
            create_symlink(model_storage_dir / 'hypernetworks' / 'animevae.pt', webui_vae_path)
        else:
            print(f'{model_storage_dir}/hypernetworks/animevae.pt not found!')

if search_paperspace_datasets:
    if Path('/datasets').is_dir():
        link_ckpts('/datasets')
    else:
        print('\nNo datasets mounted!')
        
try:
    %store -r model_storage_dir repo_storage_dir activate_xformers activate_deepdanbooru activate_medvram disable_pickle_check gradio_port gradio_auth ui_theme insecure_extension_access gradio_queue
    test = [model_storage_dir, repo_storage_dir, activate_xformers, activate_deepdanbooru, activate_medvram, disable_pickle_check, gradio_port, gradio_auth, ui_theme, insecure_extension_access, gradio_queue]
except NameError as e:
    print("There is an issue with your variables.")
    print("Please go back to the first block and make sure your settings are correct, then run the cell.")
    print('Error:', e)
    import sys
    sys.exit(1)

    
from pathlib import Path
%cd "{Path(repo_storage_dir, 'stable-diffusion-webui')}"

# Code to set the options you want as defined in the very first block
x_arg = '--xformers' if activate_xformers else ''
dd_arg = '--deepdanbooru' if activate_deepdanbooru else ''
mvram_arg = '--medvram' if activate_medvram else ''
pickled = '--disable-safe-unpickle' if disable_pickle_check else ''
port = f'--port {gradio_port}' if gradio_port else '--share'
auth = f'--gradio-auth {gradio_auth} --enable-insecure-extension-access' if gradio_auth else ''
theme = f'--theme {ui_theme}' if ui_theme else ''
insecure_extension_access = '--enable-insecure-extension-access' if insecure_extension_access else ''
queue = '--gradio-queue' if gradio_queue else ''

# Launch args go below:
!python webui.py {x_arg} {dd_arg} {mvram_arg} {pickled} {port} {auth} {theme} {queue}