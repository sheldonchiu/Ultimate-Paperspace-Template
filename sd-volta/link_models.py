import os
from pathlib import Path

repo_storage_dir = os.environ['REPO_DIR']
model_storage_dir = Path(os.environ['MODEL_DIR'])

webui_sd_model_path = Path(repo_storage_dir, 'data/models/')

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