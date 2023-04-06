import os
from pathlib import Path

repo_storage_dir = os.environ['REPO_DIR']
model_storage_dir = Path(os.environ['MODEL_DIR'])
stable_diffusion_webui_path = os.environ['WEBUI_DIR']

webui_sd_model_path =  os.environ.get('LINK_MODEL_TO', None)
webui_vae_path = os.environ.get('LINK_VAE_TO', None)
webui_hypernetwork_path = os.environ.get('LINK_HYPERNETWORK_TO', None)
webui_lora_path = os.environ.get('LINK_LORA_TO', None)
webui_controlnet_path = os.environ.get('LINK_CONTROLNET_TO', None)
webui_embedding_path = os.environ.get('LINK_EMBEDDING_TO', None)

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

def link_ckpts(source_path, target_path):
    # Link .ckpt and .safetensor/.st files (recursive)
    print('\nLinking .ckpt and .safetensor/.safetensors/.st files in', source_path)
    delete_broken_symlinks(target_path)
    source_path = Path(source_path)
    target_path = Path(target_path)
    for file in [p for p in source_path.rglob('*') if p.suffix in ['.ckpt', '.safetensor', '.safetensors', '.st']]:
        if Path(file).parent.parts[-1] not in ['embedding', 'hypernetworks', 'vae', 'lora', 'cn'] :
            if not (target_path / file.name):
                print('New model:', file.name)
            create_symlink(file, target_path)
    # Link config yaml files
    print('\nLinking config .yaml files in', source_path)
    for file in model_storage_dir.glob('*.yaml'):
        create_symlink(file, target_path)
        
def link_other(name, source_path, target_path):
    print(f'\nLinking {name}...')
    if not os.path.isdir(target_path):
        print(f'{name} storage directory not found:', target_path)
        return
    delete_broken_symlinks(target_path)
    source_path = Path(model_storage_dir, name)
    if source_path.is_dir():
        for file in source_path.iterdir():
            create_symlink(source_path / file, target_path)
    else:
        print(f'{name} storage directory not found:', source_path)

if webui_sd_model_path:
    webui_sd_model_path = webui_sd_model_path.split(',')
    for path in webui_sd_model_path:
        link_ckpts(model_storage_dir, path)

# Link hypernetworks
if webui_hypernetwork_path:
    webui_hypernetwork_path = webui_hypernetwork_path.split(',')
    for path in webui_hypernetwork_path:
        link_other('hypernetworks', model_storage_dir, path)
# Link VAEs
if webui_vae_path:
    webui_vae_path = webui_vae_path.split(',')
    for path in webui_vae_path:
        link_other('vae', model_storage_dir, path)
# Link Loras
if webui_lora_path:
    webui_lora_path = webui_lora_path.split(',')
    for path in webui_lora_path:
        link_other('lora', model_storage_dir, path)
# Link control net
if webui_controlnet_path:
    webui_controlnet_path = webui_controlnet_path.split(',')
    for path in webui_controlnet_path:
        link_other('cn', model_storage_dir, path)
        
if webui_embedding_path:
    webui_embedding_path = webui_embedding_path.split(',')
    for path in webui_embedding_path:
        link_other('embedding', model_storage_dir, path)
