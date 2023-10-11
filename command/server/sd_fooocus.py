from pydantic import BaseModel
from playhouse.shortcuts import model_to_dict
from fastapi import APIRouter
from fastapi import Depends
import asyncio

from gradio_client import Client

from auth import authenticate
from db import Task
from share import *

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
    
def save_result(result, task):
    print(result)
    task.status = "Done"
    task.result = result
    task.save()
    
    
async def process(task: Task):
    config = task.config
    client = Client(f"{base_url}:{fooocus_port}{fooocus_subfoler}", serialize=False)
    client.predict(
        config.prompt,
        config.negative_prompt,
        config.image_styles,
        config.performance,
        config.resolution,
        config.image_number,
        config.seed,
        config.sampling_sharpness,
        config.sampler,
        config.scheduler,
        config.custom_steps,
        config.custom_switch,
        config.cfg_scale,
        config.sd_model_checkpoint,
        config.sd_refiner_checkpoint,
        config.sd_model_clip_skip,
        config.sd_refiner_clip_skip,
        config.sd_lora_1,
        config.sd_lora_1_weight,
        config.sd_lora_2,
        config.sd_lora_2_weight,
        config.sd_lora_3,
        config.sd_lora_3_weight,
        config.sd_lora_4,
        config.sd_lora_4_weight,
        config.sd_lora_5,
        config.sd_lora_5_weight,
        config.save_metadata_json,
        config.save_metadata_image,
        config.image2image,
        config.image2image_start_step,
        config.image2image_denoise_strength,
        config.image2image_scale_strength,
        config.revision,
        config.positive_prompt_strength,
        config.negative_prompt_strength,
        config.revision_image_1_strength,
        config.revision_image_2_strength,
        config.revision_image_3_strength,
        config.revision_image_4_strength,
        config.same_seed_for_all,
        config.output_format,
        config.control_lora_canny,
        config.control_lora_canny_edge_detection_low,
        config.control_lora_canny_edge_detection_high,
        config.control_lora_canny_start,
        config.control_lora_canny_stop,
        config.control_lora_canny_strength,
        config.control_lora_canny_model,
        config.control_lora_depth,
        config.control_lora_depth_start,
        config.control_lora_depth_stop,
        config.control_lora_depth_strength,
        config.control_lora_depth_model,
        config.prompt_expansion,
        config.freeu,
        config.backbone_scale_f_1,
        config.backbone_scale_f_2,
        config.skip_scale_f_1,
        config.skip_scale_f_2,
        config.enhance_image,
        config.tab,
        config.variation_or_upscale,
        config.input_image,
        config.outpaint,
        config.style_iterator,
        config.input_gallery,
        config.revision_gallery,
        config.keep_input_names,
        fn_index=29,
        result_callbacks=[lambda result: save_result(result, task)]
    )
    
    
    
@router.post("/fooocus/t2i")
def t2i(base: Base, authenticated: bool = Depends(authenticate)):
    task = Task.create(task_type="fooocus_t2i", config=base.dict())
    task.save()
    
    return model_to_dict(task)

    