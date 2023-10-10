from pydantic import BaseModel
from fastapi import APIRouter

router = APIRouter()

class Base(BaseModel):
    prompt: str
    negative_prompt: str = ""
    image_styles: list[str] = ["Default (Slightly Cinematic)"]
    performance: str = "Speed"
    resolution: str = "1024×1024 (1:1)"
    image_number: int = 1
    seed: str = "861588053435941262"
    sampling_sharpness: float = 2.0
    sampler: str = "dpmpp_2m_sde_gpu"
    scheduler: str = "karras"
    custom_steps: int = 24 
    custom_switch: float = 0.75
    cfg_scale: int = 7
    sd_model_checkpoint: str = "sd_xl_base_1.0_0.9vae.safetensors"
    sd_refiner_checkpoint: str = "sd_xl_refiner_1.0_0.9vae.safetensors"
    sd_model_clip_skip: int = -2
    sd_refiner_clip_skip: int = -2
    sd_lora_1: str = "sd_xl_offset_example-lora_1.0.safetensors"
    sd_lora_1_weight: float = 0.5
    sd_lora_2: str = "None"
    sd_lora_2_weight: float = -2
    sd_lora_3: str = "None" 
    sd_lora_3_weight: float = -2
    sd_lora_4: str = "None"
    sd_lora_4_weight: float = -2
    sd_lora_5: str = "None"
    sd_lora_5_weight: float = -2
    save_metadata_json: bool = False
    save_metadata_image: bool = True
    image2image: bool = False
    image2image_start_step: float = 0
    image2image_denoise_strength: float = 0.2
    image2image_scale_strength: float = 1
    revision: bool = False
    positive_prompt_strength: float = 0
    negative_prompt_strength: float = 0
    revision_image_1_strength: float = -2
    revision_image_2_strength: float = -2
    revision_image_3_strength: float = -2
    revision_image_4_strength: float = -2
    same_seed_for_all: bool = False
    output_format: str = "png"
    control_lora_canny: bool = False
    control_lora_canny_edge_detection_low: float = 0
    control_lora_canny_edge_detection_high: float = 0
    control_lora_canny_start: float = 0
    control_lora_canny_stop: float = 0
    control_lora_canny_strength: float = 0
    control_lora_canny_model: str = "control-lora-canny-rank256.safetensors"
    control_lora_depth: bool = False
    control_lora_depth_start: float = 0
    control_lora_depth_stop: float = 0
    control_lora_depth_strength: float = 0 
    control_lora_depth_model: str = "control-lora-depth-rank128.safetensors"
    prompt_expansion: bool = True
    freeu: bool = False
    backbone_scale_f_1: float = 0
    backbone_scale_f_2: float = 0
    skip_scale_f_1: float = 0
    skip_scale_f_2: float = 0
    enhance_image: bool = False
    tab: str = "uov"
    variation_or_upscale: str = "Disabled"
    input_image: str = None
    outpaint: list[str] = []
    style_iterator: bool = False
    input_gallery: str = None
    revision_gallery: str = None
    keep_input_names: bool = False
    
    