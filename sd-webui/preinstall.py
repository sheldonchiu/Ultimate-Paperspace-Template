import os
from pathlib import Path

repo_storage_dir="/storage/stable-diffusion"
model_storage_dir="/tmp/stable-diffusion-models"
stable_diffusion_webui_path=f"{repo_storage_dir}/stable-diffusion-webui"

os.chdir(stable_diffusion_webui_path)

# Import launch.py which will automatically run the install script but not launch the WebUI.
import launch
launch.prepare_environment()
print("Finished SD-Webui preinstall")

os.makedirs(f"{repo_storage_dir}/stable-diffusion-webui/models/VAE", exist_ok=True)

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

