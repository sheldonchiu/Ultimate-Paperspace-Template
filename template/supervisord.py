import os
from glob import glob
import yaml
from jinja2 import Template
from pathlib import Path

extra_env = {
    "data_dir": os.environ["DATA_DIR"],
    "working_dir": os.environ["WORKING_DIR"],
    "root_repo_dir": os.environ["ROOT_REPO_DIR"],
    "venv_dir": os.environ["VENV_DIR"],
    "log_dir": os.environ["LOG_DIR"],
    "image_outputs_dir": os.environ["IMAGE_OUTPUTS_DIR"],
}

current_path = os.path.dirname(os.path.abspath(__file__))
output_file = Path(current_path).parent / "supervisord.conf"

if __name__ == "__main__":
    # Load the YAML file
    targets = Path(current_path).parent / "**" / "template.yaml"
    yaml_files = glob(str(targets), recursive=True)
    yaml_files.sort()

    # Load the YAML file as a Jinja2 template
    data = []
    for file in yaml_files:
        with open(file, "r") as f:
            yaml_data = yaml.safe_load(f)
            if "supervisord" in yaml_data:
                content = Template(yaml_data["supervisord"]).render(
                    yaml_data | extra_env
                )
                data.append(content)

    with open(os.path.join(current_path, "supervisord.j2")) as f:
        template = Template(f.read())
    result = template.render({"content": data} | extra_env)
    with open(output_file, "w") as f:
        f.write(result)
