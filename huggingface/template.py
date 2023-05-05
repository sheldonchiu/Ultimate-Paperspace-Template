from jinja2 import Template

# Define the variables to be used in the template
title = "HuggingFace Hub"
name = "huggingface"
use_python = True

prepare_repo = ""
prepare_env = "pip install --upgrade huggingface_hub"
download_model = ""
action_before_start = ""
start = "python $current_dir/upload.py"

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