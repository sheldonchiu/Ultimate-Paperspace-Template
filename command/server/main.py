from fastapi import Body, FastAPI, Depends
from typing import Annotated
from fastapi.middleware.cors import CORSMiddleware
from playhouse.shortcuts import model_to_dict

from terminal import router as terminal_router
from sd_fooocus import router as fooocus_router
from db import Task
from share import *
from utils import get_gpu_info
from auth import authenticate

import logging
logging.basicConfig(level=logging.INFO)

app = FastAPI(docs_url=None, redoc_url=None)

# Allow CORS from all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(terminal_router)
app.include_router(fooocus_router)

@app.get('/status')
def get_status():
    return {'status': 'ok'}

@app.get('/info')
def get_info(authenticated: bool = Depends(authenticate)):
    gpu_info = get_gpu_info()
    return gpu_info

@app.get("/tasks/{task_id}")
def get_task(task_id: int, authenticated: bool = Depends(authenticate)):
    task = Task.get(Task.id==task_id)
    return model_to_dict(task)

@app.post("/tasks")
def get_tasks(task_ids: Annotated[list[int], Body()], authenticated: bool = Depends(authenticate)):
    tasks = Task.select().where(Task.id << task_ids)
    return [model_to_dict(task) for task in tasks]
